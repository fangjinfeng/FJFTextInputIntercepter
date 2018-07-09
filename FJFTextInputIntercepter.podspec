Pod::Spec.new do |s|
  s.name         = "FJFTextInputIntercepter"
  s.version      = "0.0.1"
  s.summary      = "输入框拦截器，可以限定输入框:输入长度、只输入数字、小数、中英文、表情等"
  s.homepage     = "http://www.jianshu.com/p/bea2bfed3f3f"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'fangjinfeng' => '116418179@qq.com' }
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/fangjinfeng/FJFTextInputIntercepter.git", :tag => "0.0.1" }
  s.source_files = "FJFTextInputIntercepter/*.{h,m}"
  s.requires_arc = true
  s.framework  = 'UIKit'
end
