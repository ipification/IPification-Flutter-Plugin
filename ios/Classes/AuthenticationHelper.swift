//
//  AuthenticationHelper.swift
//  ip_sdk
//
//  Created by thousandhands on 1/20/21.
//

import Foundation

import IPificationSDK


class AuthenticationHelper {
    
    static func checkCoverage(success:@escaping(Bool)->(Void),fail:@escaping(AuthenticateResult)->(Void)){
        do {
            let coverageService = CoverageService()
            coverageService.callbackFailed = { (error) -> Void in
                print(error.localizedDescription)
                var temp = AuthenticateResult()
                temp.error_code = ErrorCode.COVERAGE_UNAVAILABLE
                temp.error_message = error.localizedDescription
                fail(temp)
                
            }
            coverageService.callbackSuccess = { (response) -> Void in
                print("check coverage result: ", response.isAvailable())
                success(response.isAvailable())
                
            }
            try coverageService.checkCoverage()
        } catch{
            print("Unexpected error: \(error).")
            var temp = AuthenticateResult()
            temp.error_code = ErrorCode.COVERAGE_ERROR
            temp.error_message = error.localizedDescription
            fail(temp)
            // unavailable, please handle it with another auth service flow
        }
    }
    
    static func authent(login_hint:String,success:@escaping(String?)->(Void),fail:@escaping(AuthenticateResult)->(Void)){
        
        
        if login_hint.isEmpty {
            var temp = AuthenticateResult()
            temp.error_code = ErrorCode.AUTHENTICATE_PHONE_MISSING
            temp.error_message = "Number phone missing"
            fail(temp)
            return
        }
        
        
        let authorizationService = AuthorizationService()
        authorizationService.callbackFailed = { (error) -> Void in
            print("authorized failed", error.localizedDescription)
            var temp = AuthenticateResult()
            temp.error_code = ErrorCode.AUTHENTICATE_ERROR
            temp.error_message = error.localizedDescription
            fail(temp)
            
        }
        authorizationService.callbackSuccess = { (response) -> Void in
            print("authorized successful with code:", response.getCode())
            
            if(response.getCode() != nil){
                success(response.getCode())
            }else{
                var temp = AuthenticateResult()
                temp.error_code = ErrorCode.AUTHENTICATE_FAIL
                temp.error_message = response.getError()
                fail(temp)
            }
        }
        
        
        let builder =  AuthorizationRequest.Builder()
        print("login_hint", login_hint)
        builder.addQueryParam(key: "login_hint", value: login_hint)
        authorizationService.doAuthorization(builder.build())
    }
    
    
        
    static func getConfigurationByName(configName: String?) -> String?
    {
      if  let path        = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let xml         = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(Configuration.self, from: xml)
        {
            print("login_hint", preferences.CLIENT_ID)
            switch configName {
            case "client_id":
                return preferences.CLIENT_ID
            case "redirect_uri":
                return preferences.REDIRECT_URI
            default:
                return ""
            }
        }
        return ""
        
    }
}





