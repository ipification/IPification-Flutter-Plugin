import Flutter
import UIKit
import IPificationSDK

/// Flutter plugin entry point for IPification authentication services on iOS.
///
/// This class owns the method channel exposed to Dart, maps Flutter method calls
/// to native SDK operations, and returns normalized results to Flutter.
public class IPificationPlugin: NSObject, FlutterPlugin {

  /// Helper used for the current authentication or coverage operation.
  var authenticationHelper: AuthenticationHelper? = nil

  /// Registers the plugin method channel with the Flutter engine.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ipification_plugin", binaryMessenger: registrar.messenger())
    let instance = IPificationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Handles method-channel calls from the Dart side of the plugin.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)

    case "setConfiguration":
        result(nil)
        
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

    case "doAuthenticationWithChannels":
        let arg = call.arguments as? [String: Any]
        let loginHint = arg?["login_hint"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.doAuthenticationWithChannels(loginHint: loginHint, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })

    case "startSMSAuthentication":
        guard let arg = call.arguments as? [String: Any],
              let phoneNumber = arg["phone_number"] as? String,
              !phoneNumber.isEmpty else {
            result(FlutterError(code: "validation_failed", message: "phone_number cannot be empty", details: nil))
            return
        }
        let scope = arg["scope"] as? String
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.startSMSAuthentication(phoneNumber: phoneNumber, scope: scope, success: { s in
            self.authenticationHelper = nil
            result(s)
        }, fail: { f in
            self.authenticationHelper = nil
            result(FlutterError(code: f.error_code.rawValue, message: f.error_message, details: nil))
        })

    case "verifySMSOTP":
        guard let arg = call.arguments as? [String: Any],
              let otpCode = arg["otp_code"] as? String,
              let authReqId = arg["auth_req_id"] as? String,
              let nonce = arg["nonce"] as? String,
              !otpCode.isEmpty,
              !authReqId.isEmpty,
              !nonce.isEmpty else {
            result(FlutterError(code: "validation_failed", message: "otp_code, auth_req_id, and nonce are required", details: nil))
            return
        }
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.verifySMSOTP(otpCode: otpCode, authReqId: authReqId, nonce: nonce, success: { s in
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
            result(FlutterError(code: "validation_failed", message: "key and value are required", details: nil))
            return
        }
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.addQueryParam(key: key, value: paramValue)
        result(nil)
        
    case "setState":
        let arg = call.arguments as? [String: Any]
        let paramValue = arg?["value"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.setState(value: paramValue)
        result(nil)
        
    case "setScope":
        let arg = call.arguments as? [String: Any]
        let paramValue = arg?["value"] as? String ?? ""
        if authenticationHelper == nil {
            authenticationHelper = AuthenticationHelper()
        }
        authenticationHelper?.setScope(value: paramValue)
        result(nil)

    case "setAuthChannels":
        guard let arg = call.arguments as? [String: Any],
              let values = arg["channels"] as? [String],
              !values.isEmpty else {
            result(FlutterError(code: "validation_failed", message: "channels cannot be empty", details: nil))
            return
        }
        var channels: [AuthChannel] = []
        for value in values {
            switch value.uppercased() {
            case "IP":
                channels.append(.IP)
            case "SMS":
                channels.append(.SMS)
            case "TS43":
                result(FlutterError(code: "unsupported_channel", message: "TS43 is not available in the bundled iOS SDK 2.2.0 framework.", details: nil))
                return
            default:
                result(FlutterError(code: "validation_failed", message: "Unsupported auth channel: \(value)", details: nil))
                return
            }
        }
        IPConfiguration.sharedInstance.AUTH_CHANNELS = channels
        result(nil)

    case "setSMSConfiguration":
        let arg = call.arguments as? [String: Any]
        if let value = arg?["sandbox_backend_url"] as? String, !value.isEmpty {
            IPConfiguration.sharedInstance.SMS_BACKEND_URL_SANDBOX = value
        }
        if let value = arg?["production_backend_url"] as? String, !value.isEmpty {
            IPConfiguration.sharedInstance.SMS_BACKEND_URL_PRODUCTION = value
        }
        if let value = arg?["auth_path"] as? String, !value.isEmpty {
            IPConfiguration.sharedInstance.SMS_AUTH_PATH = value
        }
        if let value = arg?["token_path"] as? String, !value.isEmpty {
            IPConfiguration.sharedInstance.SMS_TOKEN_PATH = value
        }
        if let value = arg?["scope"] as? String, !value.isEmpty {
            IPConfiguration.sharedInstance.SMS_SCOPE_VERIFY_PHONE = value
        }
        if let value = arg?["server_id"] as? String, !value.isEmpty {
            IPConfiguration.sharedInstance.SMS_SERVER_ID = value
        }
        result(nil)

    case "setTS43Configuration":
        result(FlutterError(code: "unsupported_channel", message: "TS43 configuration is not available in the bundled iOS SDK 2.2.0 framework.", details: nil))
        
    case "getClientId":
        result(IPConfiguration.sharedInstance.CLIENT_ID)
        
    case "getRedirectUri":
        result(IPConfiguration.sharedInstance.REDIRECT_URI)
        
    case "setClientId":
        let arg = call.arguments as? [String: Any]
        if let clientValue = arg?["value"] as? String, !clientValue.isEmpty {
            IPConfiguration.sharedInstance.CLIENT_ID = clientValue
        }
        result(nil)
        
    case "setRedirectUri":
        let arg = call.arguments as? [String: Any]
        if let redirectValue = arg?["value"] as? String, !redirectValue.isEmpty {
            IPConfiguration.sharedInstance.REDIRECT_URI = redirectValue
        }
        result(nil)
        
    case "setEnv":
        let arg = call.arguments as? [String: Any]
        if let envValue = arg?["value"] as? String {
            IPConfiguration.sharedInstance.ENV = (envValue == "production") ? .PRODUCTION : .SANDBOX
        }
        result(nil)
        
    case "setCheckCoverageUrl":
        let arg = call.arguments as? [String: Any]
        if let coverageValue = arg?["value"] as? String, !coverageValue.isEmpty {
            IPConfiguration.sharedInstance.customUrls = true
            IPConfiguration.sharedInstance.COVERAGE_URL = coverageValue
        }
        result(nil)
        
    case "setAuthorizationUrl":
        let arg = call.arguments as? [String: Any]
        if let authValue = arg?["value"] as? String, !authValue.isEmpty {
            IPConfiguration.sharedInstance.customUrls = true
            IPConfiguration.sharedInstance.AUTHORIZATION_URL = authValue
        }
        result(nil)

    case "setBaseUrl":
        let arg = call.arguments as? [String: Any]
        if let baseUrl = arg?["value"] as? String, !baseUrl.isEmpty {
            IPConfiguration.sharedInstance.BASE_URL = baseUrl
        }
        result(nil)
        
        
    case "generateState":
        result(IPConfiguration.sharedInstance.generateState())
        
    case "showNotification":
        // Do nothing, as per original implementation
        result(nil)
    case "enableLog":
        print("enableLog")
        IPConfiguration.sharedInstance.debug = true
        result(nil)
        
    case "getLog":
        print("log", IPConfiguration.sharedInstance.COVERAGE_URL)
        result(IPLogs.sharedInstance.log)
        
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
        result(nil)
        
    case "updateTheme":
        guard let arg = call.arguments as? [String: Any],
              let toolbarTitleColor = arg["toolbarTitleColor"] as? String,
              let cancelBtnColor = arg["cancelBtnColor"] as? String,
              let titleColor = arg["titleColor"] as? String,
              let descColor = arg["descColor"] as? String,
              let backgroundColor = arg["backgroundColor"] as? String else {
            result(FlutterError(code: "validation_failed", message: "theme colors are required", details: nil))
            return
        }
        IPificationTheme.sharedInstance.updateScreen(
            toolbarTitleColor: hexStringToUIColor(hex: toolbarTitleColor),
            cancelBtnColor: hexStringToUIColor(hex: cancelBtnColor),
            titleColor: hexStringToUIColor(hex: titleColor),
            descColor: hexStringToUIColor(hex: descColor),
            backgroundColor: hexStringToUIColor(hex: backgroundColor)
        )
        result(nil)
        
    default:
        result(FlutterMethodNotImplemented)
    }
  }

  /// Converts a six-digit hex color string into a `UIColor`.
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
