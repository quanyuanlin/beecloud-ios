#BeeCloud iOS SDK (Open Source)

![pass](https://img.shields.io/badge/Build-pass-green.svg) ![license](https://img.shields.io/badge/license-MIT-brightgreen.svg) ![version](https://img.shields.io/badge/version-v3.0.0-blue.svg)

本SDK是根据[BeeCloud Rest API](https://github.com/beecloud/beecloud-rest-api) 开发的 iOS SDK, 适用于 iOS6 及以上版本。可以作为调用BeeCloud Rest API的示例或者直接用于生产。

##流程
![pic](http://7xavqo.com1.z0.glb.clouddn.com/UML.png)

## 安装
1.从BeeCloud [release](https://github.com/beecloud/beecloud-ios/releases)中下载压缩包,然后将其中的`libBCPaySDK.a`及相关头文件导入自己工程。

>1. 下载的`External`文件夹下的`AliPaySDK`, `UnionPaySDK`, `WeChatSDK`文件夹分别对应`支付宝`, `银联`, `微信`的原生SDK，请按需导入进自己的项目。  
>2. iOS SDK使用了第三方Http请求库AFNetworking，请一起引入项目（如您之前已经使用AFNetworking，则无需重复导入，但是建议使用最新的AFNetworking版本，新版本修复了一个关于HTTPS链接的安全漏洞）。
>3. 最后加入系统framework: `CoreTelephony.framework`以及系统库 `libz.dylib`, `libsqlite3.dylib`, `libc++.dylib` 

2.下载本工程源码，将`BCPaySDK`文件夹中的代码拷贝进自己项目，并按照上文的3个步骤导入相应文件进自己工程即可。

## 注册
三个步骤，2分钟轻松搞定：
1. 注册开发者：猛击[这里](http://www.beecloud.cn/register)注册成为BeeCloud开发者。
2. 注册应用：使用注册的账号登陆[控制台](http://www.beecloud.cn/dashboard/)后，点击"+创建App"创建新应用
3. 在代码中注册：

```.net
//请替换成自己的BeeCloud账户中的AppID和AppSecret
[BCPaySDK initWithAppID:@"c37d661d-7e61-49ea-96a5-68c34e83db3b" andAppSecret:@"c37d661d-7e61-49ea-96a5-68c34e83db3b"];

//如果需要微信支付，请添加下面这行（自行替换微信APP ID）
[BCPaySDK initWeChatPay:@"wxf1aa465362b4c8f1"];
```

## 使用方法
>具体使用请参考项目中的`PayDemo`工程

要调用以下方法，都需要实现接口`BCApiDelegate`， 本接口的目的在于使不同类型的请求获得对应的不同的响应。

1.支付

原型： 
 
通过构造`BCPayReq`的实例，使用`[BCPaySDK sendBCReq:payReq]`方法发起支付请求。  

调用：

```objc
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
```

2.查询

* 查询支付订单

原型：

通过构造`BCQueryReq`的实例，使用`[BCPaySDK sendBCReq:req]`方法发起查询  

调用：

```.net
BCPayQueryResult result = BCPay.BCPayQueryByCondition(BCUtil.GetTimeStamp("ALI", null, null, null, null, 50);
```
* 查询退款订单

方法原型：

```.net
public static BCRefundQuerytResult BCRefundQueryByCondition(string channel, string billNo, string refundNo, long? startTime, long? endTime, int? skip, int? limit);
```
调用：

```.net
BCRefundQuerytResult result = BCPay.BCRefundQueryByCondition("ALI", null, null, null, null, null, 50);
```
* 查询退款状态（只支持微信）

方法原型：

```.net
public static BCRefundStatusQueryResult BCRefundStatusQuery(string channel, string refundNo);
```
调用：

```.net
BCRefundStatusQueryResult result = BCPay.BCRefundStatusQuery("WX", refundNo);
```

## Demo
项目中的`BeeCloudSDKDemo`工程为我们的demo  
在demo工程中添加BeeCloud工程的dll引用，设置demo工程为启动项后F5即可运行调试
>每次修改过BeeCloud工程后请先build BeeCloud工程再运行demo调试

- 关于支付宝的return_url

请参考demo中的`return_ali_url.aspx`
- 关于银联的return_url

请参考demo中的`return_un_url.aspx`
- 关于weekhook的接收

请参考demo中的`notify.asxp`
文档请阅读 [webhook](https://beecloud.cn/doc/java.php#webhook)

## 测试
TODO

## 常见问题
待补充

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
- 如果有什么问题，可以到 **321545822** BeeCloud开发者大联盟QQ群提问
- 更详细的文档，见源代码的注释以及[官方文档](https://beecloud.cn/doc/net.php)
- 如果发现了bug，欢迎提交[issue](https://github.com/beecloud/beecloud-dotnet-sdk/issues)
- 如果有新的需求，欢迎提交[issue](https://github.com/beecloud/beecloud-dotnet-sdk/issues)

## 代码许可
The MIT License (MIT).
