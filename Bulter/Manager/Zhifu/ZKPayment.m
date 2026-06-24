//
//  ZKPayment.m
//  Bulter
//
//  Created by JJK on 2024/4/15.
//

#import "ZKPayment.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation ZKPayment

+ (instancetype)sharedTool {
    static ZKPayment *payManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        payManager = [[ZKPayment alloc] init];
    });
    return payManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)zk_resumptionOfPurchase {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [SVProgressHUD showWithStatus:@"订单恢复中，请等待……"];
}

- (void)zk_applyPayIosId:(NSString *)iosId completeHandle:(PaymentCompletionHandle)handle {
    [SVProgressHUD showWithStatus:@"正在购买中"];
    [self removeAllUncompleteTransactionBeforeStartNewTransaction];
    if (!iosId.length) {
        [SVProgressHUD showErrorWithStatus:@"没有对应的商品"];
        return;
    }
    if (iosId) {
        if ([SKPaymentQueue canMakePayments]) {
            self.currentPurchasedID = iosId;
            paymentCompleteHandle = handle;
            
            //从App Store中检索关于指定产品列表的本地化信息
            NSSet *nsset = [NSSet setWithArray:@[iosId]];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
            request.delegate = self;
            [request start];
        }else{
            [self handleActionWithType:ZKPaymentNotArrow data:nil];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先开启应用内付费购买功能。"];
    }
}

- (void)handleActionWithType:(ZKPaymentStatusType)type data:(NSData *)data{
#if DEBUG
    switch (type) {
        case ZKPaymentSuccess:
            NSLog(@"购买成功");
            break;
        case ZKPaymentFailed:
            NSLog(@"购买失败");
            break;
        case ZKPaymentCancel:
            NSLog(@"用户取消购买");
            break;
        case ZKPaymentVerFailed:
            NSLog(@"订单校验失败");
            break;
        case ZKPaymentVerSuccess:
            NSLog(@"订单校验成功");
            break;
        case ZKPaymentNotArrow:
            NSLog(@"不允许程序内付费");
            break;
        default:
            break;
    }
#endif
    [self handleActionWithType:type data:data verifyStatus:YES];
}

- (void)handleActionWithType:(ZKPaymentStatusType)type data:(NSData *)data verifyStatus:(BOOL)status {

    if (type == ZKPaymentSuccess) {
        return;
    }
    if(paymentCompleteHandle && status) {
        paymentCompleteHandle(type,data,self.transaction_id);
    }
    [SVProgressHUD dismiss];
}

//data 转 json 字符串
- (NSString *)toJsonData:(id)theData{
    NSString *jsonStr = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    if (jsonStr.length > 0) {
        return jsonStr;
    }else{
        return nil;
    }
}

#define Sandbox @"https://sandbox.itunes.apple.com/verifyReceipt"
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
 
- (void)verifyPurchaseWithPaymentTransaction:(SKPaymentTransaction *)transaction{

    NSURL *recepitURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:recepitURL];
    

    self.transaction_id = transaction.transactionIdentifier;
    [self toJsonData:receipt];
    if(!receipt){
        
        [self handleActionWithType:ZKPaymentVerFailed data:nil];
        return;
    }
    
    [self handleActionWithType:ZKPaymentSuccess data:receipt];
     
    NSError *error;
    NSDictionary *requestContents;

    requestContents = @{@"receipt-data":[receipt base64EncodedStringWithOptions:0],
                            @"password":@"c6ef6bd8e0db4a3bb708a45abd0405e3"};

    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
     
    if (!requestData) { //交易凭证为空验证失败
        [self handleActionWithType:ZKPaymentVerFailed data:nil];
        return;
    }
    
    NSURL *storeURL = [NSURL URLWithString:AppStore];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:storeRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {

            [self handleActionWithType:ZKPaymentVerFailed data:nil];
        } else {
            NSError *error;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!jsonResponse) {
                
                [self handleActionWithType:ZKPaymentVerFailed data:nil];
            }
            
            self.transaction_id = transaction.transactionIdentifier;
     
            NSString *status = [NSString stringWithFormat:@"%@",jsonResponse[@"status"]];
            if(status && [status isEqualToString:@"0"]){
             
                NSString *productId = transaction.payment.productIdentifier;
                NSLog(@"\n\n===============>> 购买成功ID:%@ <<===============\n\n",productId);
                
                NSArray *pending_renewal_info = jsonResponse[@"pending_renewal_info"];
                NSDictionary *latest_pending_renewal_dic;
                if (pending_renewal_info.count > 0) {
                    latest_pending_renewal_dic = pending_renewal_info[pending_renewal_info.count - 1];
                }

                // 需在添加对象后获得对象数量 不然有极低的可能遇到并发问题 而导致不执行回调
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSArray *latest_receipt_ary = jsonResponse[@"latest_receipt_info"];
                    
                    BOOL invoke = NO;
                    
                    if (latest_receipt_ary.count > 0) {
                        for (NSDictionary *latest_receipt_dic in latest_receipt_ary) {
                            NSUInteger expires_date_ms = [[latest_receipt_dic[@"expires_date_ms"] substringToIndex:10] integerValue];//过期时间
                            NSUInteger nowTime = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] longLongValue];
                            self.transaction_id = [latest_receipt_dic objectForKey:@"transaction_id"];
                            if (expires_date_ms > nowTime) {
                                invoke = YES;
                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",expires_date_ms] forKey:@"expires_date_ms"];
                            }
                        }
                    }
                    NSDictionary *last_dic = [latest_receipt_ary firstObject];
                    self.transaction_id = [last_dic objectForKey:@"transaction_id"];
                    
                    NSString *expires_date_ms = [NSString stringWithFormat:@"%@",[last_dic objectForKey:@"expires_date_ms"]];
                    [[NSUserDefaults standardUserDefaults] setValue:@([expires_date_ms doubleValue]) forKey:@"expires_date_ms"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    NSLog(@"expires_date_ms:------%@",[last_dic objectForKey:@"expires_date_ms"]);
                    //expires_date_ms//会员到期时间戳
                    //purchase_date_ms//会员开通时间戳
                    [self handleActionWithType:ZKPaymentVerSuccess data:receipt verifyStatus:YES];
                });
            } else {
                [self handleActionWithType:ZKPaymentVerFailed data:nil];
            }
            
            NSLog(@"----验证结果 %@",jsonResponse);
        }
    }];
    [task resume];
    // 验证成功与否都注销交易,否则会出现虚假凭证信息一直验证不通过,每次进程序都得输入苹果账号
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
 
