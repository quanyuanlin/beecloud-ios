//
//  ViewController.m
//  BeeCloudDemo
//
//  Created by RInz on 15/2/5.
//  Copyright (c) 2015年 RInz. All rights reserved.
//

#import "ViewController.h"
#import "QueryResultViewController.h"

@interface ViewController ()<BCApiDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.actionType == 0) {
        self.title = @"支付";
    } else if (self.actionType == 1) {
        self.title = @"查询支付订单";
    } else if (self.actionType == 2) {
        self.title = @"查询退款订单";
    }
    
    self.payList = [NSMutableArray arrayWithCapacity:10];
    [BCPay setBCApiDelegate:self];
    
}

- (void)doPay:(PayChannel)channel {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];

    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"BeeCloud自制白开水";
    payReq.totalfee = @"1";
    payReq.billno = outTradeNo;
    payReq.scheme = @"payDemo";
    payReq.viewController = self;
    payReq.optional = dict;
    [BCPay sendBCReq:payReq];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationVC = (UINavigationController*)segue.destinationViewController;
    QueryResultViewController *vc = (QueryResultViewController *)navigationVC.childViewControllers[0];
    vc.dataList = self.payList;
}

- (void)onBCPayResp:(BCBaseResp *)resp {
    if ([resp isKindOfClass:[BCQueryResp class]]) {
        if (resp.result_code == 0) {
            BCQueryResp *tempResp = (BCQueryResp *)resp;
            if (tempResp.count == 0) {
                [self showAlertView:@"未找到相关订单信息"];
            } else {
                self.payList = tempResp.results;
                [self performSegueWithIdentifier:@"queryResult" sender:self];
            }
        }
    } else {
        if (resp.result_code == 0) {
             [self showAlertView:resp.result_msg];
        } else {
             [self showAlertView:resp.err_detail];
        }
    }
}

#pragma mark - 银联支付

- (void)showAlertView:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - 订单查询

- (void)doQuery:(PayChannel)channel {
    
    if (self.actionType == 1) {
        BCQueryReq *req = [[BCQueryReq alloc] init];
        req.channel = channel;
        req.billno = @"b0331675ac6a4d3fa36a8062c0f719ba";//@"20150722164700237";
       // req.starttime = @"2015-07-23 00:00";
     //   req.endtime = @"2015-07-23 12:00";
        req.skip = 0;
        req.limit = 50;
        [BCPay sendBCReq:req];
    } else if (self.actionType == 2) {
        BCQueryRefundReq *req = [[BCQueryRefundReq alloc] init];
        req.channel = channel;
        //  req.billno = @"20150722164700237";
        //  req.starttime = @"2015-07-21 00:00";
        // req.endtime = @"2015-07-23 12:00";
        //req.refundno = @"20150709173629127";
        req.skip = 0;
        req.limit = 20;
        [BCPay sendBCReq:req];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionType == 0) {
        [self doPay:(PayChannel)(indexPath.row + 1)];
    } else {
        [self doQuery:(PayChannel)(indexPath.row + 1)];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
