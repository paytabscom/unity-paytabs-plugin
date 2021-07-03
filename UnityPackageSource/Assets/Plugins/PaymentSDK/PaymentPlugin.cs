using UnityEngine;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public static class PaymentPlugin
{
    private const string GAME_OBJECT_NAME = "PaymentPluginBridge";
    private static GameObject gameObject;
    private static System.Action<Dictionary<string, object>> action;

#if UNITY_IOS
    [DllImport("__Internal")]
    private static extern void _StartCardPayment(string paymentDetailsJSON);
    public static void StartCardPayment(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action) {
        PaymentPlugin.action = action;
        _StartCardPayment(configuration.toJSON());
    }

    [DllImport("__Internal")]
    private static extern void _StartAlternativePaymentMethod(string paymentDetailsJSON);
    public static void StartAlternativePaymentMethod(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action) {
        PaymentPlugin.action = action;
        _StartAlternativePaymentMethod(configuration.toJSON());
    }

    [DllImport("__Internal")]
    private static extern void _StartApplePayPayment(string paymentDetailsJSON);
    public static void StartApplePayPayment(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action)
    {
        PaymentPlugin.action = action;
        _StartApplePayPayment(configuration.toJSON());
    }

#elif UNITY_ANDROID

    public static void StartCardPayment(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action) {
        PaymentPlugin.action = action;
        AndroidPaymentPlugin.StartCardPayment(configuration.toJSON());
    }

    public static void StartAlternativePaymentMethod(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action) {
        PaymentPlugin.action = action;
        AndroidPaymentPlugin.StartAlternativePaymentMethod(configuration.toJSON());
    }
#else
    public static void StartCardPayment(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action) {
        Debug.Log("No Supported platform");
    }

    public static void StartAlternativePaymentMethod(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action) {
        Debug.Log("No Supported platform");
    }
    public static void StartApplePayPayment(PaymentConfiguration configuration, System.Action<Dictionary<string, object>> action)
    {
        Debug.Log("No Supported platform");
    }
#endif

    static PaymentPlugin() {
        gameObject = new GameObject();
        gameObject.name = GAME_OBJECT_NAME;
        gameObject.AddComponent<PaymentPluginCallbackHandler>();
        UnityEngine.Object.DontDestroyOnLoad(gameObject);
    }

    private class PaymentPluginCallbackHandler : MonoBehaviour
    {
        private void HandlePaymentResult(string result)
        {
            Debug.Log(result);
            if (action != null) {
                Dictionary<string, object> resultDictionary = UnityJSON.JSON.Deserialize<Dictionary<string, object>>(result);
                action(resultDictionary);
            }
        }
    }
}
