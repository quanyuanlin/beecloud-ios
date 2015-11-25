//
//  BCQueryBillsReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayConstant.h"


typedef NS_ENUM(NSUInteger, BillStatus) {
    BillStatusAll, //所有支付订单
    BillStatusOnlySuccess,//支付成功的订单
    BillStatusOnlyFail //支付失败的订单
};

#pragma mark BCQueryBillsReq
/**
 *  根据条件查询请求支付订单记录
 */
@interface BCQueryBillsReq : BCBaseReq 
/**
 *  支付渠道(具体支持渠道请参考Enum PayChannel)
 */
@property (nonatomic, assign) PayChannel channel;
/**
 *  发起支付时商家自定义的订单号
 */
@property (nonatomic, retain) NSString *billNo;
/**
 *  订单创建时间,@"yyyyMMddHHmm"格式; 例如2015年11月17日 00:00,@"201511170000"
 */
@property (nonatomic, assign) NSString *startTime;
/**
 *  订单创建时间,@"yyyyMMddHHmm"格式; 例如2015年11月17日 12:00,@"201511171200"
 */
@property (nonatomic, assign) NSString *endTime;

/**
 *  根据订单状态查询
 */
@property (nonatomic, assign) BillStatus billStatus;
/**
 *  是否需要支付成功后渠道异步通知的详细信息，YES代表需要返回。注：只有退款成功的订单，才会有messageDetail
 */
@property (nonatomic, assign) BOOL needMsgDetail;
/**
 *  跳过skip条数据，从第(skip+1)条开始查询。默认为0
 */
@property (nonatomic, assign) NSInteger skip;
/**
 *  查询多少条订单记录;最大不超过50条,大于50的,计为50;默认为10
 */
@property (nonatomic, assign) NSInteger limit;

@end
