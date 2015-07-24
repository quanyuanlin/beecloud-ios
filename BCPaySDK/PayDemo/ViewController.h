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

static NSString * const kBCDateFormat = @"yyyy-MM-dd HH:mm:ss";

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate, BCApiDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *paySegment;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (strong,nonatomic) NSMutableArray *payList;
@property (weak, nonatomic) IBOutlet UILabel *listName;

@end

