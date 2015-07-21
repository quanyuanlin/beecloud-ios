//
//  BCObserver.h
//  BeeCloud
//
//  Created by Junxian Huang on 7/28/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>
#import "BCConstants.h"


@interface BCObserver : NSObject<SKPaymentTransactionObserver>

/**
 *  A map with key productid, value block.
 */
@property(nonatomic, strong) NSMutableDictionary *productToBlock;

/**
 *  A list with to restore productIds, set while restore some products.
 */
@property(nonatomic, strong) NSMutableArray *toRestoredProductIds;

/**
 *  Block for restore result;
 */
@property(nonatomic, strong) BCPurchaseBlock restoreBlock;

/**
 *  Block for save record result;
 */
@property(nonatomic, strong) BCIAPRecordBlock recordSaveBlock;

-(void)initPara;

/**
 *  Payment state updated, purchase success or fail delegate.
 *
 *  @param queue        payment queue
 *  @param transactions updated transactions
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

/**
 *  Deal with sucess transaction.
 *
 *  @param transaction Success transactions.
 */
- (void)purchasedTransaction:(SKPaymentTransaction *)transaction;

/**
 *  Deal with failed transaction.
 *
 *  @param transaction Sailed transactions.
 */
- (void)failedTransaction:(SKPaymentTransaction *)transaction;

/**
 *  Deal with already purchased before transactions.
 *
 *  @param transaction Purchased transactions.
 */
- (void)dupTransaction:(SKPaymentTransaction *)transaction;

/**
 *  Restore transaction success delegate.
 *
 *  @param transaction All restored transactions.
 */
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;

/**
 *  Restore transaction error delegate.
 *
 *  @param paymentQueue All payments.
 *  @param error        Error description.
 */
- (void)paymentQueue:(SKPaymentQueue *)paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error;

@end
