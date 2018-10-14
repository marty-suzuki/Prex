#
#  Be sure to run `pod spec lint Sica.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Prex"
  s.version      = "0.2.0"
  s.summary      = "Prex is unidirectional data flow architecture with MVP and Flux"
  s.homepage     = "https://github.com/marty-suzuki/Prex"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Taiki Suzuki" => "s1180183@gmail.com" }
  s.ios.deployment_target  = "10.0"
  s.tvos.deployment_target = "10.0"
  s.osx.deployment_target  = "10.10"
  s.watchos.deployment_target = "3.0"
  s.source       = { :git => "https://github.com/marty-suzuki/Prex.git", :tag => "#{s.version}" }
  s.social_media_url = 'https://twitter.com/marty_suzuki'
  s.source_files = "Sources/**/*.{swift}"
  s.swift_version = '4.2'
end
