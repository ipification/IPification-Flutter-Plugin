package com.ipification.sdk.ip_sdk

enum class ErrorCode (val code:String){
    COVERAGE_UNAVAILABLE("check_coverage_unavailable"),
    COVERAGE_ERROR("check_coverage_error"),
    AUTHENTICATE_FAIL("authentication_failed"),
    AUTHENTICATE_ERROR("authentication_error")
}
