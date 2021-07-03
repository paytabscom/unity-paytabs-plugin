using UnityEngine;
using System.Collections.Generic;
using UnityJSON;

[System.Serializable]
public class PaymentConfiguration
{
    public PaymentBillingDetails billingDetails = null;
    public PaymentShippingDetails shippingDetails = null;
    public string profileID;
    public string serverKey;
    public string clientKey;
    public double amount = 0.0;
    public string merchantCountryCode;
    public string merchantName;
    public string transactionReference;
    public string token;
    public string currency;
    public string cartDescription;
    public string screenTitle;
    public string cartID;
    public string samsungToken;
    public bool showBillingInfo = false;
    public bool showShippingInfo = false;
    public bool forceShippingInfo = false;
    public string merchantApplePayIndentifier;
    public bool simplifyApplePayValidation = false;
    public bool hideCardScanner = false;
    public string tokenFormat;
    public string tokeniseType;
    public string transactionClass;
    public string transactionType;
    public PaymentTheme theme;
    public string[] alternativePaymentMethods = null;
                    
    public string toJSON()
    {
        return JSON.ToJSONString(this);
    }

}
