package com.example.ip_sdk

import android.content.Context
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.callback.CellularCallback
import com.ipification.mobile.sdk.android.request.AuthRequest
import com.ipification.mobile.sdk.android.response.AuthResponse
import com.ipification.mobile.sdk.android.response.CoverageResponse


class IPApiService(val context: Context) {


    fun ipAuthen(hint_phone:String, callback: CellularCallback<AuthResponse>){
        val cellularService = CellularService<AuthResponse>(context)
        // cellularService.registerCallback(callback)
        val authRequestBuilder = AuthRequest.Builder()
        authRequestBuilder.addQueryParam("login_hint", hint_phone)

        val authRequest = authRequestBuilder.build()
        try {

            cellularService.performAuth(authRequest,callback)
        }catch (ex:Exception){
            ex.printStackTrace()
        }
    }

     fun checkIpCoverage(callback: CellularCallback<CoverageResponse>){
        val cellularService = CellularService<CoverageResponse>(context!!)

        cellularService.checkCoverage(callback)
    }
}