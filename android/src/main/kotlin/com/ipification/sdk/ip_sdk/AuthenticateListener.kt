package com.ipification.sdk.ip_sdk



interface AuthenticateListener {
    fun onSuccess(authen_code:String)
    fun onFail(result: AuthenticateResult)
    fun onError(result: AuthenticateResult)
}