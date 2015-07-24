//
//  ViewController.m
//  BeeCloudDemo
//
//  Created by RInz on 15/2/5.
//  Copyright (c) 2015年 RInz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<BCApiDelegate> {
    NSString *_out_trade_no;
    NSString *_out_refund_no;
}

@end

@implementation ViewController

@synthesize payButton;
@synthesize paySegment;
@synthesize listButton;
@synthesize listTableView;
@synthesize payList;
@synthesize listName;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    self.listName.text = @"请查询";
    self.payList = [NSMutableArray arrayWithCapacity:10];
    [BCPaySDK setBCApiDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated {
    [self setHideTableViewCell:self.listTableView];
}

- (NSDate *)stringToDate:(NSString *)string {
    if (string == nil || string.length == 0) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kBCDateFormat];
    return [dateFormatter dateFromString:string];
}

- (NSString *)dateToString:(NSDate *)date {
    if (date == nil) return nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kBCDateFormat];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)getDateString:(long long)timeStamp {
    NSLog(@"%lld", timeStamp);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp/1000];
    return [self dateToString:date];
}

- (BOOL)isPureFloat:(NSString *)str {
    NSScanner *scan = [NSScanner scannerWithString:str];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

- (NSString *)genRefundNo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (IBAction)pay:(id)sender {
    [self doPay:[self getChannel]];
}

- (PayChannel)getChannel {
    PayChannel channel;
    switch ([paySegment selectedSegmentIndex]) {
        case 0:
            channel = WX;
            break;
        case 1:
            channel = Ali;
            break;
        case 2:
            channel = Union;
        default:
            break;
    }
    return channel;
}

- (void)doPay:(PayChannel)channel {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    NSLog(@"traceno = %@", outTradeNo);
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = kSubject;
    payReq.totalfee = @"1";
    payReq.billno = @"2015072321064153";// outTradeNo;
    payReq.scheme = @"payTestDemo";
    payReq.viewController = self;
    payReq.optional = dict;
    [BCPaySDK sendBCReq:payReq];
}

- (void)doBCResp:(BCBaseResp *)resp {
    if ([resp isKindOfClass:[BCQueryResp class]]) {
        [self.payList removeAllObjects];
        [self.payList addObjectsFromArray:((BCQueryResp *)resp).results];
        [self.listTableView reloadData];
    } else {
        if (resp.result_code == 0) {
             [self showAlertView:resp.result_msg];
        } else {
             [self showAlertView:resp.err_detail];
        }
       
    }
}

- (void)queryWxRefund:(NSString *)outRefundNo {

}

#pragma mark - 银联支付

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 订单查询

- (IBAction)checkPayList:(id)sender {

 //20150722164700237
    BCQueryReq *req = [[BCQueryReq alloc] init];
    req.channel = WX;
  //  req.billno = @"20150722164700237";
    req.starttime = @"201507210000";
    req.endtime = @"201507231200";
    req.skip = 0;
    req.limit = 20;
    [BCPaySDK sendBCReq:req];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.payList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"orderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BCQBillsResult *result = (BCQBillsResult *)[self.payList objectAtIndex:indexPath.row];
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

- (NSString *)genOutTradeNo {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)setHideTableViewCell:(UITableView *)tableView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = view;
}

@end
