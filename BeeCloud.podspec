Pod::Spec.new do |s|

	s.name         = 'BeeCloud'
	s.version      = 'v3.2.0'
	s.summary      = 'BeeCloud云服务 致力加速App开发'
	s.homepage     = 'http://beecloud.cn'
	s.license      = 'MIT'
	s.author       = { 'LacusRInz' => 'zhihaoq@beecloud.cn' }
	s.platform     = :ios, '7.0'
	s.source       = { :git => 'https://github.com/beecloud/beecloud-ios.git', :tag => s.version}
	s.requires_arc = true
	s.default_subspecs = "Core", "Alipay", "Wx", "UnionPay"
	
	s.subspec 'Core' do |core|
		core.source_files = 'BCPaySDK/BeeCloud/**/*.{h,m}'
		core.requires_arc = true
		core.ios.library = 'c++', 'z'
		core.dependency 'AFNetworking', '~> 2.5.4'
		core.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
	end

	s.subspec 'Alipay' do |alipay|
		alipay.public_header_files = 'BCPaySDK/Channel/AliPay/*.h'
		alipay.vendored_frameworks = 'BCPaySDK/Channel/AliPay/AlipaySDK.framework'
		alipay.source_files = 'BCPaySDK/Channel/AliPay/BCAliPayAdapter/*.{h,m}'
		alipay.dependency 'BeeCloud/Core'
	end

	s.subspec 'Wx' do |wx|
		wx.public_header_files = 'BCPaySDK/Channel/WXPay/*.h'
		wx.vendored_libraries = 'BCPaySDK/Channel/WXPay/libWeChatSDK.a'
		wx.source_files = 'BCPaySDK/Channel/WXPay/BCWXPayAdapter/*.{h,m}'
		wx.ios.library = 'sqlite3'		
		wx.dependency 'BeeCloud/Core'
	end

	s.subspec 'UnionPay' do |unionpay|
		unionpay.public_header_files = 'BCPaySDK/Channel/UnionPay/*.h'
		unionpay.vendored_libraries = 'BCPaySDK/Channel/UnionPay/libUPPayPlugin.a'
		unionpay.source_files = 'BCPaySDK/Channel/UnionPay/BCUnionPayAdapter/*.{h,m}'
		unionpay.dependency 'BeeCloud/Core'
	end

	s.subspec 'PayPal' do |paypal|
		paypal.frameworks = 'AudioToolbox','CoreLocation','MessageUI','CoreMedia','CoreVideo','Accelerate','AVFoundation'
		paypal.public_header_files = 'BCPaySDK/Channel/PayPal/*.h'
		paypal.vendored_libraries = 'BCPaySDK/Channel/PayPal/libPayPalMobile.a'
		paypal.source_files = 'BCPaySDK/Channel/PayPal/BCPayPalAdapter/*.{h,m}'
		paypal.dependency 'BeeCloud/Core'
	end
	
end
