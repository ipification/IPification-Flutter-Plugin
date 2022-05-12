package com.ipification.plugin


interface AuthenticationListener {
    fun onSuccess(result: String)
    fun onFail(result: AuthenticationError)
    fun onError(result: AuthenticationError)
}