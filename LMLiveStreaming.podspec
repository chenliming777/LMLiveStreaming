

Pod::Spec.new do |s|

  s.name         = "LMLiveStreaming"
  s.version      = "0.0.1"
  s.summary      = "IOS Mobile phone broadcast  of LMLiveStreaming."
  s.homepage     = "https://github.com/chenliming777"
  s.license      = "MIT"
  s.author       = { "chenliming" => "chenliming777@qq.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/chenliming777/LMLiveStreaming.git", :tag => "1.0.2" }

  s.source_files  = "LMLiveStreaming/**/*.{h,m}"
  s.public_header_files = "LMLiveStreaming/**/*.h"

  s.frameworks = "VideoToolbox", "AudioToolbox","AVFoundation","Foundation","UIKit"
  s.library   = "z"


  s.requires_arc = true

  s.dependency "CocoaAsyncSocket", "~> 7.4.1"
  s.dependency "GPUImage"
  s.dependency "librtmp-iOS", "~> 1.1.0"

end
