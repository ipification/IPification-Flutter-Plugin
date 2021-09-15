package com.ipification.sdk.ip_sdk



interface AuthenticationListener {
    fun onSuccess(result: String)
    fun onFail(result: AuthenticationError)
    fun onError(result: AuthenticationError)
}