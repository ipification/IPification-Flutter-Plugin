#import "IpSdkPlugin.h"
#if __has_include(<ip_sdk/ip_sdk-Swift.h>)
#import <ip_sdk/ip_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ip_sdk-Swift.h"
#endif

@implementation IpSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIpSdkPlugin registerWithRegistrar:registrar];
}
@end
