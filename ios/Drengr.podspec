Pod::Spec.new do |s|
  s.name             = 'Drengr'
  s.version          = '0.1.0'
  s.summary          = 'Zero-code network analytics for iOS.'
  s.description      = 'One call captures every URLSession exchange with secret/PII redaction in-process, no track() calls.'
  s.homepage         = 'https://drengr.dev'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Drengr' => 'sharminsirajudeen11@gmail.com' }
  s.source           = { :git => 'https://github.com/SharminSirajudeen/drengr-community.git', :tag => "ios-v#{s.version}" }
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '11.0'
  s.swift_version    = '5.7'
  s.source_files     = 'Sources/Drengr/**/*.swift'
end
