package com.ipification.plugin

import android.app.Activity
import android.content.Context
import com.ipification.mobile.sdk.ip.AuthChannel
import com.ipification.mobile.sdk.ip.IPificationServices
import com.ipification.mobile.sdk.ip.callback.IPAuthCallback
import com.ipification.mobile.sdk.ip.callback.IPCoverageCallback
import com.ipification.mobile.sdk.ip.callback.MultiAuthCallback
import com.ipification.mobile.sdk.ip.callback.IPificationCallback
import com.ipification.mobile.sdk.ip.request.AuthRequest
import com.ipification.mobile.sdk.sms.callback.SMSCallback

/**
 * Thin wrapper around the Android IPification SDK.
 *
 * This class owns the [AuthRequest.Builder] used by the Flutter bridge and centralizes
 * direct calls into [IPificationServices].
 *
 * @property activity Activity required by SDK calls that launch or bind Android UI.
 * @property authRequestBuilder Mutable builder reused for authentication request options.
 */
class IPApiService(
    private val activity: Activity,
    var authRequestBuilder: AuthRequest.Builder = AuthRequest.Builder()
) {
    /**
     * Returns the application context associated with the current activity.
     */
    fun context(): Context {
        return activity.applicationContext
    }

    /**
     * Performs cellular authentication through [IPificationServices].
     *
     * @param loginHint Optional login hint to add to the authentication request.
     * @param callback SDK callback that receives the authentication response.
     */
    fun doAuthentication(loginHint: String, callback: IPAuthCallback) {
        if (loginHint.isNotEmpty()) {
            authRequestBuilder.addQueryParam("login_hint", loginHint)
        }
        val authRequest = authRequestBuilder.build()
        try {
            IPificationServices.startAuthentication(activity, authRequest, callback)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    /**
     * Starts the IPification authorization flow.
     *
     * @param activity Activity used by the SDK to launch UI.
     * @param loginHint Optional login hint to add to the authentication request.
     * @param channel Optional channel value to add to the authentication request.
     * @param callback SDK callback that receives authorization events.
     */
    fun startAuthentication(
        activity: Activity,
        loginHint: String,
        channel: String,
        callback: IPificationCallback
    ) {
        if (loginHint.isNotEmpty()) {
            authRequestBuilder.addQueryParam("login_hint", loginHint)
        }
        if (channel.isNotEmpty()) {
            authRequestBuilder.addQueryParam("channel", channel)
        }
        val authRequest = authRequestBuilder.build()
        try {
            IPificationServices.startAuthentication(activity, authRequest, callback)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    /**
     * Starts Instant Messaging authentication through the IPification SDK.
     *
     * @param activity Activity used by the SDK to launch UI.
     * @param channel Optional IM channel value to add to the authentication request.
     * @param callback SDK callback that receives authorization events.
     */
    fun startIMAuthentication(activity: Activity, channel: String, callback: IPificationCallback) {
        if (channel.isNotEmpty()) {
            authRequestBuilder.addQueryParam("channel", channel)
        }
        val authRequest = authRequestBuilder.build()
        try {
            IPificationServices.startAuthentication(activity, authRequest, callback)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    /**
     * Starts multi-channel authentication using the configured channel priority.
     */
    fun startMultiAuthentication(
        activity: Activity,
        loginHint: String,
        callback: MultiAuthCallback
    ) {
        if (loginHint.isNotEmpty()) {
            authRequestBuilder.addQueryParam("login_hint", loginHint)
        }
        val authRequest = authRequestBuilder.build()
        IPificationServices.startAuthentication(activity, authRequest, callback)
    }

    /**
     * Starts SMS authentication and returns the OTP initiation response.
     */
    fun startSMSAuthentication(phoneNumber: String, scope: String?, callback: SMSCallback) {
        if (scope.isNullOrEmpty()) {
            IPificationServices.startSMSAuthentication(activity, phoneNumber, callback = callback)
        } else {
            IPificationServices.startSMSAuthentication(activity, phoneNumber, scope, callback)
        }
    }

    /**
     * Verifies a user-entered SMS OTP and returns the final token response.
     */
    fun verifySMSOTP(
        otpCode: String,
        authReqId: String,
        nonce: String,
        callback: SMSCallback
    ) {
        IPificationServices.verifySMSOTP(activity, otpCode, authReqId, nonce, callback)
    }

    /**
     * Configures the native channel priority used by multi-channel authentication.
     */
    fun setAuthChannels(channels: List<AuthChannel>) {
        com.ipification.mobile.sdk.ip.IPConfiguration.getInstance().AUTH_CHANNELS = channels
    }

    /**
     * Sets the OAuth state value on the shared request builder.
     */
    fun setState(state: String) {
        authRequestBuilder.setState(state)
    }

    /**
     * Adds a query parameter to the shared request builder.
     */
    fun addQueryParam(key: String, value: String) {
        authRequestBuilder.addQueryParam(key, value)
    }

    /**
     * Sets the OAuth scope on the shared request builder.
     */
    fun setScope(scope: String) {
        authRequestBuilder.setScope(scope)
    }

    /**
     * Checks coverage for the current device context.
     */
    fun checkCoverage(callback: IPCoverageCallback) {
        IPificationServices.startCheckCoverage(context(), callback)
    }

    /**
     * Checks coverage for a specific phone number.
     */
    fun checkCoverage(phoneNumber: String, callback: IPCoverageCallback) {
        IPificationServices.startCheckCoverage(phoneNumber, context(), callback)
    }
}
