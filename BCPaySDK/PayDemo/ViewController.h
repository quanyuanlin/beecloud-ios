//
//  ViewController.h
//  BeeCloudDemo
//
//  Created by RInz on 15/2/5.
//  Copyright (c) 2015年 RInz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPaySDK.h"

static NSString * const kBody = @"zippo打火机 黑冰侧面圣天使十字架";
static NSString * const kSubject = @"BeeCloud自制白开水";
static NSString * const kTraceID = @"jacky";
static NSString * const kRefundReason = @"不好喝";


@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate, BCApiDelegate>

@property (strong, nonatomic) NSArray *payList;

@property (strong, nonatomic) IBOutlet UITableView *channelTbView;

@property  (assign, nonatomic) NSInteger actionType;//0:pay;1:query;

@end

