//
//  QueryResultViewController.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueryResultViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *resultTableView;

@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, assign) NSInteger resultType;

@end
