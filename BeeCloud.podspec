Pod::Spec.new do |s|

	s.name         = 'BeeCloud'
	s.version      = '3.3.2'
	s.summary      = 'BeeCloud云服务 致力加速App开发'
	s.homepage     = 'http://beecloud.cn'
	s.license      = 'MIT'
	s.author       = { 'LacusRInz' => 'zhihaoq@beecloud.cn' }
	s.platform     = :ios, '7.0'
	s.source       = { :git => 'https://github.com/beecloud/beecloud-ios.git', :tag => 'v3.3.2'}
	s.requires_arc = true
	s.default_subspecs = "Core", "Alipay", "Wx", "UnionPay"
	
	s.subspec 'Core' do |core|
		core.source_files = 'BCPaySDK/BeeCloud/**/*.{h,m}'
		core.requires_arc = true
		core.ios.library = 'c++', 'z'
		core.dependency 'AFNetworking'
		core.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
	end

	s.subspec 'Alipay' do |alipay|
		alipay.vendored_frameworks = 'BCPaySDK/Channel/AliPay/AlipaySDK.framework'
		alipay.source_files = 'BCPaySDK/Channel/AliPay/BCAliPayAdapter/*.{h,m}', 'BCPaySDK/Channel/AliPay/*.h'
		alipay.dependency 'BeeCloud/Core'
	end

	s.subspec 'Wx' do |wx|
		wx.vendored_libraries = 'BCPaySDK/Channel/WXPay/libWeChatSDK.a'
		wx.source_files = 'BCPaySDK/Channel/WXPay/BCWXPayAdapter/*.{h,m}', 'BCPaySDK/Channel/WXPay/*.h'
		wx.ios.library = 'sqlite3'		
		wx.dependency 'BeeCloud/Core'
	end

	s.subspec 'UnionPay' do |unionpay|
	    unionpay.frameworks = 'Security','QuartzCore'
		unionpay.vendored_libraries = 'BCPaySDK/Channel/UnionPay/libUPPayPlugin.a'
		unionpay.source_files = 'BCPaySDK/Channel/UnionPay/BCUnionPayAdapter/*.{h,m}', 'BCPaySDK/Channel/UnionPay/*.h'
		unionpay.dependency 'BeeCloud/Core'
	end

	s.subspec 'PayPal' do |paypal|
		paypal.frameworks = 'AudioToolbox','CoreLocation','MessageUI','CoreMedia','CoreVideo','Accelerate','AVFoundation'
		paypal.vendored_libraries = 'BCPaySDK/Channel/PayPal/libPayPalMobile.a'
		paypal.source_files = 'BCPaySDK/Channel/PayPal/BCPayPalAdapter/*.{h,m}', 'BCPaySDK/Channel/PayPal/*.h'
		paypal.dependency 'BeeCloud/Core'
	end

	s.subspec 'Offline' do |offline|
		offline.source_files = 'BCPaySDK/Channel/OfflinePay/**/*.{h,m}'
		offline.requires_arc = true
		offline.dependency 'BeeCloud/Core'
	end

	s.subspec 'Baidu' do |baidu|
    baidu.frameworks = 'CoreTelephony', 'AddressBook', 'AddressBookUI', 'AudioToolbox', 'CoreAudio', 'CoreGraphics', 'ImageIO', 'MapKit', 'MessageUI', 'MobileCoreServices', 'QuartzCore'
    baidu.source_files = 'BCPaySDK/Channel/Baidu/Dependency/**/*.{h,m}'
    baidu.resource = 'BCPaySDK/Channel/Baidu/**/*.bundle'
    baidu.vendored_libraries = 'BCPaySDK/Channel/Baidu/**/*.a'
    baidu.dependency 'BeeCloud/Core'
    end
	
end
