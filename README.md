## BeeCloud iOS SDK (Open Source)

![pass](https://img.shields.io/badge/Build-pass-green.svg) ![license](https://img.shields.io/badge/license-MIT-brightgreen.svg) ![version](https://img.shields.io/badge/version-v3.0.0-blue.svg)

本SDK是根据[BeeCloud Rest API](https://github.com/beecloud/beecloud-rest-api) 开发的 iOS SDK, 适用于 iOS6 及以上版本。可以作为调用BeeCloud Rest API的示例或者直接用于生产。

##流程
![pic](http://7xavqo.com1.z0.glb.clouddn.com/UML.png)

## 安装

1.下载本工程源码，将`BCPaySDK`文件夹中的代码拷贝进自己项目，并按照下文的3个步骤导入相应文件进自己工程即可。
>1. 下载的`External`文件夹下的`AlipaySDK.framework`, `libUPPayPlugin.a`, `libWeChatSDK.a`文件夹分别对应`支付宝`, `银联`, `微信`的原生SDK，请按需导入进自己的项目。  
>2. iOS SDK使用了第三方Http请求库AFNetworking，请一起引入项目（如您之前已经使用AFNetworking，则无需重复导入，但是建议使用最新的AFNetworking版本，新版本修复了一个关于HTTPS链接的安全漏洞）。
>3. 最后加入系统库 `libz.dylib`, `libsqlite3.dylib`, `libc++.dylib` 

2.使用CocoaPods:  
在podfile中加入

```
pod 'BeeCloud'
```


## 注册
三个步骤，2分钟轻松搞定：  
1. 注册开发者：猛击[这里](http://www.beecloud.cn/register)注册成为BeeCloud开发者。  
2. 注册应用：使用注册的账号登陆[控制台](http://www.beecloud.cn/dashboard/)后，点击"+创建App"创建新应用，并配置支付参数。  
3. 在代码中注册：

```.net
//请替换成自己的BeeCloud账户中的AppID和AppSecret
[BCPay initWithAppID:@"c5d1cba1-5e3f-4ba0-941d-9b0a371fe719" andAppSecret:@"39a7a518-9ac8-4a9e-87bc-7885f33cf18c"];

//如果需要微信支付，请添加下面这行（自行替换微信APP ID）
[BCPay initWeChatPay:@"wxf1aa465362b4c8f1"];
```

## 使用方法
>具体使用请参考项目中的`BCPayExample`工程

要调用以下方法，都需要实现接口`BCApiDelegate`， 实现本接口的方法使不同类型的请求获得对应的响应。

### 1.支付

原型：
 
通过构造`BCPayReq`的实例，使用`[BCPay sendBCReq:payReq]`方法发起支付请求。  

调用：

```objc
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
    [BCPay sendBCReq:payReq];
}
```

### 2.查询

* 查询支付订单

原型：

通过构造`BCQueryReq`的实例，使用`[BCPay sendBCReq:req]`方法发起支付查询  

调用：

```objc
   BCQueryReq *req = [[BCQueryReq alloc] init];
   req.channel = channel;
   //req.billno = @"20150722164700237";
   //req.starttime = @"2015-07-21 00:00";
   //req.endtime = @"2015-07-23 12:00";
   req.skip = 0;
   req.limit = 20;
   [BCPay sendBCReq:req];
```
* 查询退款订单

原型：

通过构造`BCQueryRefundReq`的实例，使用`[BCPay sendBCReq:req]`方法发起退款查询

调用：

```objc
   BCQueryRefundReq *req = [[BCQueryRefundReq alloc] init];
   req.channel = channel;
   //req.billno = @"20150722164700237";
   //req.starttime = @"2015-07-21 00:00";
   //req.endtime = @"2015-07-23 12:00";
   //req.refundno = @"20150709173629127";
   req.skip = 0;
   req.limit = 20;
   [BCPay sendBCReq:req];
```
* 查询退款状态（只支持微信）

原型：

通过构造`BCRefundStatusReq`的实例，使用`[BCPay sendBCReq:req]`方法发起退款查询

调用：

```objc
BCRefundStatusReq *req = [[BCRefundStatusReq alloc] init];
req.refundno = @"20150709173629127";
[BCPay sendBCReq:req];
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
由于支付宝对企业账号监控严格，故不再提供支付宝支付的测试功能，请在BeeCloud平台配置正确参数后，使用自行创建的APP的appID和appSecret。给您带来的不便，敬请谅解。

- 在iPhone上未安装支付宝钱包客户端的情况下，APP内发起支付宝支付，会是怎么样的？
正常情况下，会跳到支付宝网页收银台。如果你是从webview发起的支付请求，有可能会出现不跳转的情况。

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
