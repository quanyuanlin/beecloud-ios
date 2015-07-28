//
//  GuideViewController.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "GuideViewController.h"
#import "ViewController.h"

@interface GuideViewController ()

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navigationVC = (UINavigationController *)segue.destinationViewController;
    ViewController *viewController = navigationVC.childViewControllers[0];
    if ([segue.identifier isEqualToString:@"doPay"]) {
        viewController.actionType = 0;
    } else if ([segue.identifier isEqualToString:@"doQuery"]){
        viewController.actionType = 1;
    } else {
        viewController.actionType = 2;
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
