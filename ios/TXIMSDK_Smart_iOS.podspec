Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Smart_iOS'
  spec.version      = '5.1.118'
  spec.platform     = :ios 
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
			:text => <<-LICENSE
				copyright 2017 tencent Ltd. All rights reserved.
				LICENSE
			 }
  spec.homepage     = 'https://cloud.tencent.com/product/mlvb'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/454/7876'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXLiteAVSDK for TRTC Edition.'
  spec.ios.framework = ['AVFoundation', 'Accelerate']
  spec.library = 'c++', 'resolv'
  spec.requires_arc = true

  spec.source = { :http => 'https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/restructure/ios/5.1.118/ImSDK_Smart.framework.zip' }
  spec.preserve_paths = 'ImSDK_Smart.framework'
  spec.source_files = 'ImSDK_Smart.framework/Headers/*.h'
  spec.public_header_files = 'ImSDK_Smart.framework/Headers/*.h'
  spec.vendored_frameworks = 'ImSDK_Smart.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_Smart_iOS/ImSDK_Smart.framework/Headers/'}
end
