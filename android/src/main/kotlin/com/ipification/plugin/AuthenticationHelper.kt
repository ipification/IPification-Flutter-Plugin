package com.ipification.plugin

import android.app.Activity
import com.ipification.mobile.sdk.ip.callback.IPAuthCallback
import com.ipification.mobile.sdk.ip.callback.IPCoverageCallback
import com.ipification.mobile.sdk.ip.callback.IPificationCallback
import com.ipification.mobile.sdk.ip.exception.IPificationError
import com.ipification.mobile.sdk.ip.response.CoverageResponse
import com.ipification.mobile.sdk.ip.response.IPAuthResponse

/**
 * Converts callbacks from [IPApiService] into plugin-level success and error handlers.
 *
 * @property apiService Native IPification API wrapper used to execute SDK calls.
 */
class AuthenticationHelper(private val apiService: IPApiService) {

    /**
     * Checks whether IPification coverage is available for the supplied phone number.
     *
     * @param phoneNumber Phone number to check with the native SDK.
     * @param onSuccess Invoked with the raw coverage response when coverage lookup succeeds.
     * @param onError Invoked with a normalized plugin error when coverage lookup fails.
     */
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

    /**
     * Checks whether IPification coverage is available for the current device context.
     *
     * @param onSuccess Invoked with the raw coverage response when coverage lookup succeeds.
     * @param onError Invoked with a normalized plugin error when coverage lookup fails.
     */
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

    /**
     * Performs cellular authentication and forwards the result to [listener].
     *
     * @param loginHint Optional login hint added to the authorization request.
     * @param listener Receives success, failure, or cancellation events.
     */
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

    /**
     * Starts an authorization flow with an optional login hint and channel.
     *
     * @param activity Activity used by the native SDK to launch UI if needed.
     * @param loginHint Optional login hint added to the authorization request.
     * @param channel Optional channel parameter added to the authorization request.
     * @param listener Receives success, failure, or cancellation events.
     */
    fun startAuthorization(
        activity: Activity,
        loginHint: String,
        channel: String,
        listener: AuthenticationListener
    ) {
        val callback = object : IPificationCallback {
            override fun onSuccess(res: IPAuthResponse) {
                val code = res.code
                if (code.isNullOrEmpty()) {
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

            override fun onIMCancel() {
                listener.onIMCancel()
            }
        }
        apiService.startAuthentication(activity, loginHint, channel, callback)
    }

    /**
     * Starts Instant Messaging authentication for the supplied channel.
     *
     * @param activity Activity used by the native SDK to launch the IM flow.
     * @param channel IM channel parameter added to the authorization request.
     * @param listener Receives success, failure, or cancellation events.
     */
    fun startAuthorization(activity: Activity, channel: String, listener: AuthenticationListener) {
        val callback = object : IPificationCallback {
            override fun onSuccess(res: IPAuthResponse) {
                val code = res.code
                if (code.isNullOrEmpty()) {
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

            override fun onIMCancel() {
                listener.onIMCancel()
            }
        }
        apiService.startIMAuthentication(activity, channel, callback)
    }

    /**
     * Sets the OAuth state value on future authentication requests.
     *
     * @param state State value to pass through the native SDK request builder.
     */
    fun setState(state: String) {
        apiService.setState(state)
    }

    /**
     * Adds a custom query parameter to future authentication requests.
     *
     * @param key Query parameter name.
     * @param value Query parameter value.
     */
    fun addQueryParam(key: String, value: String) {
        apiService.addQueryParam(key, value)
    }

    /**
     * Sets the OAuth scope on future authentication requests.
     *
     * @param scope Scope value to pass through the native SDK request builder.
     */
    fun setScope(scope: String) {
        apiService.setScope(scope)
    }
}
