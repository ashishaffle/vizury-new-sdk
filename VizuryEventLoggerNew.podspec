Pod::Spec.new do |s|

 s.name         = "VizuryEventLoggerNew"
 s.version      = "1.6.7"
 s.summary      = "Vizury Event Logger for iOS"
 s.description  = <<-DESC
                    Vizury is a mobile marketing automation company. This framework helps to track events of users.
                    DESC

 s.homepage     = "https://affle.com"
 s.documentation_url = 'https://github.com/ashishaffle/vizury-new-sdk'
 s.license      = { :type => 'Commercial', :file => 'LICENSE' }
 s.author       = { 'Ayon Chowdhury' => 'ayon.chowdhury@affle.com' }
 s.platform     = :ios
 s.ios.deployment_target = '12.1'
 spec.swift_version = "4.2"

 s.source       = {
                        :git => 'https://github.com/ashishaffle/vizury-new-sdk.git',
                        :tag => 'VizuryEventLoggerNew-' + s.version.to_s
                    }
 spec.source_files  = "VizuryEventLogger/**/*.{h,m,swift}"

 

end
