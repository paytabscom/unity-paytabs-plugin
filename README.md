
# unity-paytabs-plugin
![Version](https://img.shields.io/badge/Unity%20PayTabs%20Plugin-v1.0.0_beta-green)

Unity PayTabs Plugin is a wrapper for the native PayTabs Android and iOS SDKs, It helps you integrate your Unity3D project with PayTabs.

Plugin Support:

* [x] iOS
* [x] Android


## Features

* The plugin offers a ready-made card payment screen.
* **Card Scanner** for quick & easy entry of card details (iOS 13.0+). 
* Handle the missing required billing and shipping details.
* Logo, colors, and fonts become easy to be customized.
* **Apple Pay** and **SamsunPay** are supported.
* Supporting dark mode.
* Alternative payment methods supported.

## Installation

1. Download the package from [here][packageurl].
	
2. Import the `paymentplugin` package into your project **Assets-> Import Package -> Custom Package**. 

<img src="https://user-images.githubusercontent.com/13621658/124355416-44195e00-dc11-11eb-958c-42593c74e01a.png" width="370">

## Usage


### Pay with Card

1. Configure the billing & shipping info, the shipping info is optional

```cs
PaymentBillingDetails billingDetails = new PaymentBillingDetails
    {
        name = "M Adly",
        phone = "+973111111111",
        countryCode = "AE",
        city = "Dubai",
        email = "m@m.com",
        zipCode = "12345",
        state = "Dubai",
        addressLine = "Address line"
    };
                                                      
```

2. Create an object of `PaymentConfiguration ` and fill it with your credentials and payment details.

```cs
PaymentConfiguration configuration = new PaymentConfiguration
    {
        profileID = "*Profile ID*",
        serverKey = "*Server Key*",
        clientKey = "*Client Key*",
        cartID = "1234567",
        amount = 12,
        currency = "AED",
        merchantCountryCode = "AE",
        cartDescription = "Buy 2 flowers",
        screenTitle = "Store Name"
    };
```

Options to show billing and shipping ifno

```cs
	configuration.showBillingInfo = true
	configuration.showShippingInfo = true
```

3. Add the action function to handle payment details & events callbacks.
 
```cs
 private void callbackHandler(Dictionary<string, object> result) {
        if ((string)result["status"] == "success")
        {
            // Handle transaction details here.
            Dictionary<string, object> transactionDetails = (Dictionary<string, object>)result["data"];
            Dictionary<string, object> paymentResult = (Dictionary<string, object>)transactionDetails["paymentResult"];
            Debug.Log(paymentResult["responseCode"]);
            Debug.Log(paymentResult["responseMessage"]);
            Debug.Log(paymentResult["transactionTime"]);
            if (transactionDetails.ContainsKey("token"))
            {
	            Debug.Log(transactionDetails["token"]);
	            Debug.Log(transactionDetails["transactionReference"]);
            }
            
        }
        else if ((string)result["status"] == "error")
        {
            // Handle error here the code and message.
            Debug.Log(result["message"]);
        }
        else if ((string)result["status"] == "event")
        {
            // Handle events here.
            Debug.Log(result["message"]);
        }

    }
```
 
4. Start the payment by calling `StartCardPayment` method
```cs
	PaymentPlugin.StartCardPayment(configuration, callbackHandler);     
```

### Pay with Apple Pay

1. Follow the guide [Steps to configure Apple Pay][applepayguide] to learn how to configure ApplePay with PayTabs.

2. Do the steps 1, 2, and 3 from **Pay with Card**, although you can ignore Billing & Shipping details and Apple Pay will handle it, you must add the **merchant name** and **merchant Apple Pay indentifier** to the configuration.

```cs
    configuration.merchantName = "Flowers Store"
    configuration.merchantApplePayIndentifier = "merchant.com.bundleID"
```

3. To simplify ApplePay validation on all user's billing info, pass **simplifyApplePayValidation** parameter in the configuration with **true**.

```cs
configuration.simplifyApplePayValidation = true
```

4. Call `StartApplePayPayment` to start the payment.

```cs
PaymentPlugin.StartApplePayPayment(configuration, callbackHandler);
```

### Pay with Samsung Pay

Pass Samsung Pay token to the configuration and call `startCardPayment`

```cs
configuration.samsungToken = "token"
```

### Pay with Alternative Payment Methods

It becomes easy to integrate with other payment methods in your region like STCPay, OmanNet, KNet, Valu, Fawry, UnionPay, and Meeza, to serve a large sector of customers.

1. Do the steps 1, 2, and 3 from **Pay with Card**.

2. Choose one or more of the payment methods you want to support.

```cs
configuration.alternativePaymentMethods = new string[] { PaymentAlternativePaymentMethod.stcPay, PaymentAlternativePaymentMethod.fawry };
```

3. Start payment by calling `StartAlternativePaymentMethod` method and handle the transaction details 

```cs
PaymentPlugin.StartAlternativePaymentMethod(configuration, callbackHandler);     
```

## Constants

The following constants will help you in customizing your configuration.

* Tokenise types

 The default type is none

```cs
public class PaymentTokeniseType {
    public static string none = "none", 
    merchantMandatory = "merchantMandatory",
    userMandatory = "userMandatory",
    userOptinoal = "userOptional";
};
```

```javascript
configuration.tokeniseType = PaymentTokeniseType.userOptinoal
```

* Transaction classes

 The default class is ecom

```cs
public class PaymentTransactionClass {
    public static string ecom = "ecom", 
    recurring = "recur";
};
```

```cs
configuration.transactionClass = PaymentTransactionClass.recurring
```

* Token formats

The default format is hex32

```cas
public class PaymentTokeniseFromat {
    public static string none = "1", 
    hex32 = "2", 
    alphaNum20 = "3", 
    digit22 = "3", 
    digit16 = "5", 
    alphaNum32 = "6";
};
```
```cs
configuration.tokenFormat = PaymentTokeniseFromat.hex32
```

* Transaction types

The default type is sale

```cs
public class PaymentTransactionType {
    public static string sale = "sale", 
    authorize =  "auth";
};
```

```cs
configuration.transactionType = PaymentTransactionType.sale
```

* Alternative payment methods

```cs
public class PaymentAlternativePaymentMethod {
    public static string unionPay = "unionpay", 
    stcPay = "stcpay", 
    valu =  "valu", 
    meezaQR =  "meezaqr", 
    omannet =  "omannet", 
    knetCredit =  "knetcredit", 
    knetDebit =  "knetdebit", 
    fawry =  "fawry";
}
```

```javascript
configuration.alternativePaymentMethods = new string[] { PaymentAlternativePaymentMethod.stcPay, ...}
```

## Show/Hide Card Scanner

```cs
configuration.hideCardScanner = true
```

## Theme Customization

![UI guide](https://user-images.githubusercontent.com/13621658/109432213-d7981380-7a12-11eb-9224-c8fc12b0024d.jpg)

### iOS
Create an instance from the class `PaymentTheme` and configure its fonts and colors.

```cs
PaymentTheme theme = new PaymentTheme
    {
        backgroundColor= "4853b8" // color hex value
        primaryColor = "956596"
    };
    
configuration.theme =theme;
```
### Android
Use the following guide to customize the colors, font, and logo by configuring the theme and pass it to the payment configuration.

- Override strings:
To override string you can find the keys with the default values here
[english][english], [arabic][arabic].

````xml
<resourse>
  // to override colors
     <color name="payment_sdk_primary_color">#5C13DF</color>
     <color name="payment_sdk_secondary_color">#FFC107</color>
     <color name="payment_sdk_primary_font_color">#111112</color>
     <color name="payment_sdk_secondary_font_color">#6D6C70</color>
     <color name="payment_sdk_separators_color">#FFC107</color>
     <color name="payment_sdk_stroke_color">#673AB7</color>
     <color name="payment_sdk_button_text_color">#FFF</color>
     <color name="payment_sdk_title_text_color">#FFF</color>
     <color name="payment_sdk_button_background_color">#3F51B5</color>
     <color name="payment_sdk_background_color">#F9FAFD</color>
     <color name="payment_sdk_card_background_color">#F9FAFD</color> 
   
  // to override dimens
     <dimen name="payment_sdk_primary_font_size">17sp</dimen>
     <dimen name="payment_sdk_secondary_font_size">15sp</dimen>
     <dimen name="payment_sdk_separator_thickness">1dp</dimen>
     <dimen name="payment_sdk_stroke_thickness">.5dp</dimen>
     <dimen name="payment_sdk_input_corner_radius">8dp</dimen>
     <dimen name="payment_sdk_button_corner_radius">8dp</dimen>
     
</resourse>
````

## Demo application

Download our package source and run the demo attached with it.

<img src="https://user-images.githubusercontent.com/13621658/109432386-905e5280-7a13-11eb-847c-63f2c554e2d1.png" width="370">

## License

See [LICENSE][license].

## Paytabs

[Support][1] | [Terms of Use][2] | [Privacy Policy][3]

 [1]: https://www.paytabs.com/en/support/
 [2]: https://www.paytabs.com/en/terms-of-use/
 [3]: https://www.paytabs.com/en/privacy-policy/
 [license]: https://github.com/paytabscom/unity-paytabs-plugin/blob/main/LICENSE
 [applepayguide]: https://github.com/paytabscom/unity-paytabs-plugin/blob/main/ApplePayConfiguration.md
 [packageurl]: https://github.com/paytabscom/unity-paytabs-plugin/blob/main/paymentplugin.unitypackage
 [english]: https://github.com/paytabscom/paytabs-android-library-sample/blob/master/res/strings.xml
 [arabic]: https://github.com/paytabscom/paytabs-android-library-sample/blob/master/res/strings-ar.xml

