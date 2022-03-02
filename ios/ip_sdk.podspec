#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ip_sdk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name = "ip_sdk"
  s.version = "2.0.0"
  s.summary = "IPIfication SDK"
  s.description = "IPIfication SDK"
  s.homepage = "https://ipification.com"
  s.license = { :file => "../LICENSE" }
  s.author = { "IPification" => "info@ipification.com" }
  s.source = { :path => "." }
  s.source_files = "Classes/**/*"
  s.dependency "Flutter"
  s.platform = :ios, "9.0"
  s.preserve_paths = "IPificationSDK.xcframework"
  s.xcconfig = { "OTHER_LDFLAGS" => "-framework IPificationSDK" }
  s.vendored_frameworks = "IPificationSDK.xcframework"

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386" }
  s.swift_version = "5.0"
end
