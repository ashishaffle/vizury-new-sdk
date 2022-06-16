Pod::Spec.new do |spec|

  spec.name         = "VizuryEventLoggerNew"
  spec.version      = "0.0.1"
  spec.summary      = "A CocoaPods library written in C"

  spec.description  = <<-DESC
This CocoaPods library helps you perform calculation.
                   DESC

  spec.homepage     = "https://github.com/ashishaffle/vizury-new-sdk"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Ashish Saxena" => "ashish.saxena@affle.com" }

  spec.ios.deployment_target = "12.1"
  spec.swift_version = "4.2"

  spec.source        = { :git => "https://github.com/ashishaffle/vizury-new-sdk.git", :tag => "#{spec.version}" }
  spec.source_files  = "VizuryEventLogger/**/*.{h,m,swift}"

end