//
//  GuideViewController.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "GuideViewController.h"
#import "ViewController.h"

@interface GuideViewController ()<BCApiDelegate>

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [BCPaySDK setBCApiDelegate:self];
    // Do any additional setup after loading the view.
}
- (IBAction)onQueryWXRefund:(id)sender {
    BCRefundStatusReq *req = [[BCRefundStatusReq alloc] init];
    req.refundno = @"20150709173629127";
    [BCPaySDK sendBCReq:req];
}

- (void)onBCApiResp:(BCBaseResp *)resp {
    if ([resp isKindOfClass:[BCRefundStatusResp class]]) {
        BCRefundStatusResp *tempResp = (BCRefundStatusResp *)resp;
        NSString *msg = @"";
        if (resp.result_code == 0) {
            msg = tempResp.refundStatus;
        } else {
            msg = tempResp.err_detail;
        }
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *vc = (ViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"doPay"]) {
        vc.actionType = 0;
    } else if ([segue.identifier isEqualToString:@"doQuery"]){
        vc.actionType = 1;
    } else {
        vc.actionType = 2;
    }
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
