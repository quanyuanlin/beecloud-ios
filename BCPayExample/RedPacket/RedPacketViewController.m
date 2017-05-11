//
//  ViewController.m
//  HuoShaoYun
//
//  Created by 马佳 on 17/2/13.
//  Copyright © 2017年 HWKJ.Ltd. All rights reserved.
//

#import "RedPacketViewController.h"
#import "ShowRedPacketsViewController.h"
#import "RedPacketAdapter.h"
#import "UIImageView+WebCache.h"

@interface RedPacketViewController ()
{
    //界面
    UIImageView * headIcon;
    UILabel * useridLabel;
    UILabel * nicknameLabel;
    UILabel * groupidLabel;
    
    //模拟的登陆用户的信息
    NSArray * user_IDs;
    NSArray * user_avatars;
    NSArray * user_nicknames;
    NSArray * user_groupIDs;
    NSInteger selectIndex;
    NSInteger selectBtnTag;
    
    //可领红包数据
    NSMutableArray * availablePacketArr;
}
@end

@implementation RedPacketViewController



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDataSource];
    
    [self initSubviews];
}

-(void)initDataSource
{
    availablePacketArr=[NSMutableArray array];
    selectIndex=0;
    user_IDs=@[@"A00",@"A01",@"A02",@"A03",@"A04",@"A05",@"A06",@"A07",@"A08",@"A09"];
    user_avatars=@[@"https://img3.doubanio.com/view/movie_poster_cover/lpst/public/p2180344882.jpg",
                   @"https://img1.doubanio.com/view/movie_poster_cover/lpst/public/p1084402027.jpg",
                   @"https://img3.doubanio.com/view/movie_poster_cover/lpst/public/p461621583.jpg",
                   @"https://img1.doubanio.com/view/movie_poster_cover/lpst/public/p547574189.jpg",
                   @"https://img1.doubanio.com/view/movie_poster_cover/lpst/public/p1617439899.jpg",
                   @"https://img5.doubanio.com/view/movie_poster_cover/lpst/public/p1035097366.jpg",
                   @"https://img3.doubanio.com/view/movie_poster_cover/lpst/public/p887405912.jpg",
                   @"https://img3.doubanio.com/view/movie_poster_cover/lpst/public/p2243984850.jpg",
                   @"https://img1.doubanio.com/view/movie_poster_cover/lpst/public/p2432493858.jpg",
                   @"https://img3.doubanio.com/view/movie_poster_cover/lpst/public/p2366288725.jpg"];
    user_nicknames=@[@"A零零",@"A零一",@"A零二",@"A零三",@"A零四",@"A零五",@"A零六",@"A零七",@"A零八",@"A零九"];
    user_groupIDs=@[@"qun01,qun02",@"qun01,qun02",@"qun01,qun02",@"qun02,qun03",@"qun02,qun03",@"qun02,qun03",
                    @"qun02,qun03",@"qun03,qun04",@"qun03,qun04",@"qun03,qun04"];
}


-(void)initSubviews
{
    //导航条
    self.navigationItem.title=@"红包支付";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = MAIN__COLOR;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    //头像
    headIcon=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2-50, 30, 100,100)];
    headIcon.layer.masksToBounds=YES;
    headIcon.backgroundColor=MAIN__COLOR;
    headIcon.layer.cornerRadius=25;
    [headIcon sd_setImageWithURL:[NSURL URLWithString:user_avatars[selectIndex]]];
    [self.view addSubview:headIcon];
    
    //用户ID
    useridLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2-60, 138, 120, 20)];
    useridLabel.font=[UIFont systemFontOfSize:18];
    useridLabel.textAlignment=NSTextAlignmentCenter;
    useridLabel.text=[NSString stringWithFormat:@"用户ID:%@",user_IDs[selectIndex]];
    [self.view addSubview:useridLabel];
    
    //用户昵称
    nicknameLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2-60, 158, 120, 20)];
    nicknameLabel.font=[UIFont systemFontOfSize:18];
    nicknameLabel.textAlignment=NSTextAlignmentCenter;
    nicknameLabel.text=[NSString stringWithFormat:@"昵称:%@",user_nicknames[selectIndex]];
    [self.view addSubview:nicknameLabel];
    
    //群ID
    groupidLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2-120, 180, 240, 20)];
    groupidLabel.font=[UIFont systemFontOfSize:18];
    groupidLabel.textAlignment=NSTextAlignmentCenter;
    groupidLabel.text=[NSString stringWithFormat:@"群ID:%@",user_groupIDs[selectIndex]];
    [self.view addSubview:groupidLabel];
    
    //切换用户
    UIButton * swichBtn=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2-60, 210, 120, 30)];
    [swichBtn setTitle:@"切换用户" forState:UIControlStateNormal];
    swichBtn.backgroundColor=MAIN__COLOR;
    swichBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    swichBtn.layer.cornerRadius=5;
    [swichBtn addTarget:self action:@selector(changeUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swichBtn];
    
    //发送单人红包
    UIButton * btn=[[UIButton alloc]initWithFrame:CGRectMake(30, SCREEN__HEIGHT-180, SCREEN__WIDTH/2-45,35)];
    [btn addTarget:self action:@selector(showAlertViewForInput:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius=5;
    btn.titleLabel.font=[UIFont systemFontOfSize:15];
    btn.backgroundColor=MAIN__COLOR;
    btn.tag=0;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"发单人红包" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    //群红包
    UIButton * btn2=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2+15, SCREEN__HEIGHT-180, SCREEN__WIDTH/2-45,35)];
    [btn2 addTarget:self action:@selector(showAlertViewForInput:) forControlEvents:UIControlEventTouchUpInside];
    btn2.layer.cornerRadius=5;
    btn2.titleLabel.font=[UIFont systemFontOfSize:15];
    btn2.tag=1;
    btn2.backgroundColor=MAIN__COLOR;
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 setTitle:@"发群红包" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    
    //查询红包
    UIButton * btn3=[[UIButton alloc]initWithFrame:CGRectMake(30, SCREEN__HEIGHT-120, SCREEN__WIDTH/2-45,35)];
    btn3.layer.cornerRadius=5;
    btn3.backgroundColor=MAIN__COLOR;
    btn3.titleLabel.font=[UIFont systemFontOfSize:15];
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(showAvailablePackets) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setTitle:@"查看可领红包" forState:UIControlStateNormal];
    [self.view addSubview:btn3];
    
    //红包记录
    UIButton * btn4=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN__WIDTH/2+15, SCREEN__HEIGHT-120, SCREEN__WIDTH/2-45,35)];
    [btn4 addTarget:self action:@selector(showRedPacketRecord) forControlEvents:UIControlEventTouchUpInside];
    btn4.layer.cornerRadius=5;
    btn4.titleLabel.font=[UIFont systemFontOfSize:15];
    btn4.backgroundColor=MAIN__COLOR;
    [btn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn4 setTitle:@"红包纪录" forState:UIControlStateNormal];
    [self.view addSubview:btn4];
    
    //初始化用户信息
    [self startQueryAvailablePacket:user_IDs[selectIndex] userAvatar:user_avatars[selectIndex] nickname:user_nicknames[selectIndex] groupArr:[user_groupIDs[selectIndex] componentsSeparatedByString:@","]];
}






