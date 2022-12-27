import Flutter
import UIKit
import TinkoffASDKUI
import TinkoffASDKCore

public var TINKOFF_COMMON_STATUS_FATAL_ERROR = "FATAL_ERROR"

public struct TinkoffOrderOptions {
    var orderId: String
    var amount: NSNumber
    var title: String
    var paymentId: String
}

public struct TinkoffCustomerOptions {
    var customerId: String
    var email: String?
    var lang: String?
}

public struct TinkoffSDKConfiguration {
    var terminalKey: String
    var publicKey: String
    var sdkEnv: AcquiringSdkEnvironment
}



public struct TinkoffApplePayOptions {
    var merchantIdentifier: String
}

public typealias TinkoffResult<T> = (T) -> Void


private let viewConfigurationLanguageData: [String: [String: String]] = [
    "ru": [
        "total": "Цена",
    ],
    "en": [
        "total": "Total",
    ]]

public class TinkoffAcquiringDelegate  {
    
    private var uiPaymentSDK: AcquiringUISDK?
    
    private var registrar: FlutterPluginRegistrar
    private var viewController: UIViewController?
    
    
    
    init(registrar: FlutterPluginRegistrar, uiViewController: UIViewController?) {
        self.registrar = registrar
        self.viewController = uiViewController
    }
    
    
    private func initializeViewConfiguration(
        title: String,
        amount: NSNumber,
        email: String?,
        lang: String? = "en"
    ) -> AcquiringViewConfiguration {
        let localizable =  AcquiringViewConfiguration.LocalizableInfo.init(lang: lang)
        let viewConfiguration = AcquiringViewConfiguration()
        viewConfiguration.fields = []
        
        //title in UINavigationBar in case of fullscreen 
        viewConfiguration.viewTitle = title
        viewConfiguration.localizableInfo = localizable
        
        let title = NSAttributedString(string: title)
        let amount = NSAttributedString(string:
                                            "\(viewConfigurationLanguageData[lang!]?["total"] ?? "Price") \(amount) ₽")
        
        viewConfiguration.fields.append(AcquiringViewConfiguration.InfoFields.amount(title: title, amount: amount))
        
        return viewConfiguration
    }
    
    
    
    
    
    func getPaymentConfiguration(paymentId: String) -> AcquiringConfiguration {
        let intPaymentID = Int(paymentId) ?? 0
        return AcquiringConfiguration(paymentStage: .paymentId(Int64(intPaymentID)))
    }
    
