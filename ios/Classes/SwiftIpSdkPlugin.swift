import Flutter
import UIKit
import IPificationSDK



public class SwiftIpSdkPlugin: NSObject, FlutterPlugin {
  var authenticationHelper: AuthenticationHelper? = nil
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ip_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftIpSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if(call.method == "checkCoverage"){
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.checkCoverage(success:{s in
             result(s)
        }, fail: {f in
             result(FlutterError(code:f.error_code.rawValue,message: f.error_message, details: nil))
        })
    }
    else if(call.method == "checkCoverageWithPhoneNumber"){
        var phoneNumber = ""
        let arg =   call.arguments as? Dictionary<String, Any>
        if(arg != nil && arg!["phone_number"] != nil){
          phoneNumber = arg!["phone_number"] as? String ?? ""
        }
        if(phoneNumber == ""){
           result(FlutterError(code:"validation_failed",message: "phone_number cannot be empty", details: nil))
           return
        }
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.checkCoverage(phoneNumber : phoneNumber, success:{s in
             result(s)
        }, fail: {f in
             result(FlutterError(code:f.error_code.rawValue,message: f.error_message, details: nil))
        })
    }  
    else if(call.method == "doAuthentication"){
        var login_hint = ""
        let arg =   call.arguments as? Dictionary<String, Any>
        if(arg != nil && arg!["login_hint"] != nil){
          login_hint = arg!["login_hint"] as? String ?? ""
        }
        
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthentication(login_hint: login_hint , success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: {f in
            self.authenticationHelper = nil
            result(FlutterError(code:f.error_code.rawValue, message: f.error_message, details: nil))
        })

    }
    
    else if(call.method == "addQueryParam"){
        let arg =  call.arguments as? Dictionary<String, Any>
        var key = arg!["key"] as? String
        var paramValue = arg!["value"] as? String
        if(key == nil){
          key = ""
        }
        if(paramValue == nil){
          paramValue = ""
        }
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.addQueryParam(key: key!, value: paramValue!)
    }
    else if(call.method == "setState"){
        let arg =  call.arguments as? Dictionary<String, Any>
        var paramValue = arg!["value"] as? String
      
        if(paramValue == nil){
          paramValue = ""
        }
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.setState(value: paramValue!)
    }
    else if(call.method == "setScope"){
        let arg =  call.arguments as? Dictionary<String, Any>
        var paramValue = arg!["value"] as? String
      
        if(paramValue == nil){
          paramValue = ""
        }
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.setScope(value: paramValue!)
    }
    else if(call.method == "getConfiguration"){
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        let arg = call.arguments as? Dictionary<String, Any>
        let configName = arg!["config_name"] as? String
        result(authenticationHelper?.getConfigurationByName(configName:configName!))
    }
    else if(call.method=="getClientId"){
      result(IPConfigurationFile.sharedInstance.CLIENT_ID)
    }
    else if(call.method=="getRedirectUri"){
      result(IPConfigurationFile.sharedInstance.REDIRECT_URI)
    }
    else if(call.method=="setClientId"){
      let arg = call.arguments as? Dictionary<String, Any>
      let clientValue = arg!["value"] as? String
      if (clientValue != ""){
        IPConfigurationFile.sharedInstance.CLIENT_ID = clientValue ?? ""
      }
    }
    else if(call.method=="setRedirectUri"){
      let arg = call.arguments as? Dictionary<String, Any>
      let redirectValue = arg!["value"] as? String
      if (redirectValue != ""){
        IPConfigurationFile.sharedInstance.REDIRECT_URI = redirectValue ?? ""
      }
    }
    else if(call.method=="setCheckCoverageUrl"){
      let arg = call.arguments as? Dictionary<String, Any>
      let coverageValue = arg!["value"] as? String
      if (coverageValue != ""){
        IPConfigurationFile.sharedInstance.COVERAGE_URL = coverageValue ?? ""
      }
    }
    else if(call.method=="setAuthorizationUrl"){
      let arg = call.arguments as? Dictionary<String, Any>
      let authValue = arg!["value"] as? String
      if (authValue != ""){
        IPConfigurationFile.sharedInstance.AUTHORIZATION_URL = authValue ?? ""
      }
    }
   
  }
    
}

