package com.ipification.plugin

import android.app.Activity
import android.content.Context
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.IPificationServices
import com.ipification.mobile.sdk.android.callback.IPAuthCallback
import com.ipification.mobile.sdk.android.callback.IPCoverageCallback
import com.ipification.mobile.sdk.android.callback.IPificationCallback
import com.ipification.mobile.sdk.android.request.AuthRequest

class IPApiService(
    private val activity: Activity,
    var authRequestBuilder: AuthRequest.Builder = AuthRequest.Builder()
) {
    fun context(): Context {
        return activity.applicationContext
    }

    fun doAuthentication(loginHint: String, callback: IPAuthCallback) {
        val cellularService = CellularService(context())
        if (loginHint.isNotEmpty()) {
            authRequestBuilder.addQueryParam("login_hint", loginHint)
        }
        val authRequest = authRequestBuilder.build()
        try {
            cellularService.performAuth(activity, authRequest, callback)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

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

    fun setState(state: String) {
        authRequestBuilder.setState(state)
    }

    fun addQueryParam(key: String, value: String) {
        authRequestBuilder.addQueryParam(key, value)
    }

    fun setScope(scope: String) {
        authRequestBuilder.setScope(scope)
    }

    fun checkCoverage(callback: IPCoverageCallback) {
        IPificationServices.startCheckCoverage(context(), callback)
    }

    fun checkCoverage(phoneNumber: String, callback: IPCoverageCallback) {
        IPificationServices.startCheckCoverage(phoneNumber, context(), callback)
    }
}
