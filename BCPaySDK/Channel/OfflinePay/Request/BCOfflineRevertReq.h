//
//  BCOfflineRevertReq.h
//  BCPay
//
//  Created by Ewenlong03 on 15/9/17.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"

@interface BCOfflineRevertReq : BCBaseReq

@property (nonatomic, retain) NSString *billno;
@property (nonatomic, assign) PayChannel channel;

@end
