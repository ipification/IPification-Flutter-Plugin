package com.ipification.sdk.ip_sdk

enum class ErrorCode (val code:String){
    COVERAGE_UNAVAILABLE("coverage_unavailable"),
    COVERAGE_ERROR("coverage_error"),
    AUTHENTICATE_FAIL("authenticate_fail"),
    AUTHENTICATE_ERROR("authenticate_error")
}
