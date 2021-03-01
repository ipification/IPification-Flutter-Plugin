package com.ipification.sdk.ip_sdk



class AuthenticateResult(var error_code: ErrorCode =
                                 ErrorCode.COVERAGE_UNAVAILABLE,
                         var error_message:String?="bcd") {
}