//
//  AuthenticationHelper.swift
//  ip_sdk
//
//  Created by ipification on 1/20/21.
//

import Foundation

import IPificationSDK


class AuthenticationHelper {
    var authBuilder : AuthorizationRequest.Builder
    init(){
        authBuilder = AuthorizationRequest.Builder()
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
            temp.error_code = ErrorCode.AUTHENTICATE_ERROR
            temp.error_message = error.localizedDescription
            fail(temp)
            
        }
        authorizationService.callbackSuccess = { (response) -> Void in
            // print("authorized successful with code:", response.getCode())
            
            if(response.getCode() != nil){
                let state = response.getState() ?? ""
                let resData = response.getPlainResponse()
                // let json = """{"code":"\(response.getCode())","state":"\(state)", "response_data": "\(resData)"}"""
                let json = "{\"code\": \"\(response.getCode()!)\", \"state\": \"\(state)\", \"response_data\": \"\(resData)\"}"
                // print(json)
                success(json)
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
        authorizationService.doAuthorization(authBuilder.build())
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





