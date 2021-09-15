package com.example.ip_sdk

import android.util.Log
import com.ipification.mobile.sdk.android.AuthorizationServiceConfiguration
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.callback.CellularCallback
import com.ipification.mobile.sdk.android.exception.CellularException
import com.ipification.mobile.sdk.android.response.AuthResponse
import com.ipification.mobile.sdk.android.response.CoverageResponse
import com.ipification.sdk.ip_sdk.AuthenticationListener
import com.ipification.sdk.ip_sdk.AuthenticationError
import com.ipification.sdk.ip_sdk.ErrorCode



class AuthenticationHelper(val apiService: IPApiService)  {

    

    fun checkCoverage(onSuccess:(String)->Unit={},onError:(AuthenticationError)->Unit={}) {

        val callback = object : CellularCallback<CoverageResponse> {
            override fun onSuccess(res: CoverageResponse) {
                onSuccess.invoke(res.responseData)
            }

            override fun onError(error: CellularException) {
                val result = AuthenticationError()
                result.error_code = ErrorCode.COVERAGE_ERROR
                result.error_message = error?.getErrorMessage()
                onError.invoke(result)
            }

        }
        apiService.checkIpCoverage(callback)
    }
    fun doAuthentication (login_hint:String, listener: AuthenticationListener){
        val callback = object : CellularCallback<AuthResponse> {
            override fun onSuccess(res: AuthResponse) {
                val code = res.getCode()
                if(code.isNullOrEmpty()){
                    val result = AuthenticationError()
                    result.error_code = ErrorCode.AUTHENTICATE_FAIL
                    res?.getErrorMessage()?.let {
                        result.error_message = it
                    }
                    listener.onFail(result)
                }else{
                    val state = res.getState() ?: ""
                    val resData = res.responseData
                    var json = """{"code":"${code}","state":"${state}", "response_data": "${resData}"}""";
                    listener.onSuccess(json)
                }
                
            }

            override fun onError(error: CellularException) {
                val result = AuthenticationError().apply {
                    error_code = ErrorCode.AUTHENTICATE_ERROR
                    error?.getErrorMessage()?.let {
                     error_message = it
                    }
                }
                listener?.onFail(result)
            }
        }
        apiService.doAuthentication(login_hint, callback)
    }

    fun setState(state: String){
        apiService.setState(state)
    }

    fun addQueryParam(key: String, value: String){
        apiService.addQueryParam(key, value)
    }

    fun setScope(scope: String){
        apiService.setScope(scope)
    }
    
    fun setConfiguration(file_name:String){
        Log.d("config_name", file_name)
        val context = apiService.context
        val cellularService = CellularService<CoverageResponse>(apiService.context)
        val resourceId: Int = context.resources.getIdentifier(file_name, "raw", context.getPackageName())
        val inputStream = apiService.context.resources.openRawResource(resourceId)
        cellularService.setAuthorizationServiceConfiguration(AuthorizationServiceConfiguration(inputStream))

    }

    fun getConfigurationByName(name:String):String?{
        val cellularService = CellularService<CoverageResponse>(apiService.context)
       return cellularService.getConfiguration(name)

    }

    
}