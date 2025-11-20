#

Pod::Spec.new do |s|
  s.name             = 'NL'
  s.version          = '0.3.13'
  s.summary          = 'NL cocoapod support.'

  s.description      = "NL is a network layer built on top of url session which can help you implement rest/graphql api calls"

  s.homepage         = 'https://github.com/SreelekhN/NL-Vamichuz'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SreelekhN' => 'sreelekhn@gmail.com' }
  s.source           = { :git => 'https://github.com/SreelekhN/NL-Vamichuz.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.linkedin.com/in/sreelekhn'

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.2'
  s.source_files = 'Sources/NL/**/*'
  
end
