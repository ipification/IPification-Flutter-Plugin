//
//  AuthenticationHelper.swift
//  ipification_plugin
//
//  Created by ipification on 1/20/21.
//

import Foundation
import UIKit
import Flutter
import IPificationSDK


/// Wraps the iOS IPification SDK and normalizes SDK callbacks for the Flutter bridge.
class AuthenticationHelper {
    /// Builder reused for authorization request options configured from Flutter.
    var authBuilder : AuthorizationRequest.Builder
    private var multiAuthCallback: MultiAuthBridgeCallback?
    private var smsCallback: SMSBridgeCallback?

    /// Creates a helper with a fresh authorization request builder.
    init(){
        authBuilder = AuthorizationRequest.Builder()
    }

    /// Checks whether IPification coverage is available for a specific phone number.
    ///
    /// - Parameters:
    ///   - phoneNumber: Phone number to check with the native SDK.
    ///   - success: Called with the raw SDK response when the coverage lookup succeeds.
    ///   - fail: Called with a normalized plugin error when the coverage lookup fails.
    func checkCoverage(phoneNumber: String, success:@escaping(String)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let coverageService = CoverageService()
        coverageService.callbackFailed = { (error) -> Void in
            print(error.localizedDescription)
            var temp = AuthenticationError()
            temp.error_code = ErrorCode.COVERAGE_UNAVAILABLE
            temp.error_message = error.localizedDescription
            fail(temp)
            
        }
        coverageService.callbackSuccess = { (response) -> Void in
            print("check coverage result: ", response.getPlainResponse())
            success(response.getPlainResponse())
            
        }
        coverageService.checkCoverage(phoneNumber: phoneNumber)
    }

    /// Checks whether IPification coverage is available for the current device context.
    ///
    /// - Parameters:
    ///   - success: Called with the raw SDK response when the coverage lookup succeeds.
    ///   - fail: Called with a normalized plugin error when the coverage lookup fails.
    func checkCoverage(success:@escaping(String)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let coverageService = CoverageService()
        coverageService.callbackFailed = { (error) -> Void in
            print(error.localizedDescription)
            var temp = AuthenticationError()
            temp.error_code = ErrorCode.COVERAGE_UNAVAILABLE
            temp.error_message = error.localizedDescription
            fail(temp)
            
        }
        coverageService.callbackSuccess = { (response) -> Void in
            print("check coverage result: ", response.getPlainResponse())
            success(response.getPlainResponse())
            
        }
        coverageService.checkCoverage()
    }
    
    /// Performs cellular authorization with an optional login hint.
    ///
    /// - Parameters:
    ///   - login_hint: Optional login hint added to the authorization request.
    ///   - success: Called with the raw SDK response when authorization succeeds.
    ///   - fail: Called with a normalized plugin error when authorization fails or is canceled.
    func doAuthentication(login_hint:String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let authorizationService = AuthorizationService()
        authorizationService.callbackFailed = { (error) -> Void in
            print("authorized failed ", error.localizedDescription)
            var temp = AuthenticationError()
            temp.error_code = ErrorCode.AUTHENTICATE_FAIL
            temp.error_message = error.localizedDescription
            fail(temp)
            
        }
        authorizationService.callbackIMCanceled = { () -> Void in
            print("authorized canceled")
            var error = AuthenticationError()
            error.error_code = ErrorCode.AUTHENTICATE_IM_CANCEL
            fail(error)
        }
        authorizationService.callbackSuccess = { (response) -> Void in            
            if(response.getCode() != nil){
                success(response.getPlainResponse())
            }else{
                var temp = AuthenticationError()
                temp.error_code = ErrorCode.AUTHENTICATE_FAIL
                temp.error_message = response.getError()
                fail(temp)
            }
        }
        
        
        if(login_hint.isEmpty == false){
            print("login_hint", login_hint)
            authBuilder.addQueryParam(key: "login_hint", value: login_hint)
        }
        authorizationService.startAuthorization(authBuilder.build())
    }


