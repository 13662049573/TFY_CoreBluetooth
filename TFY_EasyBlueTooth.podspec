

Pod::Spec.new do |spec|
  spec.name         = "TFY_EasyBlueTooth"

  spec.version      = "2.2.2"
  
  spec.summary      = "蓝牙封装适合各种设备使用"

  spec.description  = "蓝牙封装适合各种设备使用"

  spec.homepage     = "https://github.com/13662049573/TFY_CoreBluetooth"
  
  spec.license      = "MIT"
  
  spec.author       = { "tfyzxc13662049573" => "420144542@qq.com" }
  
  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/13662049573/TFY_CoreBluetooth.git", :tag => spec.version }

  spec.source_files  = "TFY_CoreBluetooth/TFY_EasyBlueTooth/**/*.{h,m}"

  spec.frameworks    = "Foundation","UIKit"

  spec.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include" }

  spec.requires_arc = true
  
end
