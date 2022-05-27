package com.ipification.plugin

class AuthenticationError(var error_code: ErrorCode = ErrorCode.AUTHENTICATE_FAIL, var error_message:String?="") {
}