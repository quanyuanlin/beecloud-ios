//
//  BCPayObject.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/21.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//
#import "BCPayObject.h"
#import <Foundation/Foundation.h>
#import "BCPayUtil.h"


@implementation BCQueryOrder

#pragma mark - query order
+ (NSMutableDictionary *)getQueryData:(NSString *)type {
    
    NSString *className = nil;
    NSString *keyString = nil;
    if (![BCUtil isPureInt:type]) {
        return nil;
    }
    NSInteger iType = [type integerValue];
    
    switch (iType) {
        case 11:
            className = kBCWeChatPayClassName;
            keyString = @"out_trade_no";
            break;
        case 12:
            className = KBCWeChatRefundClassName;
            keyString = @"out_refund_no";
            break;
        case 21:
            className = kBCAliPayClassName;
            keyString = @"out_trade_no";
            break;
        case 22:
            className = kBCAliRefundClassName;
            keyString = @"out_refund_no";
            break;
        case 31:
            className = kBCUPPayClassName;
            keyString = @"out_trade_no";
            break;
        case 32:
            className = kBCUPRefundClassName;
            keyString = @"out_refund_no";
            break;
        default:
            break;
    }
    if ([BCUtil isValidString:keyString] && [BCUtil isValidString:className]) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        dic[@"key"] = keyString;
        dic[@"className"] = className;
        return dic;
    }
    return nil;
}

+ (NSArray *)queryOrder:(NSString *)type orderid:(NSString *)orderid {
    
    if (![BCUtil isValidString:orderid]) return nil;
    
    NSMutableDictionary *dic = [BCQueryOrder getQueryData:type];
    if (dic) {
        BCQuery *query = [BCQuery queryWithClassName:dic[@"className"]];
        [query whereKey:dic[@"key"] equalTo:orderid];
        NSArray *array = [query findObjects];
        return [BCQueryOrder parseOrderList:array orderType:type];
    }
    return nil;
}

+ (void)querOrderAsync:(NSString *)orderid type:(NSString *)type block:(BCArrayResultBlock)block {
    if (![BCUtil isValidString:orderid] || ![BCUtil isValidString:type] || ![BCUtil isPureInt:type]) {
        if (block) block(nil, [BCPayUtil errorWithCode:1 message:@"参数不合法"]);
        return;
    }
    NSMutableDictionary *dic = [BCQueryOrder getQueryData:type];
    if (dic) {
        BCQuery *query = [BCQuery queryWithClassName:dic[@"className"]];
        [query whereKey:dic[@"key"] equalTo:orderid];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            block([BCQueryOrder parseOrderList:objects orderType:type], error);
        }];
    }
}

+ (NSString *)getValidString:(NSString *)string {
    return [BCUtil isValidString:string] ? string : @"";
}

