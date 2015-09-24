//
//  BCOfflinePayResp.h
//  BCPay
//
//  Created by Ewenlong03 on 15/9/16.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResp.h"
#import "BCOfflinePayReq.h"
@interface BCOfflinePayResp : BCBaseResp

@property (nonatomic, retain) NSString *codeurl;

@end
