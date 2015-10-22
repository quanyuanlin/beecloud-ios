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
    
//    [BeeCloud initWithAppID:@"c5d1cba1-5e3f-4ba0-941d-9b0a371fe719" andAppSecret:@"39a7a518-9ac8-4a9e-87bc-7885f33cf18c"];
   // [BeeCloud initWithAppID:@"c37d661d-7e61-49ea-96a5-68c34e83db3b" andAppSecret:@"c37d661d-7e61-49ea-96a5-68c34e83db3b"];
    [BeeCloud initWithAppID:@"88aee74e-aecd-4733-9e24-1083ebe49806" andAppSecret:@"75ede11f-9a9d-4585-8210-2f5a784b9187"];
    [BeeCloud initWeChatPay:@"wxf1aa465362b4c8f1"];
    [BeeCloud initPayPal:@"AVT1Ch18aTIlUJIeeCxvC7ZKQYHczGwiWm8jOwhrREc4a5FnbdwlqEB4evlHPXXUA67RAAZqZM0H8TCR" secret:@"EL-fkjkEUyxrwZAmrfn46awFXlX-h2nRkyCVhhpeVdlSRuhPJKXx3ZvUTTJqPQuAeomXA8PZ2MkX24vF" sanBox:YES];
    [BeeCloud setWillPrintLog:YES];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![BeeCloud handleOpenUrl:url]) {
        //handle其他类型的url
    }
    return YES;
}

@end
