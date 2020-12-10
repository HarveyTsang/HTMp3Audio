#
#  Be sure to run `pod spec lint HTMp3Audio.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "HTMp3Audio"
  spec.version      = "0.0.3"
  spec.summary      = "Record mp3 format audio on iOS platform"
  spec.description  = <<-DESC
                   Useing lame for record mp3 format audio on iOS platform.
                   DESC
  spec.homepage     = "http://github.com/HarveyTsang"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "HarveyTsang" => "13025483658@163.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/HarveyTsang/HTMp3Audio.git", :tag => "#{spec.version}" }
  spec.source_files  = "HTMp3Audio/HTMp3Audio.h"
  spec.framework  = 'Foundation', 'AVFoundation'
  spec.requires_arc = true

  spec.subspec 'Lame' do |ss|
    ss.preserve_paths = 'HTMp3Audio/lame/lame.h'
    ss.vendored_libraries = 'HTMp3Audio/lame/libmp3lame.a'
    ss.libraries = 'mp3lame'
    ss.xcconfig = {'HEADER_SEARCH_PATHS' => "${PODS_ROOT}/#{spec.name}/HTMp3Audio/lame/lame.h"}
    ss.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    ss.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  end

  spec.subspec 'Record' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.ios.dependency 'HTMp3Audio/Lame'
    ss.source_files = 'HTMp3Audio/HTMp3AudioRecorder.{h,m}'
  end

  spec.subspec 'File' do |ss|
    ss.ios.deployment_target = '9.0'
    ss.ios.dependency 'HTMp3Audio/Lame'
    ss.source_files = 'HTMp3Audio/HTMp3FileConverter.{h,m}'
  end

end