#pragma mark - 红包发、查、领、纪录
//发单人红包
-(void)sendSingleRedPacketWithReceiverID:(NSString*)userID;
{
    //随机生成外部订单号
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString * randomTimeStr=[NSString stringWithFormat:@"%.0f",interval+1233883];
    
    //发送单人红包
    [RedPacket sendPacketFrom:self Type:SinglePacketType Receiver:userID OutTradeNo:randomTimeStr Result:^(NSDictionary * _Nonnull resultData) {
        NSLog(@"单红包回调:%@",resultData);
    }];
}


//发群红包
-(void)sendMultipleRedPacketWithGroupID:(NSString*)groupID;
{
    //随机生成外部订单号
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString * randomTimeStr=[NSString stringWithFormat:@"%.0f",interval+1233883];
    
    //发群红包
    [RedPacket sendPacketFrom:self Type:MultiplePacketTypeNormal Receiver:groupID OutTradeNo:randomTimeStr Result:^(NSDictionary * _Nonnull resultData) {
        NSLog(@"群红包回调:%@",resultData);
    }];
}


//查询可领红包
-(void)startQueryAvailablePacket:(NSString*)userID userAvatar:(NSString*)avatar nickname:(NSString*)name groupArr:(NSArray*)groupArray
{
    [RedPacket queryAvailablePackets:YES UserID:userID UserNickname:name UserAvatar:avatar GroupIDArray:groupArray Result:^(NSDictionary * _Nonnull resultData) {
        NSLog(@"可领红包回调:%@",resultData);
        if ([[resultData objectForKey:@"code"] isEqualToString:@"2000"])
        {
            [availablePacketArr removeAllObjects];
            [availablePacketArr addObjectsFromArray:[resultData objectForKey:@"data"]];
        }
    }];
}


//进入领红包界面
-(void)showAvailablePackets {
    ShowRedPacketsViewController * view = [[ShowRedPacketsViewController alloc]init];
    view.dataList = availablePacketArr;
    [self.navigationController pushViewController:view animated:YES];
}


//红包详情
-(void)showRedPacketRecord
{
    [RedPacket showRedpacketRecordViewFrom:self];
}


#pragma mark - Btn Actions
-(void)showAlertViewForInput:(UIButton*)sender
{
    selectBtnTag = sender.tag;
    NSString * alertTitle;
    NSString * alertMessage;
    if (sender.tag == 0)
    {
        alertTitle=@"请输入接收 用户ID";
        alertMessage=[NSString stringWithFormat:@"为了方便demo演示，推荐输入%@－%@之间的ID号",user_IDs.firstObject,user_IDs.lastObject];
    }
    else
    {
        alertTitle = @"请输入接收 群ID";
        alertMessage = @"为了方便demo演示，可随意输入一个群ID，领取该红包时，请传入该ID值。";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self cancelButtonTitle:@"确定"
                                              otherButtonTitles:@"取消", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.text = @"A02";
    [alertView show];
}


//切换登陆用户
-(void)changeUserInfo
{
    selectIndex+=1;
    if (selectIndex==10)
    {
        selectIndex=0;
    }
    
    [headIcon sd_setImageWithURL:[NSURL URLWithString:user_avatars[selectIndex]]];
    useridLabel.text=[NSString stringWithFormat:@"用户ID:%@",user_IDs[selectIndex]];
    nicknameLabel.text=[NSString stringWithFormat:@"昵称:%@",user_nicknames[selectIndex]];
    groupidLabel.text=[NSString stringWithFormat:@"群ID:%@",user_groupIDs[selectIndex]];
    
    [self startQueryAvailablePacket:user_IDs[selectIndex] userAvatar:user_avatars[selectIndex] nickname:user_nicknames[selectIndex] groupArr:[user_groupIDs[selectIndex] componentsSeparatedByString:@","]];
}


#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"确定"])
    {
        UITextField * inputfield=[alertView textFieldAtIndex:0];
        if (selectBtnTag==0)
        {
            [self sendSingleRedPacketWithReceiverID:inputfield.text];
        }
        else
        {
            [self sendMultipleRedPacketWithGroupID:inputfield.text];
        }
    }
}
@end
