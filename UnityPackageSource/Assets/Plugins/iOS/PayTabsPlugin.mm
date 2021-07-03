#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "UnityFramework/UnityFramework-Swift.h"

char const *GAME_OBJECT = "PaymentPluginBridge";

extern UIViewController *UnityGetGLViewController();

@interface PayTabsPlugin : NSObject

@end

@implementation PayTabsPlugin

+(void)StartCardPaymentWithPaymentJSON:(NSString *)paymentJSON {
    [PaymentPlugin.shared startCardPaymentWithViewController:UnityGetGLViewController() paymentDetailsJSON:paymentJSON paymentResultCompletion:^(NSString * _Nonnull msg) {
        UnitySendMessage(GAME_OBJECT, [@"HandlePaymentResult" UTF8String], [msg UTF8String]);
    }];
}

+(void)StartAlternativePaymentMethodWithPaymentJSON:(NSString *)paymentJSON {
    [PaymentPlugin.shared startAlternativePaymentMethodWithViewController:UnityGetGLViewController() paymentDetailsJSON:paymentJSON paymentResultCompletion:^(NSString * _Nonnull msg) {
        UnitySendMessage(GAME_OBJECT, [@"HandlePaymentResult" UTF8String], [msg UTF8String]);
    }];
}

+(void)StartApplePayPaymentWithPaymentJSON:(NSString *)paymentJSON {
    [PaymentPlugin.shared startApplePayPaymentWithViewController:UnityGetGLViewController() paymentDetailsJSON:paymentJSON paymentResultCompletion:^(NSString * _Nonnull msg) {
        UnitySendMessage(GAME_OBJECT, [@"HandlePaymentResult" UTF8String], [msg UTF8String]);
    }];
}

@end

extern "C"
{
    
    void _StartCardPayment(const char *paymentDetailsJSON) {
        [PayTabsPlugin StartCardPaymentWithPaymentJSON:[NSString stringWithUTF8String:paymentDetailsJSON]];
    }

    void _StartAlternativePaymentMethod(const char *paymentDetailsJSON) {
        [PayTabsPlugin StartAlternativePaymentMethodWithPaymentJSON:[NSString stringWithUTF8String:paymentDetailsJSON]];
    }

    void _StartApplePayPayment(const char *paymentDetailsJSON) {
        [PayTabsPlugin StartApplePayPaymentWithPaymentJSON:[NSString stringWithUTF8String:paymentDetailsJSON]];
    }

}
