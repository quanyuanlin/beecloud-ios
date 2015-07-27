//
//  QueryResultViewController.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "QueryResultViewController.h"
#import "BCPaySDK.h"

@interface QueryResultViewController ()

@end

@implementation QueryResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.resultTableView.delegate = self;
    self.resultTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"orderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BCQBillsResult *result = (BCQBillsResult *)[self.dataList objectAtIndex:indexPath.row];
    UILabel *lab1 = (UILabel *)[cell viewWithTag:1001];
    lab1.text = result.title;
    
    UILabel *lab2 = (UILabel *)[cell viewWithTag:1002];
    lab2.text = [self getDateString:[result.created_time longLongValue]];
    
    UILabel *lab3 = (UILabel *)[cell viewWithTag:1003];
    lab3.text = result.bill_no;
    
    UILabel *lab4 = (UILabel *)[cell viewWithTag:1004];
    lab4.text = [NSString stringWithFormat:@"交易状态:%@  渠道:%@  金额:%@", [result.spay_result boolValue]?@"成功":@"失败", result.channel, result.total_fee];
    
    return cell;
}

- (NSString *)getDateString:(long long)timeStamp {
    NSLog(@"%lld", timeStamp);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
    return [self dateToString:date];
}

- (NSDate *)stringToDate:(NSString *)string {
    if (string == nil || string.length == 0) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];
    return [dateFormatter dateFromString:string];
}

- (NSString *)dateToString:(NSDate *)date {
    if (date == nil) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kDateFormat];
    return [dateFormatter stringFromDate:date];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
