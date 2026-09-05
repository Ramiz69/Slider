Pod::Spec.new do |spec|

  spec.name         = 'RKSlider'
  spec.version      = '0.3.0'
  spec.summary      = 'A CocoaPods library written in Swift'

  spec.description  = <<-DESC
A customizable UIControl slider written in Swift 6, with haptics, four directions,
VoiceOver support and an optional iOS 26 Liquid Glass appearance.
                   DESC

  spec.homepage     = 'https://github.com/Ramiz69/Slider'

  spec.license      = 'MIT'

  spec.author             = { 'Ramiz Kichibekov' => 'ramiz161@icloud.com' }
  spec.social_media_url   = 'https://t.me/Ramiz69'

  spec.ios.deployment_target = "14.0"

  spec.source       = { :git => 'https://github.com/Ramiz69/Slider.git', :tag => spec.version }

  spec.swift_version = ['6.0']
  
  spec.source_files  = 'Sources/*.swift', 'Sources/**/*.swift'

end
