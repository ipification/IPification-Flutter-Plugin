package com.example.ip_sdk

import android.content.Context
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.callback.CellularCallback
import com.ipification.mobile.sdk.android.request.AuthRequest
import com.ipification.mobile.sdk.android.response.AuthResponse
import com.ipification.mobile.sdk.android.response.CoverageResponse


class IPApiService(val context: Context, val authRequestBuilder:AuthRequest.Builder = AuthRequest.Builder()) {


    fun doAuthentication(login_hint:String, callback: CellularCallback<AuthResponse>){
        val cellularService = CellularService<AuthResponse>(context)
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
        val cellularService = CellularService<CoverageResponse>(context!!)
        cellularService.checkCoverage(callback)
    }
    //20092021 - add phone parameter
    fun checkCoverage(phoneNumber: String, callback: CellularCallback<CoverageResponse>){
        val cellularService = CellularService<CoverageResponse>(context!!)
        cellularService.checkCoverage(phoneNumber, callback)
    }
}