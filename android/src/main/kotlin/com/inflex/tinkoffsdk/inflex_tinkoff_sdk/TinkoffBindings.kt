package  com.inflex.tinkoffsdk.flutter_tinkoff_sdk

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import ru.tinkoff.acquiring.sdk.localization.Language
import ru.tinkoff.acquiring.sdk.models.DarkThemeMode
import ru.tinkoff.acquiring.sdk.models.enums.CheckType
import ru.tinkoff.acquiring.sdk.utils.Money
import java.lang.Exception

typealias MethodChannelFunction = suspend (call: MethodCall, result: MethodChannel.Result, delegate: TinkoffAcquiringSdkDelegate, scope: CoroutineScope) -> Unit

fun safe(function: MethodChannelFunction): MethodChannelFunction = { call, result, delegate, scope ->
    try {
        function(call, result, delegate, scope)
    } catch (e: Exception) {
        result.error(TINKOFF_COMMON_STATUS_FATAL_ERROR, e.message, null)
    }
}

private const val TINKOFF_OPEN_PAYMENT_SCREEN = "openPaymentScreen"
private val tinkoffOpenPaymentScreen: MethodChannelFunction = safe { call, result, delegate, scope ->
    val methodCallResult = delegate.openPaymentScreen(
            order = call.argument("orderId") ?: error("orderId is required"),
            money = call.argument("amount") ?: error("amount is required"),
            orderTitle =  call.argument("title")  ?: error("title is required"),
            customerId =  call.argument("customerId")  ?: error("customerId is required"),
            personEmail =  call.argument("email")  ?: error("email is required"),
            paymentId =  call.argument("paymentId")  ?: error("paymentId is required"),
            terminalKey  =  call.argument("terminalKey")  ?: error("terminalKey is required"),
            password  =  call.argument("publicKey")  ?: error("password is required"),

    )

    scope.doOnMain { result.success(mapOf(
        "status" to methodCallResult.status.name,
        "error" to methodCallResult.error?.message,
        "cardId" to methodCallResult.cardId,
        "paymentId" to methodCallResult.paymentId
    )) }
}

private const val TINKOFF_OPEN_GOOGLE_PAY = "openGooglePay"
private val tinkoffOpenGooglePay: MethodChannelFunction = safe { call, result, delegate, scope ->
    val tinkoffOrderOptions = call.toTinkoffOrderOptions()
    val tinkoffCustomerOptions = call.toTinkoffCustomerOptions()
    val tinkoffFeaturesOptions = call.toTinkoffFeaturesOptions()

    val methodCallResult = delegate.openGooglePay(
        tinkoffOrderOptions, tinkoffCustomerOptions, tinkoffFeaturesOptions
    )

    when(methodCallResult.status) {
        TinkoffAcquiringSdkDelegate.TinkoffAcquiringDelegateOpenGooglePayStatus.RESULT_REOPEN_UI -> {
//            val methodCallResult = delegate.openPaymentScreen(
//                tinkoffOrderOptions, tinkoffCustomerOptions, tinkoffFeaturesOptions, methodCallResult.paymentState
//            )

            scope.doOnMain { result.success(mapOf(
                "status" to methodCallResult.status.name,
                "error" to methodCallResult.error?.message,
                "cardId" to methodCallResult.cardId,
                "paymentId" to methodCallResult.paymentId
            )) }
        }
        else -> scope.doOnMain { result.success(mapOf(
            "status" to methodCallResult.status.name,
            "error" to methodCallResult.error?.message,
            "cardId" to methodCallResult.cardId,
            "paymentId" to methodCallResult.paymentId,
            "rebillId" to methodCallResult.rebillId
        )) }
    }
}



val tinkoffMethodBundle = mapOf(
    TINKOFF_OPEN_PAYMENT_SCREEN to tinkoffOpenPaymentScreen,
    TINKOFF_OPEN_GOOGLE_PAY to tinkoffOpenGooglePay,
)