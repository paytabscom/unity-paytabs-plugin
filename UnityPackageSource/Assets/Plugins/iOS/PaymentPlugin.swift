//
//  PayTabsPlugin.swift
//  UnityFramework
//
//  Created by Mohamed Adly on 17/06/2021.
//

import PaymentSDK

@objc public class PaymentPlugin: NSObject {
    
    @objc public static var shared = PaymentPlugin()
    private let paymentDelegateHandler = PaymentDelegateHandler()
    
    @objc public func startCardPayment(viewController: UIViewController, paymentDetailsJSON: String, paymentResultCompletion: ((String)-> Void)?) {
        paymentDelegateHandler.paymentResultCompletion = paymentResultCompletion
        
        if let configuration = convertJSONToConfiguration(json: paymentDetailsJSON) {
            PaymentManager.startCardPayment(on: viewController, configuration: configuration, delegate: paymentDelegateHandler)
        }
    }

    @objc public func startAlternativePaymentMethod(viewController: UIViewController, paymentDetailsJSON: String, paymentResultCompletion: ((String)-> Void)?) {
        paymentDelegateHandler.paymentResultCompletion = paymentResultCompletion
        
        if let configuration = convertJSONToConfiguration(json: paymentDetailsJSON) {
            PaymentManager.startAlternativePaymentMethod(on: viewController, configuration: configuration, delegate: paymentDelegateHandler)
        }
    }

    @objc public func startApplePayPayment(viewController: UIViewController, paymentDetailsJSON: String, paymentResultCompletion: ((String)-> Void)?) {
        paymentDelegateHandler.paymentResultCompletion = paymentResultCompletion
        
        if let configuration = convertJSONToConfiguration(json: paymentDetailsJSON) {
            PaymentManager.startApplePayPayment(on: viewController, configuration: configuration, delegate: paymentDelegateHandler)
        }
    }
    
