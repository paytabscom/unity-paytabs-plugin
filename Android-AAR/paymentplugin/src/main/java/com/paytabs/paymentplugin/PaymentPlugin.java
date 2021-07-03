package com.paytabs.paymentplugin;

import android.app.Activity;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.payment.paymentsdk.PaymentSdkActivity;
import com.payment.paymentsdk.PaymentSdkConfigBuilder;
import com.payment.paymentsdk.integrationmodels.PaymentSdkApms;
import com.payment.paymentsdk.integrationmodels.PaymentSdkBillingDetails;
import com.payment.paymentsdk.integrationmodels.PaymentSdkConfigurationDetails;
import com.payment.paymentsdk.integrationmodels.PaymentSdkError;
import com.payment.paymentsdk.integrationmodels.PaymentSdkLanguageCode;
import com.payment.paymentsdk.integrationmodels.PaymentSdkShippingDetails;
import com.payment.paymentsdk.integrationmodels.PaymentSdkTokenFormat;
import com.payment.paymentsdk.integrationmodels.PaymentSdkTokenise;
import com.payment.paymentsdk.integrationmodels.PaymentSdkTransactionDetails;
import com.payment.paymentsdk.integrationmodels.PaymentSdkTransactionType;
import com.payment.paymentsdk.sharedclasses.interfaces.CallbackPaymentInterface;
import com.unity3d.player.UnityPlayer;

import static com.payment.paymentsdk.integrationmodels.PaymentSdkApmsKt.createPaymentSdkApms;
import static com.payment.paymentsdk.integrationmodels.PaymentSdkLanguageCodeKt.createPaymentSdkLanguageCode;
import static com.payment.paymentsdk.integrationmodels.PaymentSdkTokenFormatKt.createPaymentSdkTokenFormat;
import static com.payment.paymentsdk.integrationmodels.PaymentSdkTokeniseKt.createPaymentSdkTokenise;
import static com.payment.paymentsdk.integrationmodels.PaymentSdkTransactionTypeKt.createPaymentSdkTransactionType;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;


public class PaymentPlugin implements CallbackPaymentInterface {
    private Activity currentActivity;
    private static final String GAME_OBJECT_NAME = "PaymentPluginBridge";

    public PaymentPlugin(Activity activity) {
        this.currentActivity = activity;
    }

    public void startCardPayment(final String arguments) {
        try {
            JSONObject paymentDetails = new JSONObject(arguments);
            PaymentSdkConfigurationDetails configData = createConfiguration(paymentDetails);
            String samsungToken = paymentDetails.optString("samsungToken");
            if (samsungToken != null && samsungToken.length() > 0)
                PaymentSdkActivity.startSamsungPayment(currentActivity, configData, samsungToken, this);
            else
                PaymentSdkActivity.startCardPayment(currentActivity, configData, this);
        } catch (Exception e) {
            Log.e("startCardPayment", e.getMessage());
        }
    }

    public void startAlternativePaymentMethod(final String arguments) {
        try {
            JSONObject paymentDetails = new JSONObject(arguments);
            PaymentSdkConfigurationDetails configData = createConfiguration(paymentDetails);
            PaymentSdkActivity.startAlternativePaymentMethods(currentActivity, configData, this);
        } catch (Exception e) {
            Log.e("startAPMstMethod", e.getMessage());
        }
    }

