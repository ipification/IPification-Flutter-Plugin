import Flutter
import UIKit
import IPificationSDK

public class IPificationPlugin: NSObject, FlutterPlugin {

  var authenticationHelper: AuthenticationHelper? = nil

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ipification_plugin", binaryMessenger: registrar.messenger())
    let instance = IPificationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
        
    case "checkCoverage":
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.checkCoverage(success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })
        
    case "checkCoverageWithPhoneNumber":
        guard let arg = call.arguments as? [String: Any],
              let phoneNumber = arg["phone_number"] as? String,
              !phoneNumber.isEmpty else {
            result(FlutterError(code: "validation_failed", message: "phone_number cannot be empty", details: nil))
            return
        }
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.checkCoverage(phoneNumber: phoneNumber, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })
        
    case "doAuthentication":
        let arg = call.arguments as? [String: Any]
        let loginHint = arg?["login_hint"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthentication(login_hint: loginHint, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })
        
    case "doAuthenticationWithChannel":
        let arg = call.arguments as? [String: Any]
        let loginHint = arg?["login_hint"] as? String ?? ""
        let channel = arg?["channel"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthentication(login_hint: loginHint, channel: channel, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })
        
    case "doIMAuthentication":
        let arg = call.arguments as? [String: Any]
        let channel = arg?["channel"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthentication(channel: channel, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })
        
    case "addQueryParam":
        guard let arg = call.arguments as? [String: Any],
              let key = arg["key"] as? String,
              let paramValue = arg["value"] as? String else {
            return // Silently ignore invalid arguments
        }
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.addQueryParam(key: key, value: paramValue)
        
    case "setState":
        let arg = call.arguments as? [String: Any]
        let paramValue = arg?["value"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.setState(value: paramValue)
        
    case "setScope":
        let arg = call.arguments as? [String: Any]
        let paramValue = arg?["value"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.setScope(value: paramValue)
        
    case "getConfiguration":
        guard let arg = call.arguments as? [String: Any],
              let configName = arg["config_name"] as? String else {
            result(nil)
            return
        }
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        result(authenticationHelper?.getConfigurationByName(configName: configName))
        
    case "getClientId":
        result(IPConfiguration.sharedInstance.CLIENT_ID)
        
    case "getRedirectUri":
        result(IPConfiguration.sharedInstance.REDIRECT_URI)
        
    case "setClientId":
        IPConfiguration.sharedInstance.SDK_TYPE_VALUE = "flutter"
        let arg = call.arguments as? [String: Any]
        if let clientValue = arg?["value"] as? String, !clientValue.isEmpty {
            IPConfiguration.sharedInstance.CLIENT_ID = clientValue
        }
        
    case "setRedirectUri":
        let arg = call.arguments as? [String: Any]
        if let redirectValue = arg?["value"] as? String, !redirectValue.isEmpty {
            IPConfiguration.sharedInstance.REDIRECT_URI = redirectValue
        }
        
    case "setEnv":
        let arg = call.arguments as? [String: Any]
        if let envValue = arg?["value"] as? String {
            IPConfiguration.sharedInstance.ENV = (envValue == "production") ? .PRODUCTION : .SANDBOX
        }
        
    case "setCheckCoverageUrl":
        let arg = call.arguments as? [String: Any]
        if let coverageValue = arg?["value"] as? String, !coverageValue.isEmpty {
            IPConfiguration.sharedInstance.customUrls = true
            IPConfiguration.sharedInstance.COVERAGE_URL = coverageValue
        }
        
    case "setAuthorizationUrl":
        let arg = call.arguments as? [String: Any]
        if let authValue = arg?["value"] as? String, !authValue.isEmpty {
            IPConfiguration.sharedInstance.customUrls = true
            IPConfiguration.sharedInstance.AUTHORIZATION_URL = authValue
        }
        
    case "generateState":
        result(IPConfiguration.sharedInstance.generateState())
        
    case "showNotification":
        // Do nothing, as per original implementation
        break
    case "enableLog":
        print("enableLog")
        IPConfiguration.sharedInstance.debug = true
        
    case "getLog":
        print("log", IPConfiguration.sharedInstance.COVERAGE_URL)
        result(IPConfiguration.sharedInstance.log)
        
    case "updateLocale":
        let arg = call.arguments as? [String: Any]
        IPificationLocale.sharedInstance.updateScreen(
            titleBar: arg?["titleBar"] as? String ?? "IPification",
            title: arg?["mainTitle"] as? String ?? "Phone Number Verify",
            description: arg?["description"] as? String ?? "Please tap on the preferred messaging app then follow our instruction on the screen",
            whatsappBtnText: arg?["whatsappBtnText"] as? String ?? "Quick Login via Whatsapp",
            viberBtnText: arg?["viberBtnText"] as? String ?? "Quick Login via Viber",
            telegramBtnText: arg?["telegramBtnText"] as? String ?? "Quick Login via Telegram",
            cancelBtnText: arg?["cancelBtnText"] as? String ?? "Cancel"
        )
        
    case "updateTheme":
        guard let arg = call.arguments as? [String: Any],
              let toolbarTitleColor = arg["toolbarTitleColor"] as? String,
              let cancelBtnColor = arg["cancelBtnColor"] as? String,
              let titleColor = arg["titleColor"] as? String,
              let descColor = arg["descColor"] as? String,
              let backgroundColor = arg["backgroundColor"] as? String else {
            return
        }
        IPificationTheme.sharedInstance.updateScreen(
            toolbarTitleColor: hexStringToUIColor(hex: toolbarTitleColor),
            cancelBtnColor: hexStringToUIColor(hex: cancelBtnColor),
            titleColor: hexStringToUIColor(hex: titleColor),
            descColor: hexStringToUIColor(hex: descColor),
            backgroundColor: hexStringToUIColor(hex: backgroundColor)
        )
        
    default:
        result(FlutterMethodNotImplemented)
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
