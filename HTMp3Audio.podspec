#
#  Be sure to run `pod spec lint HTMp3Audio.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "HTMp3Audio"
  spec.version      = "0.0.1"
  spec.summary      = "Record mp3 format audio on iOS platform"
  spec.description  = <<-DESC
                   Useing lame for record mp3 format audio on iOS platform.
                   DESC

  spec.homepage     = "http://github.com/HarveyTsang"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "HarveyTsang" => "13025483658@163.com" }
  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/HarveyTsang/HTMp3Audio.git", :tag => "#{spec.version}" }
  spec.source_files  = "HTMp3Audio/*.{h,m}", "HTMp3Audio/lame/*.{h,m}"
  spec.vendored_libraries = "HTMp3Audio/lame/*.a"

  spec.framework  = 'Foundation', 'AVFoundation'

  spec.requires_arc = true

end
