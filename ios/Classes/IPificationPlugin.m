#import "IPificationPlugin.h"
#if __has_include(<ipification_plugin/ipification_plugin-Swift.h>)
#import <ipification_plugin/ipification_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ipification_plugin-Swift.h"
#endif

@implementation IPificationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIPificationPlugin registerWithRegistrar:registrar];
}
@end
