//
//  ShowRedPacketsViewController.m
//  BCPay
//
//  Created by Ewenlong03 on 2017/5/8.
//  Copyright © 2017年 BeeCloud. All rights reserved.
//

#import "ShowRedPacketsViewController.h"
#import "RedPacketViewController.h"
#import "RedPacketAdapter.h"

@interface ShowRedPacketsViewController ()

@end

@implementation ShowRedPacketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initSubviews
{
    //导航栏设置
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"可领红包";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //可领红包
    CGFloat btnWH=40;
    CGFloat originX = SCREEN__WIDTH/5-btnWH/2;
    CGFloat originY = 30;
    CGFloat spacing = SCREEN__WIDTH/5;
    for (int i=0; i<_dataList.count; i++)
    {
        UIButton * packetBtn=[[UIButton alloc]initWithFrame:CGRectMake(originX+spacing*(i%4),originY+i/4,btnWH, btnWH)];
        packetBtn.tag=i;
        [packetBtn setImage:[UIImage imageNamed:@"demo_packet"] forState:UIControlStateNormal];
        [packetBtn addTarget:self action:@selector(fetchPackets:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:packetBtn];
    }
}


#pragma mark - 领取
-(void)fetchPackets:(UIButton*)btn
{
    NSInteger index=btn.tag;
    RPPacketInfo * packetinfo = _dataList[index];
    [RedPacket fetchRedpacketFromViewController:self.navigationController RedpacketInfo:packetinfo SuccessBlock:^(NSDictionary * _Nonnull resultData) {
        NSLog(@"领取回调=%@",resultData);
//        [_dataList removeObjectAtIndex:index];
    }];
}

@end
