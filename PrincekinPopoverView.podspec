Pod::Spec.new do |s|
      s.name         = "PrincekinPopoverView"
      s.version      = "0.2.0"
      s.summary      = "一款基于Swift语言的自定义气泡弹窗."
      s.homepage     = 'https://github.com/iOSPrincekin/PrincekinPopoverView.git'
      s.license      = 'MIT'
      s.author       = { "Albert" => "15267030696lee@gmail.com" }
      s.platform     = :ios, "9.0"
      swift_version = 4.0
      s.frameworks   = "UIKit" #支持的框架
      s.source       = { :git => "https://github.com/iOSPrincekin/PrincekinPopoverView.git", :tag => "0.2.0" }
      s.source_files  = '*.{h,m,swift}'
   end