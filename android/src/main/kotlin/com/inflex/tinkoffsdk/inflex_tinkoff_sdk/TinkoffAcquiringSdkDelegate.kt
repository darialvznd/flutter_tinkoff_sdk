package com.inflex.tinkoffsdk.flutter_tinkoff_sdk

import android.app.Activity
import androidx.fragment.app.FragmentActivity
import ru.tinkoff.acquiring.sdk.AcquiringSdk
import ru.tinkoff.acquiring.sdk.TinkoffAcquiring
import ru.tinkoff.acquiring.sdk.models.*
import ru.tinkoff.acquiring.sdk.models.enums.CheckType
import ru.tinkoff.acquiring.sdk.models.enums.Tax
import ru.tinkoff.acquiring.sdk.models.enums.Taxation
import ru.tinkoff.acquiring.sdk.models.options.screen.PaymentOptions
import ru.tinkoff.acquiring.sdk.payment.PaymentListenerAdapter
import ru.tinkoff.acquiring.sdk.utils.GooglePayHelper
import ru.tinkoff.acquiring.sdk.utils.Money
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class TinkoffAcquiringSdkDelegate(private val activityDelegate: ActivityDelegate) {

    private var tinkoffAcquiring: TinkoffAcquiring? = null
    private var googlePayHelper: GooglePayHelper? = null


    data class TinkoffAcquiringDelegateOpenPaymentScreenResponse(
            val status: TinkoffAcquiringDelegateOpenPaymentScreenStatus,
            val error: Throwable? = null,
            val cardId: String? = null,
            val paymentId: Long? = null
    )

    enum class TinkoffAcquiringDelegateOpenPaymentScreenStatus { RESULT_OK, RESULT_CANCELLED, RESULT_NONE, RESULT_ERROR, ERROR_NOT_INITIALIZED, ERROR_NO_ACTIVITY }

    suspend fun openPaymentScreen(
            order: String,
            money: Double,
            orderTitle: String,
            customerId: String,
            personEmail: String,
            paymentId: String,
            terminalKey: String,
            password: String,
            paymentState: AsdkState? = null
    ): TinkoffAcquiringDelegateOpenPaymentScreenResponse {
       

        val paymentOptions =
                PaymentOptions().setOptions {
                    orderOptions {
                        orderId = order
                        amount = Money.ofRubles(money)
                        title = orderTitle
                        recurrentPayment = false
                       
                    }
                    customerOptions {
                        checkType = CheckType.NO.toString()
                        customerKey = customerId
                        email = personEmail
                    }
                    featuresOptions {
                        useSecureKeyboard = true
                        userCanSelectCard = true
                    }
                }

        val paymentPayloadId = paymentId.toLong()

        AcquiringSdk.isDeveloperMode = false
        AcquiringSdk.isDebug = true
        
            return activityDelegate.runActivityForResult(
                    { activity  ->
                        TinkoffAcquiring(terminalKey, password).openPaymentScreen(
                                activity as FragmentActivity,
                                paymentOptions,
                                PAYMENT_CARD_REQUEST_CODE,
                                SelectCardAndPayState(paymentPayloadId)
                        )
                    },
                    PAYMENT_CARD_REQUEST_CODE,
                    { resultCode, data ->
                        when (resultCode) {
                            Activity.RESULT_OK -> TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                                    status = TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_OK,
                                    cardId = data?.getStringExtra(TinkoffAcquiring.EXTRA_CARD_ID) ,
                                    paymentId = data?.getLongExtra(TinkoffAcquiring.EXTRA_PAYMENT_ID, -1).let { if (it != -1L) it else null }
                            )
                            Activity.RESULT_CANCELED -> TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                                    status = TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_CANCELLED
                            )
                            TinkoffAcquiring.RESULT_ERROR -> TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                                    status = TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_ERROR,
                                    error = data?.getSerializableExtra(TinkoffAcquiring.EXTRA_ERROR)  as Throwable
                            )
                            else -> TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                                    status = TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_NONE
                            )
                        }
                    }
            )
                    ?: TinkoffAcquiringDelegateOpenPaymentScreenResponse(status = TinkoffAcquiringDelegateOpenPaymentScreenStatus.ERROR_NO_ACTIVITY)
       

    }

    data class TinkoffAcquiringDelegateOpenGooglePayResponse(
            val status: TinkoffAcquiringDelegateOpenGooglePayStatus,
            val error: Throwable? = null,
            val cardId: String? = null,
            val paymentId: Long? = null,
            val rebillId: String? = null,
            val paymentState: AsdkState? = null
    )

    enum class TinkoffAcquiringDelegateOpenGooglePayStatus { RESULT_OK, RESULT_CANCELLED, RESULT_REOPEN_UI, RESULT_ERROR, ERROR_NOT_INITIALIZED, ERROR_NO_ACTIVITY }

    suspend fun openGooglePay(
            tinkoffOrderOptions: TinkoffOrderOptions,
            tinkoffCustomerOptions: TinkoffCustomerOptions,
            tinkoffFeaturesOptions: TinkoffFeaturesOptions
    ): TinkoffAcquiringDelegateOpenGooglePayResponse {
        if (tinkoffAcquiring == null || googlePayHelper == null) return TinkoffAcquiringDelegateOpenGooglePayResponse(status = TinkoffAcquiringDelegateOpenGooglePayStatus.ERROR_NOT_INITIALIZED)

        val googlePayToken = activityDelegate.runActivityForResult(
                { activity -> googlePayHelper!!.openGooglePay(activity, tinkoffOrderOptions.money, PAYMENT_GOOGLE_PAY_REQUEST_CODE) },
                PAYMENT_GOOGLE_PAY_REQUEST_CODE,
                { resultCode, data ->
                    when (resultCode) {
                        Activity.RESULT_OK -> GooglePayHelper.getGooglePayToken(data!!)
                        Activity.RESULT_CANCELED -> "canceled"
                        else -> null
                    }
                }
        ) ?: return TinkoffAcquiringDelegateOpenGooglePayResponse(
                status = TinkoffAcquiringDelegateOpenGooglePayStatus.ERROR_NO_ACTIVITY
        )

        if (googlePayToken == "canceled") return TinkoffAcquiringDelegateOpenGooglePayResponse(status = TinkoffAcquiringDelegateOpenGooglePayStatus.RESULT_CANCELLED)

        return suspendCoroutine { sink ->
            tinkoffAcquiring!!.initPayment(googlePayToken, makeTinkoffPaymentOptions(tinkoffOrderOptions, tinkoffCustomerOptions, tinkoffFeaturesOptions))
                    .subscribe(object : PaymentListenerAdapter() {
                        override fun onSuccess(paymentId: Long, cardId: String?, rebillId: String?) =
                                sink.resume(TinkoffAcquiringDelegateOpenGooglePayResponse(
                                        status = TinkoffAcquiringDelegateOpenGooglePayStatus.RESULT_OK,
                                        paymentId = paymentId,
                                        rebillId = rebillId,
                                        cardId = cardId
                                ))

                        override fun onError(throwable: Throwable) =
                                sink.resume(TinkoffAcquiringDelegateOpenGooglePayResponse(
                                        status = TinkoffAcquiringDelegateOpenGooglePayStatus.RESULT_ERROR,
                                        error = throwable
                                ))

                        override fun onUiNeeded(state: AsdkState) =
                                sink.resume(TinkoffAcquiringDelegateOpenGooglePayResponse(
                                        status = TinkoffAcquiringDelegateOpenGooglePayStatus.RESULT_REOPEN_UI,
                                        paymentState = state
                                ))
                    })
                    .start()
        }
    }


    companion object {
        private const val PAYMENT_CARD_REQUEST_CODE = 4323
        private const val PAYMENT_GOOGLE_PAY_REQUEST_CODE = 4321
        private const val ORDER_ID = "orderId"
        private const val PAYMENT_PAYLOAD_ID = "paymentPayloadId"
        private const val IS_SHOW_PAYMENT = "isShowPayment"
    }
}