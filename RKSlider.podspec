Pod::Spec.new do |spec|

  spec.name         = 'RKSlider'
  spec.version      = '0.0.6'
  spec.summary      = 'A CocoaPods library written in Swift'

  spec.description  = <<-DESC
This CocoaPods library helps you create application with the best slider.
                   DESC

  spec.homepage     = 'https://github.com/Ramiz69/Slider'

  spec.license      = 'MIT'

  spec.author             = { 'Ramiz Kichibekov' => 'ramiz161@icloud.com' }
  spec.social_media_url   = 'https://t.me/Ramiz69'

  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => 'https://github.com/Ramiz69/Slider.git', :tag => spec.version }

  spec.swift_version = ['5.0', '5.1']
  
  spec.source_files  = 'Slider/*.swift', 'Slider/**/*.swift'

end
