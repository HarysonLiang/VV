//
//  PayTool.m
//  V&V
//
//  Created by Haryson Liang on 5/17/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "PayTool.h"

static PayTool* payToolShare = nil;

@implementation PayTool

@synthesize payOrderId;
@synthesize payReceipt;

+(PayTool*)getInstance
{
    if (payToolShare != nil) {
        return payToolShare;
    }
    payToolShare = [[PayTool alloc] init];
    [payToolShare initPayTool];
    [payToolShare setPayStatus:P_NONE];
    //----监听购买结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:payToolShare];
    
    return payToolShare;
}

-(void)initPayTool
{
    productArray = NULL;
}

-(SKProduct*)getProductByProductId:(NSString*)productId
{
    if (productId == NULL) {
        return NULL;
    }
    if (productArray == NULL || [productArray count] <= 0) {
        return NULL;
    }
    
    for (SKProduct* product in productArray) {
        if ([product.productIdentifier isEqualToString:productId]) {
            return product;
        }
    }
    
    return NULL;
}

-(void)initPayList
{
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"不允许程序内付费购买!");
        return;
    }
    
    NSLog(@"允许程序内付费购买,initPayList...");
    [self RequestProductData];
}

-(void)buy:(int)orderId productId:(NSString*)productId
{
    [self setPayStatus:P_PAYING];
    //buyType = type;
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"允许程序内付费购买,发送购买请求...");
        SKProduct* skProduct = [self getProductByProductId:productId];
        
        if (skProduct == NULL) {
            NSLog(@"购买失败,请求商品为NULL!!!");
            [self setPayStatus:P_FAIL];
            return;
        }
        
        //SKPayment *payment = [SKPayment paymentWithProduct:skProduct];
        SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:skProduct];
        
        payment.requestData = [[NSString stringWithFormat:@"%d",orderId] dataUsingEncoding:NSUTF8StringEncoding];
        payment.quantity = 1;
        
        NSLog(@"---------发送购买请求------------");
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    }
    else
    {
        NSLog(@"不允许程序内付费购买");
//        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"信息"
//                                                            message:@"不允许程序内付费购买"
//                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
        
//        [alerView show];
//        [alerView release];
        [self setPayStatus:P_FAIL];
    }

}

-(NSString*)getLocalPrice:(NSString*)productId
{
    NSString* localPrice = @"";
    SKProduct* product = [self getProductByProductId:productId];
    if (product == NULL) {
        return localPrice;
    }
    
    localPrice = [NSString stringWithFormat:@"%@ %.02f",(NSString*)[[product priceLocale] objectForKey:NSLocaleCurrencySymbol],[product.price floatValue]];
    
    return localPrice;
}

-(bool)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}

-(void)RequestProductData
{
    NSLog(@"---------请求对应的产品信息------------");
    NSArray *product = [[NSArray alloc] initWithObjects:IAP1,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request=[[SKProductsRequest alloc] initWithProductIdentifiers: nsset];
    request.delegate=self;
    [request start];
}
//<SKProductsRequestDelegate> 请求协议
//收到的产品信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"-----------收到产品反馈信息--------------");
    NSArray *myProduct = response.products;
    NSLog(@"产品Product invalid ID:%@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量: %lu", (unsigned long)[myProduct count]);
    
    if (productArray == NULL) {
        productArray = [[NSMutableArray alloc] init];
    } else {
        [productArray removeAllObjects];
    }
    for(SKProduct *product in myProduct){
        NSLog(@"============product info========================");
        NSLog(@"SKProduct 描述信息%@", [product description]);
        NSLog(@"产品标题 %@" , product.localizedTitle);
        NSLog(@"产品描述信息: %@" , product.localizedDescription);
        NSLog(@"价格: %@" , product.price);
        NSLog(@"本地化价格：%@",(NSString*)[[product priceLocale] objectForKey:NSLocaleCurrencySymbol]);
        NSLog(@"Product id: %@" , product.productIdentifier);
        
        [productArray addObject:product];
    }
}

- (void)requestProUpgradeProductData
{
    NSLog(@"------请求升级数据---------");
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.productid"];
    SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}