    /// Starts authorization with optional login hint and channel values.
    ///
    /// - Parameters:
    ///   - login_hint: Optional login hint added to the authorization request.
    ///   - channel: Optional channel value added to the authorization request.
    ///   - success: Called with the raw SDK response when authorization succeeds.
    ///   - fail: Called with a normalized plugin error when authorization fails or is canceled.
    func doAuthentication(login_hint:String, channel: String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
       
        let authorizationService = AuthorizationService()
        authorizationService.callbackFailed = { (e) -> Void in
            print("authorized failed ", e.localizedDescription)
            var error = AuthenticationError()
            error.error_code = ErrorCode.AUTHENTICATE_FAIL
            error.error_message = e.localizedDescription
            fail(error)
            
        }
        authorizationService.callbackIMCanceled = { () -> Void in
            print("authorized canceled")
            var error = AuthenticationError()
            error.error_code = ErrorCode.AUTHENTICATE_IM_CANCEL
            fail(error)
        }
        authorizationService.callbackSuccess = { (response) -> Void in
            
            if(response.getCode() != nil){
                success(response.getPlainResponse())
            }else{
                var temp = AuthenticationError()
                temp.error_code = ErrorCode.AUTHENTICATE_FAIL
                temp.error_message = response.getError()
                fail(temp)
            }
        }
        

        if(login_hint.isEmpty == false){
            print("login_hint", login_hint)
            authBuilder.addQueryParam(key: "login_hint", value: login_hint)
        }

        if(channel.isEmpty == false){
            print("channel", channel)
            authBuilder.addQueryParam(key: "channel", value: channel)
        }
        let storyboard : UIStoryboard? = UIStoryboard.init(name: "Main", bundle: nil);
        let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let controller : FlutterViewController = window.rootViewController as! FlutterViewController
        authorizationService.startAuthorization(viewController: controller, authBuilder.build())
    }

    /// Starts Instant Messaging authorization for the supplied channel.
    ///
    /// - Parameters:
    ///   - channel: Optional IM channel value added to the authorization request.
    ///   - success: Called with the raw SDK response when authorization succeeds.
    ///   - fail: Called with a normalized plugin error when authorization fails or is canceled.
    func doAuthentication(channel: String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let authorizationService = AuthorizationService()
        authorizationService.callbackFailed = { (error) -> Void in
            print("authorized failed ", error.localizedDescription)
            var temp = AuthenticationError()
            temp.error_code = ErrorCode.AUTHENTICATE_FAIL
            temp.error_message = error.localizedDescription
            fail(temp)
            
        }
        authorizationService.callbackIMCanceled = { () -> Void in
            print("authorized canceled")
            var error = AuthenticationError()
            error.error_code = ErrorCode.AUTHENTICATE_IM_CANCEL
            fail(error)
        }
        authorizationService.callbackSuccess = { (response) -> Void in            
            if(response.getCode() != nil){
                success(response.getPlainResponse())
            }else{
                var temp = AuthenticationError()
                temp.error_code = ErrorCode.AUTHENTICATE_FAIL
                temp.error_message = response.getError()
                fail(temp)
            }
        }
        
        
        
        if(channel.isEmpty == false){
            print("channel", channel)
            authBuilder.addQueryParam(key: "channel", value: channel)
        }
        let storyboard : UIStoryboard? = UIStoryboard.init(name: "Main", bundle: nil);
        let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let controller : FlutterViewController = window.rootViewController as! FlutterViewController
        authorizationService.startIMAuthorization(viewController: controller, authBuilder.build())
    }

    /// Starts configured-channel authentication and returns either an auth response or OTP challenge.
    func doAuthenticationWithChannels(loginHint:String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let authorizationService = AuthorizationService()
        if loginHint.isEmpty == false {
            authBuilder.addQueryParam(key: "login_hint", value: loginHint)
        }

        let callback = MultiAuthBridgeCallback(success: success, fail: fail)
        multiAuthCallback = callback
        let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let controller : FlutterViewController = window.rootViewController as! FlutterViewController
        authorizationService.startAuthentication(viewController: controller, authBuilder.build(), callback: callback)
    }

