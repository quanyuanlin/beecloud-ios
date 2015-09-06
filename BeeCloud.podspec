Pod::Spec.new do |s|

	s.name         = 'BeeCloud'
	s.version      = '3.1.1'
	s.summary      = 'BeeCloud云服务 致力加速App开发'
	s.homepage     = 'http://beecloud.cn'
	s.license      = 'MIT'
	s.author       = { 'LacusRInz' => 'zhihaoq@beecloud.cn' }
	s.platform     = :ios, '7.0'
	s.source       = { :git => 'https://github.com/beecloud/beecloud-ios.git', :tag => s.version}
	s.requires_arc = true
	s.default_subspecs = "Core", "Alipay", "Wx", "UnionPay"
	
	s.subspec 'Core' do |core|
		core.source_files = 'BCPaySDK/**/*.{h,m}'
		core.requires_arc = true
		core.ios.library = 'c++', 'z'
		core.dependency 'AFNetworking', '~> 2.5.4'
		core.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
	end

	s.subspec 'Alipay' do |alipay|
		alipay.vendored_frameworks = 'External/AlipaySDK.framework'
		alipay.dependency 'BeeCloud/Core'
	end

	s.subspec 'Wx' do |wx|
		wx.vendored_libraries = 'External/libWeChatSDK.a'
		wx.ios.library = 'sqlite3'		
		wx.dependency 'BeeCloud/Core'
	end

	s.subspec 'UnionPay' do |unionpay|
		unionpay.vendored_libraries = 'External/libUPPayPlugin.a'
		unionpay.dependency 'BeeCloud/Core'
	end

	s.subspec 'PayPal' do |paypal|
		paypal.frameworks = 'AudioToolbox','CoreLocation','MessageUI','CoreMedia','CoreVideo','Accelerate','AVFoundation'
		paypal.vendored_libraries = 'External/libPayPalMobile.a'
		paypal.dependency 'BeeCloud/Core'
	end
	
end