//弹出错误信息
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"-------弹出错误信息----------:%@",error);
//    UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"信息",NULL) message:[error localizedDescription]
//                                                       delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
//    [alerView show];
//    [alerView release];
    [self setPayStatus:P_FAIL];
}

-(void) requestDidFinish:(SKRequest *)request
{
    NSLog(@"----------反馈信息结束--------------");
}

-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"-----PurchasedTransaction----");
    NSArray *transactions =[[NSArray alloc] initWithObjects:transaction, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
}

//<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
//----监听购买结果
//[[SKPaymentQueue defaultQueue] addTransactionObserver:self];

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions//交易结果
{
    NSLog(@"-----paymentQueue--------");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
            {
                [self completeTransaction:transaction];
                NSLog(@"-----交易完成 --------");
//                UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
//                                                                    message:@"购买成功"
//                                                                   delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
//                
//                [alerView show];
//                [alerView release];
            }
                break;
            case SKPaymentTransactionStateFailed://交易失败
            {
                [self failedTransaction:transaction];
                NSLog(@"-----交易失败 --------");
//                UIAlertView *alerView2 =  [[UIAlertView alloc] initWithTitle:@"信息"
//                                                                     message:@"购买失败，请重新尝试购买"
//                                                                    delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭",nil) otherButtonTitles:nil];
//                
//                [alerView2 show];
//                [alerView2 release];
            }
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                NSLog(@"-----已经购买过该商品 --------");
                [self restoreTransaction:transaction];
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"-----商品添加进列表 --------");
                break;
            default:
                break;
        }
    }
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----completeTransaction--------");
    // Your application should implement these two methods.
    NSString *product = transaction.payment.productIdentifier;
    int orderId = [[[NSString alloc] initWithData:transaction.payment.requestData encoding:NSUTF8StringEncoding] intValue];
    NSString* receipt = [PayTool base64_encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];
    NSLog(@"orderId:%d\nreceipt:%@",orderId,receipt);
    
    [self setPayOrderId:orderId];
    [self setPayReceipt:receipt];
    
    if ([product length] > 0) {
        
        NSArray *tt = [product componentsSeparatedByString:@"."];
        NSString *bookid = [tt lastObject];
        if ([bookid length] > 0) {
            [self recordTransaction:bookid];
            [self provideContent:bookid];
        }
    }
    
    // Remove the transaction from the payment queue.
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self setPayStatus:P_SUCCESS];
}

//记录交易
-(void)recordTransaction:(NSString *)product{
    NSLog(@"-----记录交易--------");
}

//处理下载内容
-(void)provideContent:(NSString *)product{
    NSLog(@"-----下载--------");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    NSLog(@"failedTransaction:失败,error code:%d,desc:%@",(int)transaction.error.code,transaction.error.description);
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self setPayStatus:P_FAIL];
}

-(void) restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction{
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@" 交易恢复处理");
    [self completeTransaction:transaction];
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"-------paymentQueue----error:%@",error);
    [self setPayStatus:P_FAIL];
}


#pragma mark connection delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@",  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    switch([(NSHTTPURLResponse *)response statusCode]) {
        case 200:
        case 206:
            break;
        case 304:
            break;
        case 400:
            break;
        case 404:
            break;
        case 416:
            break;
        case 403:
            break;
        case 401:
        case 500:
            break;
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"test");
}

-(bool)checkUndonePurchase
{
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    //检测是否有未完成的交易
    if (transactions.count > 0) {
        [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:transactions];
        return true;
    }
    return false;
}

-(void)setPayStatus:(int)_payStatus
{
    payStatus = _payStatus;
}

-(int)getPayStatus
{
    return payStatus;
}

-(int)getPayOrderIdAndClean
{
    int orderId = [self payOrderId];
    [self setPayOrderId:0];
    return orderId;
}
-(NSString*)getPayReceiptAndClean
{
    NSString* receipt = [NSString stringWithString:[self payReceipt]];
    [self setPayReceipt:NULL];
    return receipt;
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];//解除监听
}

+ (NSString *)base64_encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger indexCode = (i / 3) * 4;
        output[indexCode + 0] =                    table[(value >> 18) & 0x3F];
        output[indexCode + 1] =                    table[(value >> 12) & 0x3F];
        output[indexCode + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[indexCode + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
