//
//  AppDelegate.m
//  BeeCloudDemo
//
//  Created by RInz on 15/2/5.
//  Copyright (c) 2015年 RInz. All rights reserved.
//

#import "AppDelegate.h"
#import "BeeCloud.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

#pragma mark - 初始化生产环境
    //初始化生产环境
    [BeeCloud initWithAppID:@"c5d1cba1-5e3f-4ba0-941d-9b0a371fe719" andAppSecret:@"39a7a518-9ac8-4a9e-87bc-7885f33cf18c"];
    //初始化微信
    [BeeCloud initWeChatPay:@"wxf1aa465362b4c8f1"];
#pragma mark - 初始化沙箱测试环境
    //开启沙箱测试模式，可通过[BeeCloud getSandboxMode]查看当前模式，返回YES代表当前是sandbox环境，返回NO代表当前是生产环境
//    [BeeCloud initSandboxWithAppID:@"c5d1cba1-5e3f-4ba0-941d-9b0a371fe719" testSecret:@"4bfdd244-574d-4bf3-b034-0c751ed34fee"];
#pragma mark - 初始化PayPal
    [BeeCloud initPayPal:@"AVT1Ch18aTIlUJIeeCxvC7ZKQYHczGwiWm8jOwhrREc4a5FnbdwlqEB4evlHPXXUA67RAAZqZM0H8TCR"
                  secret:@"EL-fkjkEUyxrwZAmrfn46awFXlX-h2nRkyCVhhpeVdlSRuhPJKXx3ZvUTTJqPQuAeomXA8PZ2MkX24vF"
                 sandbox:YES];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![BeeCloud handleOpenUrl:url]) {
        //handle其他类型的url
    }
    return YES;
}

//iOS9之后官方推荐用此方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSLog(@"options %@", options);
    if (![BeeCloud handleOpenUrl:url]) {
        //handle其他类型的url
    }
    return YES;
}

@end
