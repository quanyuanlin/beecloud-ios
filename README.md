## BeeCloud iOS SDK (Open Source)

![pass](https://img.shields.io/badge/Build-pass-green.svg) ![license](https://img.shields.io/badge/license-MIT-brightgreen.svg) ![version](https://img.shields.io/badge/version-v3.2.3-blue.svg)

## 简介

本项目的官方GitHub地址是 [https://github.com/beecloud/beecloud-ios](https://github.com/beecloud/beecloud-ios)

目前已经包含微信APP、支付宝APP、银联在线APP、PayPal APP支付功能，以及支付订单和退款订单的查询功能。还包含了线下收款功能(包括微信扫码、微信刷卡、支付宝扫码、支付宝条形码)，以及订单状态的查询与订单撤销。  
本SDK是根据[BeeCloud Rest API](https://github.com/beecloud/beecloud-rest-api) 开发的 iOS SDK, 适用于 iOS6 及以上版本。可以作为调用BeeCloud Rest API的示例或者直接用于生产。

##流程
![pic](http://7xavqo.com1.z0.glb.clouddn.com/UML.png)

## 安装

1.下载本工程源码，将`BCPaySDK`文件夹中的代码拷贝进自己项目，并按照下文的3个步骤导入相应文件进自己工程即可。
>1. 下载的`BCPaySDK`文件夹下的`Channel`文件夹里包含了`支付宝`, `银联`, `微信`, `PayPal`,`OfflinePay`的原生SDK，请按需删除自己不需要的渠道，都保留也没有问题。  
>2. iOS SDK使用了第三方Http请求库AFNetworking，请一起引入项目（如您之前已经使用AFNetworking，则无需重复导入，但是建议使用最新的AFNetworking版本，新版本修复了一个关于HTTPS链接的安全漏洞）。
>3. 最后加入系统库 `libz.dylib`, `libsqlite3.dylib`, `libc++.dylib` 
>4. 使用PayPal支付，需要添加以下系统库：
>`AudioToolbox.framework`
`CoreLocation.framework`
`MessageUI.framework`
`CoreMedia.framework`
`CoreVideo.framework`
`Accelerate.framework`
`AVFoundation.framework`

2.使用CocoaPods:  
在podfile中加入

```
pod 'BeeCloud' //包含支付宝微信银联三个渠道
pod 'BeeCloud/Alipay' //只包含支付宝
pod 'BeeCloud/Wx' //只包括微信
pod 'BeeCloud/UnionPay' //只包括银联
pod 'BeeCloud/PayPal' //只包括paypal
pod 'BeeCloud/Offline' //只包括线下收款
```
## 配置

1. `iOS 9`以上版本如果需要使用支付宝和微信支付，需要在`Info.plist`添加以下代码：

    ```
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>weixin</string>
        <string>wechat</string>
        <string>alipay</string>
    </array>
    ```
2. `iOS 9`默认限制了http协议的访问，如果App需要使用`http://`访问，必须在 `Info.plist`添加如下代码：

    ```
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    ```
3. 如果Build失败，遇到以下错误信息：

    ```
    XXXXXXX does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target.
    ```
    请到 Xcode 项目的 Build Settings 页搜索 bitcode，将 Enable Bitcode 设置为 NO。


## 注册
三个步骤，2分钟轻松搞定：  
1. 注册开发者：猛击[这里](http://www.beecloud.cn/register)注册成为BeeCloud开发者。  
2. 注册应用：使用注册的账号登陆[控制台](http://www.beecloud.cn/dashboard/)后，点击"+创建App"创建新应用，并配置支付参数。  
3. 在代码中注册：

```objc
//请替换成自己的BeeCloud账户中的AppID和AppSecret
[BeeCloud initWithAppID:@"c5d1cba1-5e3f-4ba0-941d-9b0a371fe719" andAppSecret:@"39a7a518-9ac8-4a9e-87bc-7885f33cf18c"];

//如果需要微信支付，请添加下面这行（自行替换微信APP ID）
[BeeCloud initWeChatPay:@"wxf1aa465362b4c8f1"];

//如果需要PayPal，请添加下面这行
 [BeeCloud initPayPal:@"AVT1Ch18aTIlUJIeeCxvC7ZKQYHczGwiWm8jOwhrREc4a5FnbdwlqEB4evlHPXXUA67RAAZqZM0H8TCR" secret:@"EL-fkjkEUyxrwZAmrfn46awFXlX-h2nRkyCVhhpeVdlSRuhPJKXx3ZvUTTJqPQuAeomXA8PZ2MkX24vF" sanBox:YES];
```

## 使用方法
>具体使用请参考项目中的`BCPayExample`工程

实现接口`BeeCloudDelegate`，获取不同类型的请求对应的响应。  

*  使用以下方法设置delegate:

```objc
[BeeCloud setBeeCloudDelegate:self];
```

*  实现BeeCloudDelegate:

```objc
- (void)onBeeCloudResp:(BCBaseResp *)resp {
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
    } else if ([resp isKindOfClass:[BCPayResp class]]){
        if (resp.result_code == 0) {
             [self showAlertView:resp.result_msg];
        } else {
             [self showAlertView:resp.err_detail];
        }
    }
}
```


### 1.支付

原型：
 
通过构造`BCPayReq`的实例，使用`[BeeCloud sendBCReq:payReq]`方法发起支付请求。  

调用：

```objc
//微信、支付宝、银联
- (void)doPay:(PayChannel)channel {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];

    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;//渠道
    payReq.title = @"BeeCloud自制白开水";//订单标题
    payReq.totalfee = @"1";//订单金额
    payReq.billno = outTradeNo;//商户自定义订单号，必须保证唯一性
    payReq.scheme = @"payDemo";//url scheme,"AliPay"必须参数
    payReq.viewController = self;//"UnionPay"必须参数
    payReq.optional = dict;//商户业务扩展参数
    [BeeCloud sendBCReq:payReq];
}

```

#### PayPal
##### 支付
 
 ```objc
 //PayPal Pay
- (void)doPayPal {
    BCPayPalReq *payReq = [[BCPayPalReq alloc] init];
    
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    PayPalItem *item1 = [PayPalItem itemWithName:@"Old jeans with holes"
                                    withQuantity:2
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"84.99"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00037"];
    
    PayPalItem *item2 = [PayPalItem itemWithName:@"Free rainbow patch"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"0.00"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00066"];
    
    PayPalItem *item3 = [PayPalItem itemWithName:@"Long-sleeve plaid shirt (mustache not included)"
                                    withQuantity:1
                                       withPrice:[NSDecimalNumber decimalNumberWithString:@"37.99"]
                                    withCurrency:@"USD"
                                         withSku:@"Hip-00291"];
    
    payReq.items = @[item1, item2, item3];
    payReq.shipping = @"5.00";
    payReq.tax = @"2.50";
    payReq.shortDesc = @"paypal test";
    payReq.viewController = self;
    payReq.payConfig = _payPalConfig;
    
    [BeeCloud sendBCReq:payReq]; 
}
 ```
##### 实现`PayPalPaymentDelegate`

支付完成

```objc
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {

	//使用`completedPayment`完成Payment Verify操作
	BCPayPalVerifyReq *req = [[BCPayPalVerifyReq alloc] init];
   req.payment = _completedPayment;
   [BeeCloud sendBCReq:req];
   
   [self dismissViewControllerAnimated:YES completion:nil];
}
```

支付取消

```objc

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
   
    [self dismissViewControllerAnimated:YES completion:nil];
}
```

#### OfflinePay
##### 支付

```objc
- (void)doOfflinePay:(PayChannel)channel authCode:(NSString *)authcode {
    NSString *outTradeNo = [self genOutTradeNo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    
    BCOfflinePayReq *payReq = [[BCOfflinePayReq alloc] init];
    payReq.channel = channel;
    payReq.title = @"Offline Pay";
    payReq.totalfee = @"1";
    payReq.billno = outTradeNo;
    payReq.authcode = authcode;
    payReq.terminalid = @"BeeCloud617"; 
    payReq.storeid = @"BeeCloud618";
    payReq.optional = dict;
    [BeeCloud sendBCReq:payReq];
}
```
##### 订单状态查询

```objc
BCOfflineStatusReq *req = [[BCOfflineStatusReq alloc] init];
req.channel = PayChannelWxScan;
req.billno = @"2015091821320048";
[BeeCloud sendBCReq:req];               
```

##### 订单撤销

```objc
BCOfflineRevertReq *req = [[BCOfflineRevertReq alloc] init];
req.channel = PayChannelWxScan;
req.billno = @"2015091821320048";
[BeeCloud sendBCReq:req];
```

### 2.查询

* 查询支付订单

原型：

通过构造`BCQueryReq`的实例，使用`[BeeCloud sendBCReq:req]`方法发起支付查询  

调用：

```objc
BCQueryReq *req = [[BCQueryReq alloc] init];
//req.channel = channel;
req.billno = @"20150722164700237";
//req.starttime = @"2015-07-21 00:00";
//req.endtime = @"2015-07-23 12:00";
req.skip = 0;
req.limit = 20;
[BeeCloud sendBCReq:req];
```
* 查询退款订单

原型：

通过构造`BCQueryRefundReq`的实例，使用`[BeeCloud sendBCReq:req]`方法发起退款查询

调用：

```objc
   BCQueryRefundReq *req = [[BCQueryRefundReq alloc] init];
   //req.channel = channel;
   req.billno = @"20150722164700237";
   //req.starttime = @"2015-07-21 00:00";
   //req.endtime = @"2015-07-23 12:00";
   //req.refundno = @"20150709173629127";
   req.skip = 0;
   req.limit = 20;
   [BeeCloud sendBCReq:req];
```
* 查询退款状态（只支持微信）

原型：

通过构造`BCRefundStatusReq`的实例，使用`[BeeCloud sendBCReq:req]`方法发起退款查询

调用：

```objc
BCRefundStatusReq *req = [[BCRefundStatusReq alloc] init];
req.refundno = @"20150709173629127";
[BeeCloud sendBCReq:req];
```

## Demo
项目中的`BCPayExample`文件夹为我们的demo文件  
在真机上运行`BCPayExample`target，体验真实支付场景

## 测试
TODO

## 常见问题
- 关于weekhook的接收  
文档请阅读 [webhook](https://github.com/beecloud/beecloud-webhook)

- 支付宝支付时，提示“ALI69”，“ALI64”？  
一般是因为RSA公钥不正确或未上传导致的。解决方法：在[支付宝商家服务平台](https://b.alipay.com/order/serviceIndex.htm)检查RSA公钥是否生成错误或者没上传。

- BCPayExample中支付宝支付，跳转到支付后提示“系统繁忙”？    
由于支付宝政策原因，故不再提供支付宝支付的测试功能，请在BeeCloud平台配置正确参数后，使用自行创建的APP的appID和appSecret。给您带来的不便，敬请谅解。

- 在iPhone上未安装支付宝钱包客户端的情况下，APP内发起支付宝支付，会是怎么样的？  
正常情况下，会跳到支付宝网页收银台。如果你是从webview发起的支付请求，则不会跳转，请提示用户当前手机没安装APP。

## 代码贡献
我们非常欢迎大家来贡献代码，我们会向贡献者致以最诚挚的敬意。

一般可以通过在Github上提交[Pull Request](https://github.com/beecloud/beecloud-dotnet-sdk)来贡献代码。

Pull Request要求

- 代码规范 

- 代码格式化 

- 必须添加测试！ - 如果没有测试（单元测试、集成测试都可以），那么提交的补丁是不会通过的。

- 记得更新文档 - 保证`README.md`以及其他相关文档及时更新，和代码的变更保持一致性。

- 创建feature分支 - 最好不要从你的master分支提交 pull request。

- 一个feature提交一个pull请求 - 如果你的代码变更了多个操作，那就提交多个pull请求吧。

- 清晰的commit历史 - 保证你的pull请求的每次commit操作都是有意义的。如果你开发中需要执行多次的即时commit操作，那么请把它们放到一起再提交pull请求。

## 联系我们
- 如果有什么问题，可以到BeeCloud开发者1群:**321545822** 或 BeeCloud开发者2群:**427128840** 提问
- 更详细的文档，见源代码的注释以及[官方文档](https://beecloud.cn/doc/?index=1)
- 如果发现了bug，欢迎提交[issue](https://github.com/beecloud/beecloud-dotnet-sdk/issues)
- 如果有新的需求，欢迎提交[issue](https://github.com/beecloud/beecloud-dotnet-sdk/issues)

## 代码许可
The MIT License (MIT).
