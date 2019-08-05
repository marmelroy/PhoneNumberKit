#
# Be sure to run `pod lib lint PhoneNumberKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PhoneNumberKit"
  s.version          = "3.0.0"
  s.summary          = "Swift framework for working with phone numbers"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                        A Swift framework for parsing, formatting and validating international phone numbers. Inspired by Google's libphonenumber.
                       DESC

  s.homepage         = "https://github.com/marmelroy/PhoneNumberKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Roy Marmelstein" => "marmelroy@gmail.com" }
  s.source           = { :git => "https://github.com/marmelroy/PhoneNumberKit.git", :tag => s.version.to_s }
  s.social_media_url   = "http://twitter.com/marmelroy"


  s.requires_arc = true

  s.ios.frameworks = 'CoreTelephony'
  s.osx.frameworks = 'CoreTelephony'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.swift_version = '5.0'

  s.subspec 'PhoneNumberKitCore' do |core|
    core.ios.deployment_target = '8.0'
    core.osx.deployment_target = '10.10'
    core.tvos.deployment_target = '9.0'
    core.watchos.deployment_target = '2.0'
    core.source_files = "PhoneNumberKit/*.{swift}"
    core.resources = "PhoneNumberKit/Resources/PhoneNumberMetadata.json"
  end

  s.subspec 'UIKit' do |ui|
    ui.dependency 'PhoneNumberKit/PhoneNumberKitCore'
    ui.ios.deployment_target = '8.0'
    ui.tvos.deployment_target = '9.0'
    ui.source_files = 'PhoneNumberKit/UI/'
  end

end