#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *product = response.products;
    if([product count] <= 0){

        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{

            [SVProgressHUD showErrorWithStatus:@"没有找到对应的商品"];
        });
        
        NSLog(@"--------------没有商品------------------");
        return;
    }
     
    SKProduct *p = nil;
    for(SKProduct *pro in product){
        if([pro.productIdentifier isEqualToString:_currentPurchasedID]){
            p = pro;
            break;
        }
    }
     
#if DEBUG
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    NSLog(@"产品描述:%@",[p description]);
    NSLog(@"产品标题%@",[p localizedTitle]);
    NSLog(@"产品本地化描述%@",[p localizedDescription]);
    NSLog(@"产品价格：%@",[p price]);
    NSLog(@"产品productIdentifier：%@",[p productIdentifier]);
#endif
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
 
#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self verifyPurchaseWithPaymentTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
               
                break;
            case SKPaymentTransactionStateRestored:

                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"恢复成功！"];
                
                [self verifyPurchaseWithPaymentTransaction:tran];
                NSLog(@"已经购买过商品");
                
                // 消耗型不支持恢复购买
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:tran];
                break;
            default:
                break;
        }
    }
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-----------从App Store中检索关于指定产品列表的本地化信息错误------------:%@", error);
}
 
- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------requestDidFinish-----------------");
}

// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self handleActionWithType:ZKPaymentFailed data:nil];
    }else{
        [self handleActionWithType:ZKPaymentCancel data:nil];
    }
     
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"恢复Transactions = %@",queue.transactions);
    [SVProgressHUD dismiss];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"恢复error = %@",error);
    [SVProgressHUD dismiss];
}



#pragma mark -- 结束上次未完成的交易 防止串单
- (void)removeAllUncompleteTransactionBeforeStartNewTransaction{
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    if (transactions.count > 0) {
        //检测是否有未完成的交易
        SKPaymentTransaction* transaction = [transactions firstObject];
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            return;
        }
    }
}

// 获取会员到期时间
- (void)getExpirationDateForPurchase:(SKPaymentTransaction *)transaction {
    // 获取原始的购买事务
    SKPaymentTransaction *originalTransaction = transaction.originalTransaction;
    
    // 获取购买凭证
    NSData *receiptData = originalTransaction.transactionReceipt;
    
    // 将凭证发送到苹果服务器进行验证
    [self validateReceiptWithData:receiptData completion:^(NSDictionary *receiptInfo, NSError *error) {
        if (error) {
            NSLog(@"Receipt validation failed with error: %@", error.localizedDescription);
        } else {
            // 解析返回的 JSON 数据
            NSDictionary *latestReceiptInfo = receiptInfo[@"latest_receipt_info"];
            NSString *expirationDateStr = latestReceiptInfo[@"expires_date"];
            
            // 将字符串转换为日期格式
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss VV"];
            NSDate *expirationDate = [dateFormatter dateFromString:expirationDateStr];
            
            NSLog(@"Membership expiration date: %@", expirationDate);
        }
    }];
}

// 发送购买凭证到苹果服务器进行验证
- (void)validateReceiptWithData:(NSData *)receiptData completion:(void(^)(NSDictionary *receiptInfo, NSError *error))completion {
    // 构建请求参数
    NSDictionary *requestParams = @{
        @"receipt-data": [receiptData base64EncodedStringWithOptions:0]
    };
    
    // 发送请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:nil];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            completion(jsonResponse, nil);
        }
    }];
    [task resume];
}


@end
