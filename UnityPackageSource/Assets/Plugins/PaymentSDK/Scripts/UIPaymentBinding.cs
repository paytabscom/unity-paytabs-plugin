using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

public class UIPaymentBinding : MonoBehaviour
{
    private string profileID = "*Profile Id*";
    private string serverKey = "*Server Key*";
    private string clientKey = "*Client key*";

    [SerializeField]
    GameObject applePayButton;

    [SerializeField]
    GameObject resultPanel;

    [SerializeField]
    Text resultText;

    private void Start()
    {
        #if UNITY_IOS
            applePayButton.SetActive(true);
        #else
            applePayButton.SetActive(false);
        #endif
    }

    private PaymentConfiguration getConfiguration() {
        PaymentConfiguration configuration = new PaymentConfiguration
        {
            profileID = profileID,
            serverKey = serverKey,
            clientKey = clientKey,
            cartID = "1234567",
            amount = 12,
            currency = "AED",
            merchantCountryCode = "AE",
            cartDescription = "Buy 2 flowers",
            screenTitle = "DoKan"
        };

        //PaymentTheme theme = new PaymentTheme
        //{
        //    backgroundColor= "csccc", // color hex value
        //    primaryColor = ""
        //};

        //configuration.theme = theme;
        return configuration;
    }

    private PaymentBillingDetails getBillingDetails() {
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
        return billingDetails;
    }

    public void payWithCardAction() {
        PaymentConfiguration configuration = getConfiguration();
        configuration.billingDetails = getBillingDetails();
        PaymentPlugin.StartCardPayment(configuration, resultHandler);
    }

    public void payWithAPMSAction() {
        PaymentConfiguration configuration = getConfiguration();
        configuration.currency = "SAR";
        configuration.amount = 1000;
        configuration.alternativePaymentMethods = new string[] { PaymentAlternativePaymentMethod.stcPay, PaymentAlternativePaymentMethod.fawry};
        configuration.billingDetails = getBillingDetails();
        PaymentPlugin.StartAlternativePaymentMethod(configuration, resultHandler);
    }

    public void payWithApplePayAction()
    {
#if UNITY_IOS
        PaymentConfiguration configuration = getConfiguration();
        configuration.billingDetails = getBillingDetails();
        configuration.merchantApplePayIndentifier = "merchant.com.bundleid";
        PaymentPlugin.StartApplePayPayment(configuration,resultHandler);
#endif
    }

    private void resultHandler(Dictionary<string, object> result) {
        if ((string)result["status"] == "success")
        {
            // Handle transaction details here.
            Dictionary<string, object> transactionDetails = (Dictionary<string, object>)result["data"];
            Dictionary<string, object> paymentResult = (Dictionary<string, object>)transactionDetails["paymentResult"];
            resultText.text = "ResponseCode: " + paymentResult["responseCode"];
            resultText.text = resultText.text + "\n" + "ResponseMessage: " + paymentResult["responseMessage"];
            resultText.text = resultText.text + "\n" + "TransactionTime: " + paymentResult["transactionTime"];
            resultText.text = resultText.text + "\n" + "TransactionReference: " + transactionDetails["transactionReference"];
            if (transactionDetails.ContainsKey("token"))
            {
                resultText.text = resultText.text + "\n" + "Token: " + transactionDetails["token"];
            }
        }
        else if ((string)result["status"] == "error")
        {
            // Handle error here the code and message.
            resultText.text = (string)result["message"];
        }
        else if ((string)result["status"] == "event")
        {
            // Handle events here.
            resultText.text = (string)result["message"];
        }

        resultPanel.SetActive(true);
    }

    public void closeResultPanel() {
        resultPanel.SetActive(false);
    }
}
