//
//  QRCodeViewController.m
//  BCPay
//
//  Created by Ewenlong03 on 15/9/16.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "QRCodeViewController.h"
#import "NSString+IsValid.h"
#import "GenQrCode.h"

@interface QRCodeViewController ()

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMyself)];
    [self.view addGestureRecognizer:tap];
    
    if (self.codeUrl.isValid) {
        UIImage *qrCode = [GenQrCode createQRForString:_codeUrl withSize:250.0f];
       
       UIImageView *codeView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width-40, self.view.bounds.size.width-40) ];
        codeView.image = qrCode;
        [self.view addSubview:codeView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissMyself {
    [self dismissViewControllerAnimated:YES completion:nil];
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
