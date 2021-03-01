import Flutter
import UIKit



public class SwiftIpSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ip_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftIpSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if(call.method == "doAuthentication"){
        let arg =   call.arguments as? Dictionary<String, Any>
        let phone = arg!["login_hint"] as? String
        
        AuthenticationHelper.authent(login_hint: phone! , success: { s in
            result(s)
        }, fail: {f in
            result(FlutterError(code:f.error_code.rawValue,message: f.error_message, details: nil))
        })

    }else if(call.method == "checkCoverage"){
        AuthenticationHelper.checkCoverage(success:{s in
             result(s)
        }, fail: {f in
             result(FlutterError(code:f.error_code.rawValue,message: f.error_message, details: nil))
        })
    }else if(call.method == "getConfiguration"){
        let arg =   call.arguments as? Dictionary<String, Any>
        let configName = arg!["config_name"] as? String
        result(AuthenticationHelper.getConfigurationByName(configName:configName!))
    }
   
  }
    
}

