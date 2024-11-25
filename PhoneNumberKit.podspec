Pod::Spec.new do |s|
  s.name             = 'PhoneNumberKit'
  s.version          = '4.0.1'
  s.summary          = 'Swift framework for working with phone numbers'
  s.description      = <<-DESC
                        A Swift framework for parsing, formatting and validating international phone numbers. Inspired by Google's libphonenumber.
  DESC

  s.homepage         = 'https://github.com/marmelroy/PhoneNumberKit'
  s.license          = 'MIT'
  s.author           = { 'Roy Marmelstein' => 'marmelroy@gmail.com' }
  s.source           = { git: 'https://github.com/marmelroy/PhoneNumberKit.git', tag: s.version.to_s }

  s.requires_arc = true
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '4.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.swift_version = '5.0'

  s.subspec 'PhoneNumberKitCore' do |core|
    core.ios.deployment_target = '12.0'
    core.osx.deployment_target = '10.13'
    core.tvos.deployment_target = '12.0'
    core.watchos.deployment_target = '4.0'
    core.source_files = 'PhoneNumberKit/*.{swift}'
    core.resources = [
      'PhoneNumberKit/Resources/PhoneNumberMetadata.json'
    ]
    core.resource_bundles = { 'PhoneNumberKitPrivacy' => ['PhoneNumberKit/Resources/PrivacyInfo.xcprivacy'] }
  end

  s.subspec 'UIKit' do |ui|
    ui.dependency 'PhoneNumberKit/PhoneNumberKitCore'
    ui.ios.deployment_target = '12.0'
    ui.source_files = 'PhoneNumberKit/UI/*.{swift}'
  end
end