    private PaymentSdkConfigurationDetails createConfiguration(JSONObject paymentDetails) {
        String profileId = paymentDetails.optString("profileID");
        String serverKey = paymentDetails.optString("serverKey");
        String clientKey = paymentDetails.optString("clientKey");
        PaymentSdkLanguageCode locale = createPaymentSdkLanguageCode(paymentDetails.optString("languageCode"));
        String screenTitle = paymentDetails.optString("screenTitle");
        String orderId = paymentDetails.optString("cartID");
        String cartDesc = paymentDetails.optString("cartDescription");
        String currency = paymentDetails.optString("currency");
        String token = paymentDetails.optString("token");
        String transRef = paymentDetails.optString("transactionReference");
        double amount = paymentDetails.optDouble("amount");
        PaymentSdkTokenise tokeniseType = createPaymentSdkTokenise(paymentDetails.optString("tokeniseType"));
        PaymentSdkTokenFormat tokenFormat = createPaymentSdkTokenFormat(paymentDetails.optString("tokenFormat"));
        PaymentSdkTransactionType transactionType = createPaymentSdkTransactionType(paymentDetails.optString("transactionType"));

        JSONObject billingDetails = paymentDetails.optJSONObject("billingDetails");
        PaymentSdkBillingDetails billingData = null;
        if(billingDetails != null) {
            billingData = new PaymentSdkBillingDetails(
                    billingDetails.optString("city"),
                    billingDetails.optString("countryCode"),
                    billingDetails.optString("email"),
                    billingDetails.optString("name"),
                    billingDetails.optString("phone"), billingDetails.optString("state"),
                    billingDetails.optString("addressLine"), billingDetails.optString("zipCode")
            );
        }
        JSONObject shippingDetails = paymentDetails.optJSONObject("shippingDetails");
        PaymentSdkShippingDetails shippingData = null;
        if(shippingDetails != null ) {
            shippingData = new PaymentSdkShippingDetails(
                    shippingDetails.optString("city"),
                    shippingDetails.optString("countryCode"),
                    shippingDetails.optString("email"),
                    shippingDetails.optString("name"),
                    shippingDetails.optString("phone"), shippingDetails.optString("state"),
                    shippingDetails.optString("addressLine"), shippingDetails.optString("zipCode")
            );
        }
        JSONArray apmsJSONArray = paymentDetails.optJSONArray("alternativePaymentMethods");
        ArrayList<PaymentSdkApms> apmsList = new ArrayList<PaymentSdkApms>();
        if (apmsJSONArray != null) {
            apmsList =  createAPMs(apmsJSONArray);
        }
        PaymentSdkConfigurationDetails configData = new PaymentSdkConfigBuilder(
                profileId, serverKey, clientKey, amount, currency)
                .setCartDescription(cartDesc)
                .setLanguageCode(locale)
                .setBillingData(billingData)
                .setMerchantCountryCode(paymentDetails.optString("merchantCountryCode"))
                .setShippingData(shippingData)
                .setCartId(orderId)
                .setTokenise(tokeniseType, tokenFormat)
                .setTokenisationData(token, transRef)
                .hideCardScanner(paymentDetails.optBoolean("hideCardScanner"))
                .showBillingInfo(paymentDetails.optBoolean("showBillingInfo"))
                .showShippingInfo(paymentDetails.optBoolean("showShippingInfo"))
                .forceShippingInfo(paymentDetails.optBoolean("forceShippingInfo"))
                .setScreenTitle(screenTitle)
                .setAlternativePaymentMethods(apmsList)
                .setTransactionType(transactionType)
                .build();

        return configData;
    }

    private ArrayList<PaymentSdkApms> createAPMs(JSONArray apmsJSONArray) {
        ArrayList<PaymentSdkApms> apmsList = new ArrayList<PaymentSdkApms>();
        for (int i = 0; i < apmsJSONArray.length(); i++) {
            String apmString = apmsJSONArray.optString(i);
            PaymentSdkApms apm = createPaymentSdkApms(apmString);
            apmsList.add(apm);
        }
        return apmsList;
    }

    private void sendResponse(int code, String msg, String status, PaymentSdkTransactionDetails data) {
        JsonObject jsonObject = new JsonObject();
        if (data != null) {
            String detailsString = new Gson().toJson(data);
            JsonObject transactionDetails = new Gson().fromJson(detailsString, JsonObject.class); //parser.parse(detailsString).getAsJsonObject();
            jsonObject.add("data", transactionDetails);
        }
        jsonObject.addProperty("code", code);
        jsonObject.addProperty("message", msg);
        jsonObject.addProperty("status", status);
        String jsonString = new Gson().toJson(jsonObject);
        UnityPlayer.UnitySendMessage(GAME_OBJECT_NAME, "HandlePaymentResult", jsonString);
    }

    @Override
    public void onError(@NotNull PaymentSdkError paymentSdkError) {
        if (paymentSdkError.getCode() != null)
            sendResponse(paymentSdkError.getCode(), paymentSdkError.getMsg(), "error", null);
        else
            sendResponse(0, paymentSdkError.getMsg(), "error", null);
    }

    @Override
    public void onPaymentCancel() {
        sendResponse(0, "Cancelled", "event", null);
    }

    @Override
    public void onPaymentFinish(@NotNull PaymentSdkTransactionDetails paymentSdkTransactionDetails) {
        sendResponse(200, "success", "success", paymentSdkTransactionDetails);
    }
}