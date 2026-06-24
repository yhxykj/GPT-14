//
//  ZKPayment.h
//  Bulter
//
//  Created by JJK on 2024/4/15.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ZKPaymentSuccess = 0,       // 购买成功
    ZKPaymentFailed = 1,        // 购买失败
    ZKPaymentCancel = 2,        // 取消购买
    ZKPaymentVerFailed = 3,     // 订单校验失败
    ZKPaymentVerSuccess = 4,    // 订单校验成功
    ZKPaymentNotArrow = 5,      // 不允许内购
}ZKPaymentStatusType;

typedef void (^PaymentCompletionHandle)(ZKPaymentStatusType type, NSData *data, NSString *transaction_id);

@interface ZKPayment : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>
{
    PaymentCompletionHandle paymentCompleteHandle;
}
@property (nonatomic, copy) NSString *transaction_id;
@property (nonatomic, copy) NSString *currentPurchasedID;

+ (instancetype)sharedTool;

//恢复购买
- (void)zk_resumptionOfPurchase;

- (void)zk_applyPayIosId:(NSString *)iosId completeHandle:(PaymentCompletionHandle)handle;

@end

NS_ASSUME_NONNULL_END
