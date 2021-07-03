using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class AndroidPaymentPlugin
{
    private const string JAVA_OBJECT_NAME = "com.paytabs.paymentplugin.PaymentPlugin";
    private static AndroidJavaObject androidJavaNativePaymentPlugin;
    
    public static void StartCardPayment(string paymentDetails) {
        androidJavaNativePaymentPlugin = new AndroidJavaObject(JAVA_OBJECT_NAME, getCurrentActivity());
        androidJavaNativePaymentPlugin.Call("startCardPayment", paymentDetails);
    }
    
    public static void StartAlternativePaymentMethod(string paymentDetails) {
        androidJavaNativePaymentPlugin = new AndroidJavaObject(JAVA_OBJECT_NAME, getCurrentActivity());
        androidJavaNativePaymentPlugin.Call("startAlternativePaymentMethod", paymentDetails);
    }

    private static AndroidJavaObject getCurrentActivity() {
        var androidJavaUnityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        var currentActivity = androidJavaUnityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
        return currentActivity;
    }
}
