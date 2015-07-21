//
//  BCObserver.m
//  BeeCloud
//
//  Created by Junxian Huang on 7/28/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCObserver.h"
#import "BCConstants.h"
#import "BCObject.h"
#import "BCUtilPrivate.h"
#import "BCUtil.h"

@implementation BCObserver

@synthesize productToBlock;
@synthesize toRestoredProductIds;
@synthesize restoreBlock;
@synthesize recordSaveBlock;

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self purchasedTransaction:transaction];
                [self saveRecord:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [self saveRecord:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self dupTransaction:transaction];
                [self saveRecord:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
        
    }
}

- (void)purchasedTransaction:(SKPaymentTransaction *)transaction {
    NSString *productId = transaction.payment.productIdentifier;
    BCPurchaseBlock block = [productToBlock objectForKey:productId];
  
    if (block) {
        block(productId, 0, nil);
        [productToBlock removeObjectForKey:transaction.payment.productIdentifier];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {

    NSString *productId = transaction.payment.productIdentifier;
    BCPurchaseBlock block = [productToBlock objectForKey:productId];
    if (block) {
        block(productId, 1, transaction.error);
        [productToBlock removeObjectForKey:transaction.payment.productIdentifier];
    }
}

- (void)dupTransaction:(SKPaymentTransaction *)transaction {
   
    NSString *productId = transaction.payment.productIdentifier;
    if (restoreBlock) {
        if ([toRestoredProductIds containsObject: productId]) {
            restoreBlock(productId, 2, nil);
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    BCDLog(@"Finished restore");
}

- (void)paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    BCDLog(@"error occur");
}

- (void)initPara {
    self.productToBlock = [NSMutableDictionary dictionary];
    self.restoreBlock = nil;
    self.toRestoredProductIds = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    
}

- (void)saveRecord:(SKPaymentTransaction *)transaction {
    if (recordSaveBlock) {
        recordSaveBlock(transaction, nil);
    }
}

@end
