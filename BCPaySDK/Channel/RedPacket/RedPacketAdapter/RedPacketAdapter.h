//
//  RedPacketAdapter.h
//  BCPay
//
//  Created by Ewenlong03 on 2017/5/2.
//  Copyright © 2017年 BeeCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RedpacketSDK/RedPacket.h>

@interface RedPacketAdapter : NSObject

@property (nonatomic, strong) NSMutableDictionary * _Nonnull secretCacheDic;

+ (instancetype _Nonnull )sharedInstance;

+ (BOOL)handleOpenUrl:(NSURL * _Nonnull )url;

+ (BOOL)initRedPacket;

+ (void)sendPacketFrom:(nonnull UIViewController*)viewcontroller
                  Type:(RedpacketType)type
                UserID:(nonnull NSString*)userID
            OutTradeNo:(nonnull NSString*)outTradeNo
                Result:(nullable RedpacketResultBlock)block;

+ (void)queryAvailablePacketsByUserID:(nonnull NSString*)userID
                         UserNickname:(nonnull NSString*)nickname
                           UserAvatar:(nullable NSString*)avatar
                         GroupIDArray:(nullable NSArray *)groupArray
                               Result:(nullable RedpacketResultBlock)block;
@end
