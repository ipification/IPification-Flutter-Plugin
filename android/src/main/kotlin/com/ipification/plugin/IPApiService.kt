package com.ipification.plugin

import android.app.Activity
import android.content.Context
import com.ipification.mobile.sdk.ip.IPificationServices
import com.ipification.mobile.sdk.ip.callback.IPAuthCallback
import com.ipification.mobile.sdk.ip.callback.IPCoverageCallback
import com.ipification.mobile.sdk.ip.callback.IPificationCallback
import com.ipification.mobile.sdk.ip.request.AuthRequest

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
