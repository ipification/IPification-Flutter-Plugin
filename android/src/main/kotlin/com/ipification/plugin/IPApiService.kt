package com.ipification.plugin

import android.content.Context
import android.app.Activity
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.callback.CellularCallback
import com.ipification.mobile.sdk.android.request.AuthRequest
import com.ipification.mobile.sdk.android.response.AuthResponse
import com.ipification.mobile.sdk.android.response.CoverageResponse
import com.ipification.mobile.sdk.android.callback.IPificationCallback
import com.ipification.mobile.sdk.android.IPificationServices
import android.util.Log


class IPApiService(private val activity: Activity, var authRequestBuilder:AuthRequest.Builder = AuthRequest.Builder()) {
    fun context(): Context{
        return activity.applicationContext
    }
    fun doAuthentication(login_hint:String, callback: CellularCallback<AuthResponse>){
        val cellularService = CellularService<AuthResponse>(context())
        if(login_hint != ""){
            authRequestBuilder.addQueryParam("login_hint", login_hint)
        }
        val authRequest = authRequestBuilder.build()
        try {
            cellularService.performAuth(authRequest,callback)
        } catch (ex:Exception){
            ex.printStackTrace()
        }
    }
    

    fun startAuthentication(activity: Activity, login_hint:String, channel: String, callback: IPificationCallback){
        
        if(login_hint != ""){
            authRequestBuilder.addQueryParam("login_hint", login_hint)
        }
        if(channel != ""){
            authRequestBuilder.addQueryParam("channel", channel)
        }
        val authRequest = authRequestBuilder.build()
        try {
            IPificationServices.startAuthentication(activity, authRequest , callback)
        } catch (ex:Exception){
            ex.printStackTrace()
        }
    }

    fun startIMAuthentication(activity: Activity, channel: String, callback: IPificationCallback){
        
        if(channel != ""){
            authRequestBuilder.addQueryParam("channel", channel)
        }
        val authRequest = authRequestBuilder.build()
        try {
            IPificationServices.startAuthentication(activity, authRequest , callback)
        } catch (ex:Exception){
            ex.printStackTrace()
        }
    }
    

    fun setState(state: String){
        authRequestBuilder.setState(state)
    }

    fun addQueryParam(key: String, value: String){
        authRequestBuilder.addQueryParam(key, value)
    }

    fun setScope(scope: String){
        authRequestBuilder.setScope(scope)
    }

    fun checkCoverage(callback: CellularCallback<CoverageResponse>){
        IPificationServices.startCheckCoverage(context(), callback)
    }
    //20092021 - add phone parameter
    fun checkCoverage(phoneNumber: String, callback: CellularCallback<CoverageResponse>){
        IPificationServices.startCheckCoverage(phoneNumber, context(), callback)
    }
}