    /// Starts SMS authentication and returns the OTP initiation response.
    func startSMSAuthentication(phoneNumber: String, scope: String?, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let callback = SMSBridgeCallback(success: success, fail: fail)
        smsCallback = callback
        if let scopeValue = scope, scopeValue.isEmpty == false {
            SMSServices.startVerification(phoneNumber: phoneNumber, scope: scopeValue, callback: callback)
        } else {
            SMSServices.startVerification(phoneNumber: phoneNumber, callback: callback)
        }
    }

    /// Verifies a user-entered SMS OTP and returns the final token response.
    func verifySMSOTP(otpCode: String, authReqId: String, nonce: String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        let callback = SMSBridgeCallback(success: success, fail: fail)
        smsCallback = callback
        SMSServices.verifyOTP(otpCode: otpCode, authReqId: authReqId, nonce: nonce, callback: callback)
    }
    
    /// Adds a custom query parameter to future authorization requests.
    func addQueryParam(key: String, value: String){
        print("key", key, value)
        authBuilder.addQueryParam(key: key, value: value)
    }

    /// Sets the OAuth state value on future authorization requests.
    func setState(value: String){
        print("setState", value)
        authBuilder.setState(value: value)
    }

    /// Sets the OAuth scope on future authorization requests.
    func setScope(value: String){
        print("setScope", value)
        authBuilder.setScope(value: value)
    }
}

private class MultiAuthBridgeCallback: MultiAuthCallback {
    private let success: (String?)->(Void)
    private let fail: (AuthenticationError)->(Void)

    init(success:@escaping(String?)->(Void), fail:@escaping(AuthenticationError)->(Void)) {
        self.success = success
        self.fail = fail
    }

    func onSuccess(response: AuthorizationResponse) {
        let json: [String: Any] = [
            "type": "authentication",
            "authentication_response": response.getPlainResponse()
        ]
        success(jsonString(json))
    }

    func onOTPRequired(response: SMSAuthResponse) {
        let json: [String: Any] = [
            "type": "otp_required",
            "sms_auth_response": smsAuthJson(response)
        ]
        success(jsonString(json))
    }

    func onError(error: IPificationException) {
        var temp = AuthenticationError()
        temp.error_code = ErrorCode.AUTHENTICATE_FAIL
        temp.error_message = error.localizedDescription
        fail(temp)
    }
}

private class SMSBridgeCallback: SMSCallback {
    private let success: (String?)->(Void)
    private let fail: (AuthenticationError)->(Void)

    init(success:@escaping(String?)->(Void), fail:@escaping(AuthenticationError)->(Void)) {
        self.success = success
        self.fail = fail
    }

    func onAuthInitiated(response: SMSAuthResponse) {
        success(jsonString(smsAuthJson(response)))
    }

    func onSuccess(response: SMSTokenResponse) {
        success(jsonString(smsTokenJson(response)))
    }

    func onError(error: IPificationException) {
        var temp = AuthenticationError()
        temp.error_code = ErrorCode.AUTHENTICATE_FAIL
        temp.error_message = error.localizedDescription
        fail(temp)
    }
}

private func smsAuthJson(_ response: SMSAuthResponse) -> [String: Any] {
    var json: [String: Any] = [
        "auth_req_id": response.authReqId,
        "nonce": response.nonce,
        "raw_response": response.rawResponse
    ]
    if let authServer = response.authServer {
        json["auth_server"] = [
            "id": authServer.id,
            "url": authServer.url
        ]
    }
    return json
}

private func smsTokenJson(_ response: SMSTokenResponse) -> [String: Any] {
    var json: [String: Any] = [
        "phone_number_verified": response.phoneNumberVerified
    ]
    json["sub"] = response.sub
    json["phone_number"] = response.phoneNumber
    json["login_hint"] = response.loginHint
    json["raw_response"] = response.rawResponse
    return json
}

private func jsonString(_ dictionary: [String: Any]) -> String {
    guard JSONSerialization.isValidJSONObject(dictionary),
          let data = try? JSONSerialization.data(withJSONObject: dictionary),
          let string = String(data: data, encoding: .utf8) else {
        return "{}"
    }
    return string
}