    private func convertJSONToConfiguration(json: String) -> PaymentSDKConfiguration? {
        let data = Data(json.utf8)
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            return generateConfiguration(dictionary: dictionary)
        } catch {
            return nil
        }
    }
    
    private func generateConfiguration(dictionary: [String: Any]) -> PaymentSDKConfiguration {
            let configuration = PaymentSDKConfiguration()
            configuration.profileID = dictionary["profileID"] as? String ?? ""
            configuration.serverKey = dictionary["serverKey"] as? String ?? ""
            configuration.clientKey = dictionary["clientKey"] as? String ?? ""
            configuration.cartID = dictionary["cartID"] as? String ?? ""
            configuration.cartDescription = dictionary["cartDescription"] as? String ?? ""
            configuration.amount = dictionary["amount"] as? Double ?? 0.0
            configuration.currency =  dictionary["currency"] as? String ?? ""
            configuration.merchantName = dictionary["merchantName"] as? String ?? ""
            configuration.screenTitle = dictionary["screenTitle"] as? String
            configuration.merchantCountryCode = dictionary["merchantCountryCode"] as? String ?? ""
            configuration.merchantIdentifier = dictionary["merchantApplePayIndentifier"] as? String
            configuration.simplifyApplePayValidation = dictionary["simplifyApplePayValidation"] as? Bool ?? false
            configuration.languageCode = dictionary["languageCode"] as? String
            configuration.forceShippingInfo = dictionary["forceShippingInfo"] as? Bool ?? false
            configuration.showBillingInfo = dictionary["showBillingInfo"] as? Bool ?? false
            configuration.showShippingInfo = dictionary["showShippingInfo"] as? Bool ?? false
            configuration.token = dictionary["token"] as? String
            configuration.transactionReference = dictionary["transactionReference"] as? String
            configuration.hideCardScanner = dictionary["hideCardScanner"] as? Bool ?? false
            configuration.serverIP = dictionary["serverIP"] as? String
            if let tokeniseType = dictionary["tokeniseType"] as? String,
               let type = mapTokeiseType(tokeniseType: tokeniseType) {
                configuration.tokeniseType = type
            }
            if let tokenFormat = dictionary["tokenFormat"] as? String,
               let type = TokenFormat.getType(type: tokenFormat) {
                configuration.tokenFormat = type
            }
            
            if let transactionType = dictionary["transactionType"] as? String {
                configuration.transactionType = TransactionType.init(rawValue: transactionType) ?? .sale
            }
            
            if let themeDictionary = dictionary["theme"] as? [String: Any],
               let theme = generateTheme(dictionary: themeDictionary) {
                configuration.theme = theme
            } else {
                configuration.theme = .default
            }
            if let billingDictionary = dictionary["billingDetails"] as?  [String: Any] {
                configuration.billingDetails = generateBillingDetails(dictionary: billingDictionary)
            }
            if let shippingDictionary = dictionary["shippingDetails"] as?  [String: Any] {
                configuration.shippingDetails = generateShippingDetails(dictionary: shippingDictionary)
            }
            if let alternativePaymentMethods = dictionary["alternativePaymentMethods"] as? [String] {
                configuration.alternativePaymentMethods = generateAlternativePaymentMethods(apmsArray: alternativePaymentMethods)
            }
            return configuration
        }
        
        
        private func generateBillingDetails(dictionary: [String: Any]) -> PaymentSDKBillingDetails? {
            let billingDetails = PaymentSDKBillingDetails()
            billingDetails.name = dictionary["name"] as? String ?? ""
            billingDetails.phone = dictionary["phone"] as? String ?? ""
            billingDetails.email = dictionary["email"] as? String ?? ""
            billingDetails.addressLine = dictionary["addressLine"] as? String ?? ""
            billingDetails.countryCode = dictionary["countryCode"] as? String ?? ""
            billingDetails.city = dictionary["city"] as? String ?? ""
            billingDetails.state = dictionary["state"] as? String ?? ""
            billingDetails.zip = dictionary["zipCode"] as? String ?? ""
            return billingDetails
        }
    
        private func generateShippingDetails(dictionary: [String: Any]) -> PaymentSDKShippingDetails? {
            let shippingDetails = PaymentSDKShippingDetails()
            shippingDetails.name = dictionary["name"] as? String ?? ""
            shippingDetails.phone = dictionary["phone"] as? String ?? ""
            shippingDetails.email = dictionary["email"] as? String ?? ""
            shippingDetails.addressLine = dictionary["addressLine"] as? String ?? ""
            shippingDetails.countryCode = dictionary["countryCode"] as? String ?? ""
            shippingDetails.city = dictionary["city"] as? String ?? ""
            shippingDetails.state = dictionary["state"] as? String ?? ""
            shippingDetails.zip = dictionary["zipCode"] as? String ?? ""
            return shippingDetails
        }
        
        private func generateTheme(dictionary: [String: Any]) -> PaymentSDKTheme? {
            let theme = PaymentSDKTheme.default
            if let imageName = dictionary["logoImage"] as? String, !imageName.isEmpty {
                theme.logoImage = UIImage(named: imageName)
            }
            if let colorHex = dictionary["primaryColor"] as? String, !colorHex.isEmpty {
                theme.primaryColor = UIColor(hex: colorHex)
            }
            if let colorHex = dictionary["primaryFontColor"] as? String, !colorHex.isEmpty {
                theme.primaryFontColor = UIColor(hex: colorHex)
            }
            if let fontName = dictionary["primaryFont"] as? String, !fontName.isEmpty {
                theme.primaryFont = UIFont.init(name: fontName, size: 16)
            }
            if let colorHex = dictionary["secondaryColor"] as? String, !colorHex.isEmpty {
                theme.secondaryColor = UIColor(hex: colorHex)
            }
            if let colorHex = dictionary["secondaryFontColor"] as? String, !colorHex.isEmpty {
                theme.secondaryFontColor = UIColor(hex: colorHex)
            }
            if let fontName = dictionary["secondaryFont"] as? String, !fontName.isEmpty {
                theme.secondaryFont = UIFont.init(name: fontName, size: 16)
            }
            if let colorHex = dictionary["strokeColor"] as? String, !colorHex.isEmpty {
                theme.strokeColor = UIColor(hex: colorHex)
            }
            if let value = dictionary["strokeThinckness"] as? CGFloat, value != 0.0 {
                theme.strokeThinckness = value
            }
            if let value = dictionary["inputsCornerRadius"] as? CGFloat, value != 0.0 {
                theme.inputsCornerRadius = value
            }
            if let colorHex = dictionary["buttonColor"] as? String, !colorHex.isEmpty {
                theme.buttonColor = UIColor(hex: colorHex)
            }
            if let colorHex = dictionary["buttonFontColor"] as? String, !colorHex.isEmpty {
                theme.buttonFontColor = UIColor(hex: colorHex)
            }
            if let fontName = dictionary["buttonFont"] as? String, !fontName.isEmpty {
                theme.buttonFont = UIFont.init(name: fontName, size: 16)
            }
            if let colorHex = dictionary["titleFontColor"] as? String, !colorHex.isEmpty {
                theme.titleFontColor = UIColor(hex: colorHex)
            }
            if let fontName = dictionary["titleFont"] as? String, !fontName.isEmpty {
                theme.titleFont = UIFont.init(name: fontName, size: 16)
            }
            if let colorHex = dictionary["backgroundColor"] as? String, !colorHex.isEmpty {
                theme.backgroundColor = UIColor(hex: colorHex)
            }
            if let colorHex = dictionary["placeholderColor"] as? String, !colorHex.isEmpty {
                theme.placeholderColor = UIColor(hex: colorHex)
            }
            return theme
        }
        
        private func generateAlternativePaymentMethods(apmsArray: [String]) -> [AlternativePaymentMethod] {
            var apms = [AlternativePaymentMethod]()
            for apmValue in apmsArray {
                if let apm = AlternativePaymentMethod.init(rawValue: apmValue) {
                    apms.append(apm)
                }
            }
            return apms
        }
        
        // to be fixed in next versions
        private func mapTokeiseType(tokeniseType: String) -> TokeniseType? {
            var type = 0
            switch tokeniseType {
            case "userOptional":
                type = 3
            case "userMandatory":
                type = 2
            case "merchantMandatory":
                type = 1
            default:
                break
            }
            return TokeniseType.getType(type: type)
        }
}

class PaymentDelegateHandler: PaymentManagerDelegate {
    
    private struct Response: Codable {
        let code: Int
        let message: String
        let status: String
        let data: PaymentSDKTransactionDetails?
    }
    
    public var paymentResultCompletion: ((String)-> Void)?
    private func sendPluginResult(code: Int, message: String, status: String, transactionDetails: PaymentSDKTransactionDetails? = nil) {
        let response = Response(code: code, message: message, status: status, data: transactionDetails)
        if let paymentResultCompletion = paymentResultCompletion, let responseData = try? JSONEncoder().encode(response) {
            paymentResultCompletion(String(data: responseData, encoding: .utf8) ?? "")
        }
    }
    
    func paymentManager(didFinishTransaction transactionDetails: PaymentSDKTransactionDetails?, error: Error?) {
        if let error = error {
            return sendPluginResult(code: (error as NSError).code,
                                    message: error.localizedDescription,
                                    status: "error")
        }
        sendPluginResult(code: 200,
                         message: "",
                         status: "success",
                         transactionDetails: transactionDetails)
    }
    
    func paymentManager(didCancelPayment error: Error?) {
        sendPluginResult(code: 0, message: "Cancelled", status: "event")
    }
    
}
