//
//  PayTool.h
//  V&V
//
//  Created by Haryson Liang on 5/17/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define IAP1 @"com.mobilegametree.vv.tip"

enum{
    P_NONE = 0,
    P_PAYING,
    P_SUCCESS,
    P_FAIL,
}PayStatus;

@interface PayTool : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    int buyType;
    int payStatus;
    int payOrderId;
    NSString *payReceipt;
    
    NSMutableArray* productArray;
}

@property (nonatomic, readwrite)int payOrderId;
@property (nonatomic, retain)NSString* payReceipt;

+(PayTool*)getInstance;
-(void)initPayTool;
-(SKProduct*)getProductByProductId:(NSString*)productId;

-(void)initPayList;
-(void)buy:(int)orderId productId:(NSString*)productId;
-(NSString*)getLocalPrice:(NSString*)productId;

-(bool)checkUndonePurchase;
-(void)setPayStatus:(int)_payStatus;
-(int)getPayStatus;
-(int)getPayOrderIdAndClean;
-(NSString*)getPayReceiptAndClean;

-(void) requestProUpgradeProductData;
-(void) RequestProductData;
-(bool) CanMakePay;
-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void) PurchasedTransaction: (SKPaymentTransaction *)transaction;
-(void) completeTransaction: (SKPaymentTransaction *)transaction;
-(void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction;
-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;
-(void) restoreTransaction: (SKPaymentTransaction *)transaction;
-(void) provideContent:(NSString *)product;
-(void) recordTransaction:(NSString *)product;
-(void) restoreCompletedTransactions;

+ (NSString *)base64_encode:(const uint8_t *)input length:(NSInteger)length;
@end

