Pod::Spec.new do |s|

  s.name         = "BeeCloud"
  s.version      = "3.0.0"
  s.summary      = "BeeCloud云服务 致力加速App开发"
  s.homepage     = "http://beecloud.cn"
  s.license      = "COMMERCIAL"
  s.author       = { "LacusRInz" => "zhihaoq@beecloud.cn" }
  s.platform     = :ios
  s.source       = { :git@github.com:beecloud/beecloud-ios.git", :tag => '3.0.0'}
  s.requires_arc = true
  s.default_subspec = "Core", "Alipay", "Wx", "UnionPay"

  s.subspec "Core" do |core|
  	core.source_files = 'BCPaySDK/**/*.{h,m}'
  	core.requires_arc = true
  	core.libraries = 'z'
  	core.dependency 'AFNetworking', '~> 2.0'
  	core.ios.library = "c++", "z", "sqlite3"
  	core.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }
  end

  s.subspec "Alipay" do |alipay|
  	alipay.public_header_files = 'External/AliPaySDK/*.h'
    alipay.vendored_frameworks = "External/AliPaySDK/AlipaySDK.framework"
    alipay.dependency "BeeCloud/Core"
  end

  s.subspec "Wx" do |wx|
  	wx.public_header_files = 'External/WeChatSDK/*.h'
    wx.vendored_libraries = "External/WeChatSDK/libWeChatSDK.a"
    wx.dependency "BeeCloud/Core"
  end

  s.subspec "UnionPay" do |unionpay|
  	unionpay.public_header_files = 'External/UnionPaySDK/*.h'
    unionpay.vendored_libraries = "External/UnionPaySDK/libUPPayPlugin.a"
    unionpay.dependency "BeeCloud/Core"
  end

end