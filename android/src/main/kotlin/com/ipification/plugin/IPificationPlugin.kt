package com.ipification.plugin

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.util.Log
import android.view.View
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.IPConfiguration
import com.ipification.mobile.sdk.android.IPEnvironment
import com.ipification.mobile.sdk.im.IMLocale
import com.ipification.mobile.sdk.im.IMService
import com.ipification.mobile.sdk.im.IMTheme
import com.ipification.mobile.sdk.im.ui.IMVerificationActivity
import com.ipification.mobile.sdk.android.IPificationServices
import com.ipification.mobile.sdk.android.utils.IPConstant

import java.util.concurrent.atomic.AtomicBoolean

/**
 * Flutter plugin for IPification authentication services on Android
 */
class IPificationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    companion object {
        private const val TAG = "IPificationPlugin"
        private const val CHANNEL_NAME = "ipification_plugin"
            }

    private lateinit var channel: MethodChannel
    private var authenticationHelper: AuthenticationHelper? = null
    private var activity: Activity? = null
    private val authInProgress = AtomicBoolean(false)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this::onActivityResult)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "doAuthentication" -> handleAuthentication(call, result)
            "doAuthenticationWithChannel" -> handleAuthenticationWithChannel(call, result)
            "doIMAuthentication" -> handleIMAuthentication(call, result)
            "checkCoverage" -> handleCheckCoverage(result)
            "checkCoverageWithPhoneNumber" -> handleCheckCoverageWithPhoneNumber(call, result)
            "setConfiguration" -> handleSetConfiguration(call)
            "getConfiguration" -> handleGetConfiguration(call, result)
            "setEnv" -> handleSetEnv(call)
            "getClientId" -> result.success(getConfigString { IPConfiguration.getInstance().CLIENT_ID })
            "getRedirectUri" -> result.success(getConfigString { IPConfiguration.getInstance().REDIRECT_URI.toString() })
            "setClientId" -> handleSetClientId(call)
            "setRedirectUri" -> handleSetRedirectUri(call)
            "setCheckCoverageUrl" -> handleSetCoverageUrl(call)
            "setAuthorizationUrl" -> handleSetAuthorizationUrl(call)
            "addQueryParam" -> handleAddQueryParam(call)
            "setState" -> handleSetState(call)
            "setScope" -> handleSetScope(call)
            "generateState" -> result.success(getConfigString { IPConfiguration.getInstance().generateState() })
            "showNotification" -> handleShowNotification(call, result)
            "unregisterNetwork" -> handleUnregisterNetwork()
            "enableLog" -> IPConfiguration.getInstance().debug = true
            "getLog" -> result.success(IPConstant.getInstance().LOG ?: "")
            "updateLocale" -> handleUpdateLocale(call)
            "updateTheme" -> handleUpdateTheme(call)
            else -> result.success("unregister function")
        }
    }

    private fun createAuthListener(result: Result) = object : AuthenticationListener {
        override fun onSuccess(response: String) {
            if (authInProgress.compareAndSet(true, false)) {
                activity?.runOnUiThread { result.success(response) }
                authenticationHelper = null
            }
        }

        override fun onFail(errorResult: AuthenticationError) {
            if (authInProgress.compareAndSet(true, false)) {
                activity?.runOnUiThread {
                    result.error(errorResult.error_code.code, errorResult.error_message, null)
                }
                authenticationHelper = null
            }
        }

        override fun onIMCancel() {
            authInProgress.set(false)
            result.error(ErrorCode.AUTHENTICATE_IM_CANCEL.code, "im_canceled", null)
        }
    }

    private fun handleAuthentication(call: MethodCall, result: Result) {
        if (authInProgress.get()) return
        
        val loginHint = call.argument<String>("login_hint") ?: ""
        executeWithAuthHelper(result) { helper ->
            authInProgress.set(true)
            helper.doAuthentication(loginHint, createAuthListener(result))
        }
    }

    private fun handleAuthenticationWithChannel(call: MethodCall, result: Result) {
        if (authInProgress.get()) return
        
        val loginHint = call.argument<String>("login_hint") ?: ""
        val channel = call.argument<String>("channel") ?: ""
        executeWithAuthHelper(result) { helper ->
            authInProgress.set(true)
            helper.startAuthorization(activity!!, loginHint, channel, createAuthListener(result))
        }
    }

    private fun handleIMAuthentication(call: MethodCall, result: Result) {
        if (authInProgress.get()) return
        
        val channel = call.argument<String>("channel") ?: ""
        executeWithAuthHelper(result) { helper ->
            authInProgress.set(true)
            helper.startAuthorization(activity!!, channel, createAuthListener(result))
        }
    }

    private fun handleCheckCoverage(result: Result) {
        if (authInProgress.get()) return
        
        executeWithAuthHelper(result) { helper ->
            authInProgress.set(true)
            helper.checkCoverage(
                { response ->
                    if (authInProgress.compareAndSet(true, false)) {
                        activity?.runOnUiThread { result.success(response) }
                        authenticationHelper = null
                    }
                },
                { error ->
                    if (authInProgress.compareAndSet(true, false)) {
                        activity?.runOnUiThread {
                            result.error(error.error_code.code, error.error_message, null)
                        }
                        authenticationHelper = null
                    }
                }
            )
        }
    }

    private fun handleCheckCoverageWithPhoneNumber(call: MethodCall, result: Result) {
        if (authInProgress.get()) return
        
        val phoneNumber = call.argument<String>("phone_number")
        if (phoneNumber.isNullOrEmpty()) {
            activity?.runOnUiThread {
                result.error("invalid_parameter", "phoneNumber cannot be empty", null)
            }
            return
        }
        
        executeWithAuthHelper(result) { helper ->
            authInProgress.set(true)
            helper.checkCoverage(phoneNumber,
                { response ->
                    if (authInProgress.compareAndSet(true, false)) {
                        activity?.runOnUiThread { result.success(response) }
                        authenticationHelper = null
                    }
                },
                { error ->
                    if (authInProgress.compareAndSet(true, false)) {
                        activity?.runOnUiThread {
                            result.error(error.error_code.code, error.error_message, null)
                        }
                        authenticationHelper = null
                    }
                }
            )
        }
    }

    private fun handleSetConfiguration(call: MethodCall) {
        val jsonConfig = call.argument<String>("config_file_name")
        if (!jsonConfig.isNullOrEmpty()) {
            // if (BuildConfig.DEBUG) Log.d(TAG, "config_file_name: $jsonConfig")
            executeWithAuthHelper { it.setConfiguration(jsonConfig) }
        }
    }

    private fun handleGetConfiguration(call: MethodCall, result: Result) {
        val configName = call.argument<String>("config_name")
        if (!configName.isNullOrEmpty()) {
            executeWithAuthHelper(result) { helper ->
                activity?.runOnUiThread {
                    result.success(helper.getConfigurationByName(configName))
                }
            }
        }
    }

    private fun handleSetEnv(call: MethodCall) {
        activity?.let {
            val env = call.argument<String>("value")
            IPConfiguration.getInstance().ENV = if (env == "production") {
                IPEnvironment.PRODUCTION
            } else {
                IPEnvironment.SANDBOX
            }
        }
    }

    private fun handleSetClientId(call: MethodCall) {
        IPConfiguration.getInstance().SDK_TYPE_VALUE = "flutter"
        val clientValue = call.argument<String>("value")
        if (!clientValue.isNullOrEmpty()) {
            activity?.let { IPConfiguration.getInstance().CLIENT_ID = clientValue }
        }
    }

    private fun handleSetRedirectUri(call: MethodCall) {
        val redirectValue = call.argument<String>("value")
        if (!redirectValue.isNullOrEmpty()) {
            activity?.let { IPConfiguration.getInstance().REDIRECT_URI = Uri.parse(redirectValue) }
        }
    }

    private fun handleSetCoverageUrl(call: MethodCall) {
        val coverageValue = call.argument<String>("value")
        if (!coverageValue.isNullOrEmpty()) {
            activity?.let {
                IPConfiguration.getInstance().apply {
                    customUrls = true
                    COVERAGE_URL = Uri.parse(coverageValue)
                }
            }
        }
    }

    private fun handleSetAuthorizationUrl(call: MethodCall) {
        val authorizationValue = call.argument<String>("value")
        if (!authorizationValue.isNullOrEmpty()) {
            activity?.let {
                IPConfiguration.getInstance().apply {
                    customUrls = true
                    AUTHORIZATION_URL = Uri.parse(authorizationValue)
                }
            }
        }
    }

    private fun handleAddQueryParam(call: MethodCall) {
        activity?.let {
            val key = call.argument<String>("key") ?: ""
            val value = call.argument<String>("value") ?: ""
            executeWithAuthHelper { helper -> helper.addQueryParam(key, value) }
        }
    }

    private fun handleSetState(call: MethodCall) {
        activity?.let {
            val state = call.argument<String>("value") ?: ""
            executeWithAuthHelper { helper -> helper.setState(state) }
        }
    }

    private fun handleSetScope(call: MethodCall) {
        activity?.let {
            val scope = call.argument<String>("value") ?: ""
            executeWithAuthHelper { helper -> helper.setScope(scope) }
        }
    }

    private fun handleShowNotification(call: MethodCall, result: Result) {
        try {
            val context = activity ?: run {
                result.error("NO_CONTEXT", "No activity or context available", null)
                return
            }
            
            val title = call.argument<String>("title") ?: ""
            val message = call.argument<String>("message") ?: ""
            val notificationFolder = call.argument<String>("notificationFolder") ?: ""
            val notiIcon = call.argument<String>("notificationIcon") ?: ""
            
            val notificationIcon = context.resources.getIdentifier(
                notiIcon, notificationFolder, context.packageName
            )
            IMService.showIPNotification(context, title, message, notificationIcon)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "showNotification error: ${e.message}")
            result.error("NOTIFICATION_ERROR", e.message, null)
        }
    }

    private fun handleUnregisterNetwork() {
        activity?.let {
            val unregisterResult = CellularService.unregisterNetwork(it)
            Log.d(TAG, "unregisterNetwork: $unregisterResult")
        }
    }

    private fun handleUpdateLocale(call: MethodCall) {
        activity?.let {
            try {
                IPificationServices.locale = IMLocale(
                    mainTitle = call.argument<String>("mainTitle") ?: "",
                    description = call.argument<String>("description") ?: "",
                    whatsappText = call.argument<String>("whatsappBtnText") ?: "",
                    telegramText = call.argument<String>("telegramBtnText") ?: "",
                    viberText = call.argument<String>("viberBtnText") ?: "",
                    toolbarTitle = call.argument<String>("toolbarTitle") ?: "",
                    toolbarVisibility = if (call.argument<Boolean>("isVisible") ?: true) {
                        View.VISIBLE
                    } else View.GONE
                )
            } catch (e: Exception) {
                Log.e(TAG, "updateLocale: ${e.message}")
            }
        }
    }

    private fun handleUpdateTheme(call: MethodCall) {
        activity?.let {
            try {
                IPificationServices.theme = IMTheme(
                    backgroundColor = Color.parseColor(call.argument<String>("backgroundColor") ?: "#FFFFFF"),
                    toolbarTextColor = Color.parseColor(call.argument<String>("toolbarTextColor") ?: "#000000"),
                    toolbarColor = Color.parseColor(call.argument<String>("toolbarColor") ?: "#FFFFFF")
                )
            } catch (e: Exception) {
                Log.e(TAG, "updateTheme: ${e.message}")
            }
        }
    }

    private fun executeWithAuthHelper(result: Result? = null, action: (AuthenticationHelper) -> Unit) {
        activity?.let {
            if (authenticationHelper == null) {
                authenticationHelper = AuthenticationHelper(IPApiService(it))
            }
            authenticationHelper?.let(action) ?: run {
                result?.error("HELPER_NULL", "Authentication helper initialization failed", null)
            }
        } ?: result?.error("NO_ACTIVITY", "Activity not available", null)
    }

    private fun getConfigString(action: () -> String): String? {
        return activity?.let { action() }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        IMService.onActivityResult(requestCode, resultCode, data)
        return true
    }
}