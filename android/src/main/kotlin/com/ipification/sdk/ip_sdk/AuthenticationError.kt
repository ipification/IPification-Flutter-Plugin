package com.ipification.sdk.ip_sdk

class AuthenticationError(var error_code: ErrorCode = ErrorCode.AUTHENTICATE_FAIL, var error_message:String?="") {
}