    public struct TinkoffAcquiringDelegateOpenPaymentScreenResponse {
        var status: TinkoffAcquiringDelegateOpenPaymentScreenStatus
        var error: Error? = nil
        var cardId: String? = nil
        var paymentId: Int64? = nil
    }
    public enum TinkoffAcquiringDelegateOpenPaymentScreenStatus: String {
        case RESULT_OK = "RESULT_OK"
        case RESULT_ERROR = "RESULT_ERROR"
        case RESULT_CANCELLED = "RESULT_CANCELLED"
    }
    public func openPaymentScreen(
        tinkoffOrderOptions: TinkoffOrderOptions,
        tinkoffCustomerOptions: TinkoffCustomerOptions,
        sdkConfiguration: AcquiringSdkConfiguration,
        paymentId: String,
        result: @escaping TinkoffResult<TinkoffAcquiringDelegateOpenPaymentScreenResponse>
    ) {
        
        let paymentData = PaymentInitData(
            amount: Int64( truncating: tinkoffOrderOptions.amount),
            orderId: tinkoffOrderOptions.orderId,
            customerKey: tinkoffCustomerOptions.customerId
        )
        
        let paymentConfiguration =
        getPaymentConfiguration(paymentId: paymentId)
        
        let viewConfiguration = initializeViewConfiguration(
            title: tinkoffOrderOptions.title,
            amount: tinkoffOrderOptions.amount,
            email: tinkoffCustomerOptions.email,
            lang: tinkoffCustomerOptions.lang
        )
        
        uiPaymentSDK = try? AcquiringUISDK(configuration: sdkConfiguration)
        
        uiPaymentSDK?.presentPaymentView(
            on: self.viewController!,
            paymentData: paymentData,
            configuration: viewConfiguration,
            acquiringConfiguration: paymentConfiguration,
            completionHandler: { [weak self] apiResult in
                do {
                    let unfoldedResult = try apiResult.get()
                    if (unfoldedResult.success) {
                        result(TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                            status: TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_OK,
                            paymentId: unfoldedResult.paymentId
                        ))
                    }
                    else {
                        result(TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                            status: TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_CANCELLED,
                            paymentId: unfoldedResult.paymentId
                        ))
                    }
                }
                catch {
                    result(TinkoffAcquiringDelegateOpenPaymentScreenResponse(
                        status: TinkoffAcquiringDelegateOpenPaymentScreenStatus.RESULT_ERROR,
                        error: error
                    ))
                }
            })
    }
    
    
    
    private func responseReviewing(_ response: Result<PaymentStatusResponse, Error>) {
        switch response {
        case let .success(result):
            print(result)
            
        case let .failure(error):
            print(error)
        }
    }
    
    public struct TinkoffAcquiringDelegateOpenApplePayResponse {
        var status: TinkoffAcquiringDelegateOpenApplePayStatus
        var error: Error? = nil
        var cardId: String? = nil
        var paymentId: Int64? = nil
    }
    public enum TinkoffAcquiringDelegateOpenApplePayStatus: String {
        case RESULT_OK = "RESULT_OK"
        case RESULT_ERROR = "RESULT_ERROR"
        case ERROR_NOT_INITIALIZED = "ERROR_NOT_INITIALIZED"
    }
    
    public func openApplePay(
        tinkoffOrderOptions: TinkoffOrderOptions,
        tinkoffCustomerOptions: TinkoffCustomerOptions,
        tinkoffApplePayOptions: TinkoffApplePayOptions,
        result: @escaping TinkoffResult<TinkoffAcquiringDelegateOpenApplePayResponse>
    ) {
        
        var paymentData = PaymentInitData(
            amount: NSDecimalNumber(decimal: tinkoffOrderOptions.amount.decimalValue),
            orderId: tinkoffOrderOptions.orderId,
            customerKey: tinkoffCustomerOptions.customerId
        )
        paymentData.savingAsParentPayment = false
        
        var applePayConfiguration = AcquiringUISDK.ApplePayConfiguration()
        applePayConfiguration.merchantIdentifier = tinkoffApplePayOptions.merchantIdentifier
        
        uiPaymentSDK?.presentPaymentApplePay(
            on: self.viewController!,
            paymentData: paymentData,
            viewConfiguration: initializeViewConfiguration(
                title: tinkoffOrderOptions.title,
                amount: tinkoffOrderOptions.amount,
                email: tinkoffCustomerOptions.email
            ),
            paymentConfiguration: applePayConfiguration,
            completionHandler: { (apiResult: Result<PaymentStatusResponse, Error>) -> Void in
                do {
                    let unfoldedResult = try apiResult.get()
                    print(unfoldedResult.status)
                    result(TinkoffAcquiringDelegateOpenApplePayResponse(
                        status: TinkoffAcquiringDelegateOpenApplePayStatus.RESULT_OK,
                        paymentId: unfoldedResult.paymentId
                    ))
                }
                catch {
                    result(TinkoffAcquiringDelegateOpenApplePayResponse(
                        status: TinkoffAcquiringDelegateOpenApplePayStatus.RESULT_ERROR,
                        error: error
                    ))
                }
            }
        )
    }
    
    
    
    
    private static func formatAmount(_ value: Int64, currency: String = "₽") -> String { return "\(value) \(currency)" }
    
}