+ (NSArray *)parseOrderList:(NSArray *)array orderType:(NSString  *)type {
    
    NSMutableArray *mArray = [NSMutableArray array];
    NSInteger iType = [type integerValue];
    for(BCObject *obj in array) {
        switch(iType) {
            case 11:
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"subject"] = [BCQueryOrder getValidString:[obj objectForKey:@"body"]];
                dic[@"out_trade_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"out_trade_no"]];
                dic[@"total_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"total_fee"]];
                dic[@"trace_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"trace_id"]];
                if ([[obj objectForKey:@"spay_result"] boolValue]) {
                    dic[@"trade_state"] = @"TRADE_SUCCESS";
                } else {
                    dic[@"trade_state"] = @"TRADE_CANCEL";
                }
                NSDate *createdAt = [obj objectForKey:@"createdat"];
                if (createdAt)
                    dic[@"trace_time"] = createdAt;
                dic[@"partner"] = [BCQueryOrder getValidString:[obj objectForKey:@"mch_id"]];
                dic[@"openid"] = [BCQueryOrder getValidString:[obj objectForKey:@"openid"]];
                dic[@"trace_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"transaction_id"]];
                dic[@"trade_type"] = [BCQueryOrder getValidString:[obj objectForKey:@"trade_type"]];
                [mArray addObject:dic];
                dic = nil;
            }
                break;
            case 12:
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"refund_status"] = [BCQueryOrder getValidString:[obj objectForKey:@"AFrefund_status"]];
                NSDate *createdAt = [obj objectForKey:@"createdat"];
                if (createdAt)
                    dic[@"trace_time"] = createdAt;
                dic[@"out_trade_no"]=[BCQueryOrder getValidString:[obj objectForKey:@"out_trade_no"]];
                dic[@"body"] = [BCQueryOrder getValidString:[obj objectForKey:@"body"]];
                dic[@"total_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"total_fee"]];
                dic[@"refund_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"refund_amount"]];
                dic[@"refund_reason"] = [BCQueryOrder getValidString:[obj objectForKey:@"refund_reason"]];
                dic[@"reject_reason"] = [BCQueryOrder getValidString:[obj objectForKey:@"reject_reason"]];
                dic[@"trace_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"trace_id"]];
                dic[@"refund_finish"] = [BCQueryOrder getValidString:[obj objectForKey:@"finish"]];
                dic[@"out_refund_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"out_refund_no"]];
                dic[@"trace_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"transaction_id"]];
                dic[@"trade_type"] = [BCQueryOrder getValidString:[obj objectForKey:@"trade_type"]];
                [mArray addObject:dic];
                dic = nil;
            }
                break;
            case 21:
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"body"] = [BCQueryOrder getValidString:[obj objectForKey:@"body"]];
                dic[@"buyer_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"buyer_id"]];
                dic[@"buyer_email"] = [BCQueryOrder getValidString:[obj objectForKey:@"buyer_email"]];
                NSDate *createdAt = [obj objectForKey:@"createdat"];
                if (createdAt) dic[@"trace_time"] = createdAt;
                dic[@"out_trade_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"out_trade_no"]];
                dic[@"partner"] = [BCQueryOrder getValidString:[obj objectForKey:@"partner"]];
                dic[@"seller_email"] = [BCQueryOrder getValidString:[obj objectForKey:@"seller_email"]];
                dic[@"seller_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"seller_id"]];
                dic[@"subject"] = [BCQueryOrder getValidString:[obj objectForKey:@"subject"]];
                dic[@"total_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"total_fee"]];
                dic[@"trace_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"trace_id"]];
                if ([[obj objectForKey:@"spay_result"] boolValue]) {
                    dic[@"trade_state"] = @"TRADE_SUCCESS";
                } else {
                    dic[@"trade_state"] = @"TRADE_CANCEL";
                }
                dic[@"trace_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"trade_no"]];
                [mArray addObject:dic];
                dic = nil;
            }
                break;
            case 22:
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"refund_status"] = [BCQueryOrder getValidString:[obj objectForKey:@"AFrefund_status"]];
                NSDate *createdAt = [obj objectForKey:@"createdat"];
                if (createdAt) dic[@"trace_time"] = createdAt;
                dic[@"out_trade_no"]=[BCQueryOrder getValidString:[obj objectForKey:@"out_trade_no"]];
                dic[@"body"] = [BCQueryOrder getValidString:[obj objectForKey:@"body"]];
                dic[@"total_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"total_fee"]];
                dic[@"refund_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"refund_amount"]];
                dic[@"refund_reason"] = [BCQueryOrder getValidString:[obj objectForKey:@"refund_reason"]];
                dic[@"reject_reason"] = [BCQueryOrder getValidString:[obj objectForKey:@"reject_reason"]];
                dic[@"trace_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"trace_id"]];
                dic[@"refund_finish"] = [BCQueryOrder getValidString:[obj objectForKey:@"finish"]];
                dic[@"out_refund_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"out_refund_no"]];
                dic[@"trace_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"trade_no"]];
                [mArray addObject:dic];
                dic = nil;
            }
                break;
            case 31:
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"subject"] = [BCQueryOrder getValidString:[obj objectForKey:@"orderdesc"]];
                dic[@"trace_time"] = [BCQueryOrder getValidString:[obj objectForKey:@"txntime"]];
                dic[@"out_trade_no"]=[BCQueryOrder getValidString:[obj objectForKey:@"orderid"]];
                dic[@"partner"] = [BCQueryOrder getValidString:[obj objectForKey:@"merid"]];
                dic[@"total_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"txnamt"]];
                dic[@"trace_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"traceid"]];
                dic[@"trade_state"] = [[BCQueryOrder getValidString:[obj objectForKey:@"respcode"]] isEqualToString:@"00"]?@"TRADE_SUCCESS":@"TRADE_CANCEL";
                dic[@"trace_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"queryid"]];
                [mArray addObject:dic];
                dic = nil;
            }
                break;
            case 32:
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"refund_status"] = [BCQueryOrder getValidString:[obj objectForKey:@"AFrefund_status"]];
                NSDate *createdAt = [obj objectForKey:@"createdat"];
                if (createdAt) dic[@"trace_time"] = createdAt;
                dic[@"out_trade_no"]=[BCQueryOrder getValidString:[obj objectForKey:@"orderid"]];
                dic[@"partner"] = [BCQueryOrder getValidString:[obj objectForKey:@"merid"]];
                dic[@"body"] = [BCQueryOrder getValidString:[obj objectForKey:@"orderdesc"]];
                dic[@"total_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"total_fee"]];
                dic[@"refund_fee"] = [BCQueryOrder getValidString:[obj objectForKey:@"refund_amount"]];
                dic[@"refund_reason"] = [BCQueryOrder getValidString:[obj objectForKey:@"refund_reason"]];
                dic[@"reject_reason"] = [BCQueryOrder getValidString:[obj objectForKey:@"reject_reason"]];
                dic[@"trace_id"] = [BCQueryOrder getValidString:[obj objectForKey:@"trace_id"]];
                dic[@"refund_finish"] = [BCQueryOrder getValidString:[obj objectForKey:@"respmsg"]];
                dic[@"out_refund_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"out_refund_no"]];
                dic[@"trace_no"] = [BCQueryOrder getValidString:[obj objectForKey:@"queryid"]];
                [mArray addObject:dic];
                dic = nil;
            }
                break;
            default:
                break;
        }
    }
    NSArray *reArray = nil;
    if (mArray.count > 0) {
        reArray = [NSArray arrayWithArray:mArray];
        mArray = nil;
    }
    return reArray;
}
@end