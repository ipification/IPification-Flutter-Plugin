package com.ipification.plugin

import android.app.Activity
import com.ipification.mobile.sdk.android.callback.IPAuthCallback
import com.ipification.mobile.sdk.android.callback.IPCoverageCallback
import com.ipification.mobile.sdk.android.callback.IPificationCallback
import com.ipification.mobile.sdk.android.exception.IPificationError
import com.ipification.mobile.sdk.android.response.AuthResponse
import com.ipification.mobile.sdk.android.response.CoverageResponse
import com.ipification.mobile.sdk.android.response.IPAuthResponse

class AuthenticationHelper(private val apiService: IPApiService) {

    fun checkCoverage(
        phoneNumber: String,
        onSuccess: (String) -> Unit = {},
        onError: (AuthenticationError) -> Unit = {}
    ) {
        val callback = object : IPCoverageCallback {
            override fun onSuccess(res: CoverageResponse) {
                onSuccess.invoke(res.responseData)
            }

            override fun onError(error: IPificationError) {
                onError.invoke(
                    AuthenticationError(
                        error_code = ErrorCode.COVERAGE_ERROR,
                        error_message = error.getErrorMessage()
                    )
                )
            }
        }
        apiService.checkCoverage(phoneNumber, callback)
    }

    fun checkCoverage(
        onSuccess: (String) -> Unit = {},
        onError: (AuthenticationError) -> Unit = {}
    ) {
        val callback = object : IPCoverageCallback {
            override fun onSuccess(res: CoverageResponse) {
                onSuccess.invoke(res.responseData)
            }

            override fun onError(error: IPificationError) {
                onError.invoke(
                    AuthenticationError(
                        error_code = ErrorCode.COVERAGE_ERROR,
                        error_message = error.getErrorMessage()
                    )
                )
            }
        }
        apiService.checkCoverage(callback)
    }

    fun doAuthentication(loginHint: String, listener: AuthenticationListener) {
        val callback = object : IPAuthCallback {
            override fun onSuccess(res: IPAuthResponse) {
                if (res.code.isBlank()) {
                    listener.onFail(
                        AuthenticationError(
                            error_code = ErrorCode.AUTHENTICATE_FAIL,
                            error_message = res.fullResponse
                        )
                    )
                } else {
                    listener.onSuccess(res.fullResponse)
                }
            }

            override fun onError(error: IPificationError) {
                listener.onFail(
                    AuthenticationError(
                        error_code = ErrorCode.AUTHENTICATE_FAIL,
                        error_message = error.getErrorMessage()
                    )
                )
            }
        }
        apiService.doAuthentication(loginHint, callback)
    }

    fun startAuthorization(
        activity: Activity,
        loginHint: String,
        channel: String,
        listener: AuthenticationListener
    ) {
        val callback = object : IPificationCallback {
            override fun onSuccess(res: AuthResponse) {
                val code = res.getCode()
                if (code.isNullOrEmpty()) {
                    listener.onFail(
                        AuthenticationError(
                            error_code = ErrorCode.AUTHENTICATE_FAIL,
                            error_message = res.getErrorMessage()
                        )
                    )
                } else {
                    listener.onSuccess(res.responseData)
                }
            }

            override fun onError(error: IPificationError) {
                listener.onFail(
                    AuthenticationError(
                        error_code = ErrorCode.AUTHENTICATE_FAIL,
                        error_message = error.getErrorMessage()
                    )
                )
            }

            override fun onIMCancel() {
                listener.onIMCancel()
            }
        }
        apiService.startAuthentication(activity, loginHint, channel, callback)
    }

    fun startAuthorization(activity: Activity, channel: String, listener: AuthenticationListener) {
        val callback = object : IPificationCallback {
            override fun onSuccess(res: AuthResponse) {
                val code = res.getCode()
                if (code.isNullOrEmpty()) {
                    listener.onFail(
                        AuthenticationError(
                            error_code = ErrorCode.AUTHENTICATE_FAIL,
                            error_message = res.getErrorMessage()
                        )
                    )
                } else {
                    listener.onSuccess(res.responseData)
                }
            }

            override fun onError(error: IPificationError) {
                listener.onFail(
                    AuthenticationError(
                        error_code = ErrorCode.AUTHENTICATE_FAIL,
                        error_message = error.getErrorMessage()
                    )
                )
            }

            override fun onIMCancel() {
                listener.onIMCancel()
            }
        }
        apiService.startIMAuthentication(activity, channel, callback)
    }

    fun setState(state: String) {
        apiService.setState(state)
    }

    fun addQueryParam(key: String, value: String) {
        apiService.addQueryParam(key, value)
    }

    fun setScope(scope: String) {
        apiService.setScope(scope)
    }
}
