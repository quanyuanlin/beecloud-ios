//
//  RPPacketInfo.h
//  HuoShaoYun
//
//  Created by 马佳 on 17/3/9.
//  Copyright © 2017年 HWKJ.Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPPacketInfo : NSObject
@property(strong,nonatomic)NSString * platRpNo;
@property(strong,nonatomic)NSString * rpType;
@property(strong,nonatomic)NSString * outReceiverGroupId;
@property(strong,nonatomic)NSString * amount;
@property(strong,nonatomic)NSString * senderNickname;
@property(strong,nonatomic)NSString * sendTime;
@property(strong,nonatomic)NSString * senderAvatar;
@property(strong,nonatomic)NSString * greeting;
@end