public class SwiftFlutterTinkoffSDkPlugin: NSObject, FlutterPlugin {
    var delegate: TinkoffAcquiringDelegate
    
    
    init(pluginRegistrar: FlutterPluginRegistrar, uiViewController: UIViewController?) {
        delegate = TinkoffAcquiringDelegate(registrar: pluginRegistrar, uiViewController: uiViewController)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tinkoff_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTinkoffSDkPlugin(pluginRegistrar: registrar, uiViewController: UIApplication.shared.delegate?.window??.rootViewController)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        guard let arguments = (call.arguments as? [String: Any]) else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "call.arguments are null", details: nil)); return }
        
        switch call.method {
        case "openPaymentScreen":
            guard let paymentId: String = arguments["paymentId"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "paymentId is required in openPaymentScreen method", details: nil)); return }
            
            guard let customerId: String = arguments["customerId"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "customerId is required in openPaymentScreen method", details: nil)); return }
            
            guard  let email: String = arguments["email"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "email is required in openPaymentScreen method", details: nil)); return }
            
            guard  let lang: String = arguments["lang"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "lang is required in openPaymentScreen method", details: nil)); return }
            
            guard let orderId: String = arguments["orderId"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "orderId is required in openPaymentScreen method", details: nil)); return }
            
            guard let title: String = arguments["title"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "title is required in openPaymentScreen method", details: nil)); return }
            
            guard let amount: NSNumber = arguments["amount"] as? NSNumber else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "amount is required in openPaymentScreen method", details: nil)); return }
            
            guard let terminalKey: String = arguments["terminalKey"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "terminalKey is required in openPaymentScreen method", details: nil)); return }
            
            guard let publicKey: String = arguments["publicKey"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "publicKey is required in openPaymentScreen method", details: nil)); return }
            
            
            let sdkConfiguration = getSDKConfiguration(terminalKey:  terminalKey, publicKey: publicKey)
            
            delegate.openPaymentScreen(
                tinkoffOrderOptions: TinkoffOrderOptions(orderId: orderId, amount: amount, title: title, paymentId: paymentId),
                tinkoffCustomerOptions: TinkoffCustomerOptions(customerId: customerId, email: email, lang: lang),
                sdkConfiguration: sdkConfiguration,
                paymentId: paymentId,
                result: { (response) -> Void in
                    result([
                        "status": response.status.rawValue,
                        "error": (response.error as NSError?)?.description,
                        "cardId": response.cardId as Any?,
                        "paymentId": response.paymentId
                    ])
                }
            )
        case "openApplePay":
            guard let paymentId: String = arguments["paymentId"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "paymentId is required in openPaymentScreen method", details: nil)); return }
            
            guard let customerId: String = arguments["customerId"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "customerId is required in openPaymentScreen method", details: nil)); return }
            let email: String? = arguments["email"] as? String
            
            guard let orderId: String = arguments["orderId"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "orderId is required in openPaymentScreen method", details: nil)); return }
            guard let title: String = arguments["title"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "title is required in openPaymentScreen method", details: nil)); return }
            guard let amount: NSNumber = arguments["amount"] as? NSNumber else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "amount is required in openPaymentScreen method", details: nil)); return }
            
            guard let merchantIdentifier: String = arguments["merchantIdentifier"] as? String else { result(FlutterError(code: TINKOFF_COMMON_STATUS_FATAL_ERROR, message: "merchantIdentifier is required in openApplePay method", details: nil)); return }
            
            delegate.openApplePay(
                tinkoffOrderOptions: TinkoffOrderOptions(orderId: orderId, amount: amount, title: title, paymentId: paymentId ),
                tinkoffCustomerOptions: TinkoffCustomerOptions(customerId: customerId, email: email),
                tinkoffApplePayOptions: TinkoffApplePayOptions(merchantIdentifier: merchantIdentifier),
                result: { (response) -> Void in
                    result([
                        "status": response.status.rawValue,
                        "error": (response.error as NSError?)?.description,
                        "cardId": response.cardId as Any?,
                        "paymentId": response.paymentId
                    ])
                }
            )
            
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func getSDKConfiguration(
        terminalKey: String,
        publicKey: String
    ) -> AcquiringSdkConfiguration {
        let credential = AcquiringSdkCredential(
            terminalKey: terminalKey, publicKey: publicKey
        )
        let server = getSDKEnvironment()
        let configuration = AcquiringSdkConfiguration(credential: credential, server: server)
        configuration.logger =
        AcquiringLoggerDefault()
        return configuration
    }
    
    func getSDKEnvironment() -> AcquiringSdkEnvironment {
        return .prod
    }
    
    
}
