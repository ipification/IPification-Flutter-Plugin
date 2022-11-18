import Flutter
import UIKit
import IPificationSDK



public class SwiftIPificationPlugin: NSObject, FlutterPlugin {
  var authenticationHelper: AuthenticationHelper? = nil
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ipification_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftIPificationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if(call.method == "checkCoverage"){
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.checkCoverage(success:{s in
            self.authenticationHelper = nil
            result(s)
        }, fail: {f in
            self.authenticationHelper = nil
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
            self.authenticationHelper = nil
            result(s)
        }, fail: {f in
            self.authenticationHelper = nil
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
    else if(call.method == "doAuthenticationWithChannel"){
        var channel = ""
        var login_hint = ""
        let arg =   call.arguments as? Dictionary<String, Any>
        if(arg != nil && arg!["login_hint"] != nil){
          login_hint = arg!["login_hint"] as? String ?? ""
        }
        if(arg != nil && arg!["channel"] != nil){
          channel = arg!["channel"] as? String ?? ""
        }
        
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthentication(login_hint: login_hint , channel: channel, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: {f in
            self.authenticationHelper = nil
            result(FlutterError(code:f.error_code.rawValue, message: f.error_message, details: nil))
        })

    }
    else if(call.method == "doIMAuthentication"){
        var channel = ""
        let arg =   call.arguments as? Dictionary<String, Any>
        
        if(arg != nil && arg!["channel"] != nil){
          channel = arg!["channel"] as? String ?? ""
        }
        
        if(authenticationHelper == nil){
          authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthentication(channel: channel, success: { s in
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
      result(IPConfiguration.sharedInstance.CLIENT_ID)
    }
    else if(call.method=="getRedirectUri"){
      result(IPConfiguration.sharedInstance.REDIRECT_URI)
    }
    else if(call.method=="setClientId"){
      let arg = call.arguments as? Dictionary<String, Any>
      let clientValue = arg!["value"] as? String
      if (clientValue != ""){
        IPConfiguration.sharedInstance.CLIENT_ID = clientValue ?? ""
      }
    }
    else if(call.method=="setRedirectUri"){
      let arg = call.arguments as? Dictionary<String, Any>
      let redirectValue = arg!["value"] as? String
      if (redirectValue != ""){
        IPConfiguration.sharedInstance.REDIRECT_URI = redirectValue ?? ""
      }
    }
    else if(call.method=="setEnv"){
      let arg = call.arguments as? Dictionary<String, Any>
      let envValue = arg!["value"] as? String
      if (envValue == "production"){
        IPConfiguration.sharedInstance.ENV = IPEnvironment.PRODUCTION
      }else{
        IPConfiguration.sharedInstance.ENV = IPEnvironment.SANDBOX
      }
    }
    else if(call.method=="setCheckCoverageUrl"){
      let arg = call.arguments as? Dictionary<String, Any>
      let coverageValue = arg!["value"] as? String
      if (coverageValue != ""){
        IPConfiguration.sharedInstance.customUrls = true
        IPConfiguration.sharedInstance.COVERAGE_URL = coverageValue ?? ""
      }
    }
    else if(call.method=="setAuthorizationUrl"){
      
      let arg = call.arguments as? Dictionary<String, Any>
      let authValue = arg!["value"] as? String
      if (authValue != ""){
        IPConfiguration.sharedInstance.customUrls = true
        IPConfiguration.sharedInstance.AUTHORIZATION_URL = authValue ?? ""
      }
    }
    else if(call.method=="generateState"){
      result(IPConfiguration.sharedInstance.generateState())
    }
    else if(call.method=="showNotification"){
      // do nothing
    }
    else if(call.method=="enableLog"){
      print("enableLog")
      IPConfiguration.sharedInstance.debug = true
    }
    else if(call.method=="getLog"){
      print("log", IPConfiguration.sharedInstance.COVERAGE_URL)
      result(IPConfiguration.sharedInstance.log)
    }
    else if(call.method=="updateLocale"){
      let arg = call.arguments as? Dictionary<String, Any>
      let titleBar = arg!["titleBar"] as? String
      let title = arg!["mainTitle"] as? String
      let description = arg!["description"] as? String
      let whatsappBtnText = arg!["whatsappBtnText"] as? String
      let viberBtnText = arg!["viberBtnText"] as? String
      let telegramBtnText = arg!["telegramBtnText"] as? String
      let cancelBtnText = arg!["cancelBtnText"] as? String
      IPificationLocale.sharedInstance.updateScreen(
        titleBar: titleBar ?? "IPification", 
        title: title ?? "Phone Number Verify", 
        description: description ?? "Please tap on the preferred messaging app then follow our instruction on the screen", 
        whatsappBtnText: whatsappBtnText ?? "Quick Login via Whatsapp", 
        viberBtnText : viberBtnText ?? "Quick Login via Viber", 
        telegramBtnText : telegramBtnText ?? "Quick Login via Telegram", 
        cancelBtnText:cancelBtnText ?? "Cancel"
      )
    }
    else if(call.method=="updateTheme"){
      let arg = call.arguments as? Dictionary<String, Any>
      let toolbarTitleColor = arg!["toolbarTitleColor"] as? String
      let cancelBtnColor = arg!["cancelBtnColor"] as? String
      let titleColor = arg!["titleColor"] as? String
      let descColor = arg!["descColor"] as? String
      let backgroundColor = arg!["backgroundColor"] as? String
       IPificationTheme.sharedInstance.updateScreen(
            toolbarTitleColor: hexStringToUIColor(hex: toolbarTitleColor as! String),
            cancelBtnColor: hexStringToUIColor(hex: cancelBtnColor as! String),
            titleColor: hexStringToUIColor(hex: titleColor as! String),
            descColor: hexStringToUIColor(hex: descColor as! String),
            backgroundColor: hexStringToUIColor(hex: backgroundColor as! String))
    }
    
  }

  func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

