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


class AuthenticationHelper {
    var authBuilder : AuthorizationRequest.Builder
    init(){
        authBuilder = AuthorizationRequest.Builder()
    }
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
    
    func doAuthentication(login_hint:String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        // if login_hint.isEmpty {
        //     var temp = AuthenticationError()
        //     temp.error_code = ErrorCode.AUTHENTICATE_PHONE_MISSING
        //     temp.error_message = "login-hint is missing"
        //     fail(temp)
        //     return
        // }
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
            // print("authorized successful with code:", response.getCode())
            
            if(response.getCode() != nil){
                // let state = response.getState() ?? ""
                // let resData = response.getPlainResponse()
                // let json = """{"code":"\(response.getCode())","state":"\(state)", "response_data": "\(resData)"}"""
                // let json = "{\"code\": \"\(response.getCode()!)\", \"state\": \"\(state)\", \"response_data\": \"\(resData)\"}"
                // print(json)
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

    func doAuthentication(channel: String, success:@escaping(String?)->(Void),fail:@escaping(AuthenticationError)->(Void)){
        // if login_hint.isEmpty {
        //     var temp = AuthenticationError()
        //     temp.error_code = ErrorCode.AUTHENTICATE_PHONE_MISSING
        //     temp.error_message = "login-hint is missing"
        //     fail(temp)
        //     return
        // }
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
            // print("authorized successful with code:", response.getCode())
            
            if(response.getCode() != nil){
                // let state = response.getState() ?? ""
                // let resData = response.getPlainResponse()
                // let json = """{"code":"\(response.getCode())","state":"\(state)", "response_data": "\(resData)"}"""
                // let json = "{\"code\": \"\(response.getCode()!)\", \"state\": \"\(state)\", \"response_data\": \"\(resData)\"}"
                // print(json)
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
    
    func addQueryParam(key: String, value: String){
        print("key", key, value)
        authBuilder.addQueryParam(key: key, value: value)
    }
    func setState(value: String){
        print("setState", value)
        authBuilder.setState(value: value)
    }
    func setScope(value: String){
        print("setScope", value)
        authBuilder.setScope(value: value)
    }
        
    func getConfigurationByName(configName: String?) -> String?
    {
      if  let path        = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let xml         = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(Configuration.self, from: xml)
        {
            // print("login_hint", preferences.CLIENT_ID)
            switch configName {
            case "client_id":
                return preferences.CLIENT_ID
            case "redirect_uri":
                return preferences.REDIRECT_URI?.replacingOccurrences(of: "\\", with: "")
            default:
                return ""
            }
        }
        return ""
        
    }
}





