package com.ipification.plugin

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Handler
import android.os.Looper
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

import com.ipification.mobile.sdk.ip.IPConfiguration
import com.ipification.mobile.sdk.ip.AuthChannel
import com.ipification.mobile.sdk.ip.IPEnvironment
import com.ipification.mobile.sdk.im.IMLocale
import com.ipification.mobile.sdk.im.IMService
import com.ipification.mobile.sdk.im.IMTheme
import com.ipification.mobile.sdk.im.ui.IMVerificationActivity
import com.ipification.mobile.sdk.ip.IPificationServices
import com.ipification.mobile.sdk.ip.utils.IPConstant
import com.ipification.mobile.sdk.ip.utils.IPLogs

import java.util.concurrent.atomic.AtomicBoolean

/**
 * Flutter plugin entry point for IPification authentication services on Android.
 *
 * The plugin owns the method channel exposed to Dart, maps Flutter method calls to
 * native SDK operations, and normalizes native callback results into Flutter responses.
 */
class IPificationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    companion object {
        private const val TAG = "IPificationPlugin"
        private const val CHANNEL_NAME = "ipification_plugin"
            }

    private lateinit var channel: MethodChannel
    private var authenticationHelper: AuthenticationHelper? = null
    private var activity: Activity? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val authInProgress = AtomicBoolean(false)
    private val coverageInProgress = AtomicBoolean(false)

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
        authenticationHelper = null
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
            "doAuthenticationWithChannels" -> handleAuthenticationWithChannels(call, result)
            "startSMSAuthentication" -> handleStartSMSAuthentication(call, result)
            "verifySMSOTP" -> handleVerifySMSOTP(call, result)
            "checkCoverage" -> handleCheckCoverage(result)
            "checkCoverageWithPhoneNumber" -> handleCheckCoverageWithPhoneNumber(call, result)
            "setConfiguration" -> { handleSetConfiguration(call); result.success(null) }
            "setEnv" -> { handleSetEnv(call); result.success(null) }
            "getClientId" -> result.success(getConfigString { IPConfiguration.getInstance().CLIENT_ID })
            "getRedirectUri" -> result.success(getConfigString { IPConfiguration.getInstance().REDIRECT_URI?.toString() })
            "setClientId" -> { handleSetClientId(call); result.success(null) }
            "setRedirectUri" -> { handleSetRedirectUri(call); result.success(null) }
            "setBaseUrl" -> { handleSetBaseUrl(call); result.success(null) }
            "setCheckCoverageUrl" -> { handleSetCoverageUrl(call); result.success(null) }
            "setAuthorizationUrl" -> { handleSetAuthorizationUrl(call); result.success(null) }
            "addQueryParam" -> { handleAddQueryParam(call); result.success(null) }
            "setState" -> { handleSetState(call); result.success(null) }
            "setScope" -> { handleSetScope(call); result.success(null) }
            "setAuthChannels" -> handleSetAuthChannels(call, result)
            "setSMSConfiguration" -> handleSetSMSConfiguration(call, result)
            "setTS43Configuration" -> handleSetTS43Configuration(call, result)
            "generateState" -> result.success(getConfigString { IPConfiguration.getInstance().generateState() })
            "showNotification" -> handleShowNotification(call, result)
            "unregisterNetwork" -> { handleUnregisterNetwork(); result.success(null) }
            "enableLog" -> { IPConfiguration.getInstance().debug = true; result.success(null) }
            "getLog" -> result.success(IPLogs.getInstance().LOG ?: "")
            "updateLocale" -> { handleUpdateLocale(call); result.success(null) }
            "updateTheme" -> { handleUpdateTheme(call); result.success(null) }
            else -> result.success("unregister function")
        }
    }

    private fun createAuthListener(result: Result) = object : AuthenticationListener {
        override fun onSuccess(response: String) {
            finishAuth()
            mainHandler.post {
                result.success(response)
            }
        }

        override fun onFail(errorResult: AuthenticationError) {
            finishAuth()
            mainHandler.post {
                result.error(errorResult.error_code.code, errorResult.error_message, null)
            }
        }

        override fun onIMCancel() {
            finishAuth()
            mainHandler.post {
                result.error(ErrorCode.AUTHENTICATE_IM_CANCEL.code, "im_canceled", null)
            }
        }
    }

    private fun handleAuthentication(call: MethodCall, result: Result) {
        if (!beginAuthRequest(result)) {
            return
        }

        val loginHint = call.argument<String>("login_hint") ?: ""
        val helper = getOrCreateAuthHelper(result)
        if (helper == null) {
            finishAuth()
            mainHandler.post {
                result.error("NO_ACTIVITY", "Activity not available", null)
            }
            return
        }
        helper.doAuthentication(loginHint, createAuthListener(result))
    }

    private fun handleAuthenticationWithChannel(call: MethodCall, result: Result) {
        if (!beginAuthRequest(result)) {
            return
        }

        val loginHint = call.argument<String>("login_hint") ?: ""
        val channel = call.argument<String>("channel") ?: ""
        val currentActivity = activity
        val helper = getOrCreateAuthHelper(result)
        if (currentActivity == null || helper == null) {
            finishAuth()
            mainHandler.post {
                result.error("NO_ACTIVITY", "Activity not available", null)
            }
            return
        }
        helper.startAuthorization(currentActivity, loginHint, channel, createAuthListener(result))
    }

    private fun handleIMAuthentication(call: MethodCall, result: Result) {
        if (!beginAuthRequest(result)) {
            return
        }

        val channel = call.argument<String>("channel") ?: ""
        val currentActivity = activity
        val helper = getOrCreateAuthHelper(result)
        if (currentActivity == null || helper == null) {
            finishAuth()
            mainHandler.post {
                result.error("NO_ACTIVITY", "Activity not available", null)
            }
            return
        }
        helper.startAuthorization(currentActivity, channel, createAuthListener(result))
    }

    private fun handleAuthenticationWithChannels(call: MethodCall, result: Result) {
        if (!beginAuthRequest(result)) {
            return
        }

        val loginHint = call.argument<String>("login_hint") ?: ""
        val currentActivity = activity
        val helper = getOrCreateAuthHelper(result)
        if (currentActivity == null || helper == null) {
            finishAuth()
            mainHandler.post {
                result.error("NO_ACTIVITY", "Activity not available", null)
            }
            return
        }
        helper.startMultiAuthentication(currentActivity, loginHint, createAuthListener(result))
    }

    private fun handleStartSMSAuthentication(call: MethodCall, result: Result) {
        if (!beginAuthRequest(result)) {
            return
        }

        val phoneNumber = call.argument<String>("phone_number") ?: ""
        val scope = call.argument<String>("scope")
        if (phoneNumber.isBlank()) {
            finishAuth()
            result.error("invalid_parameter", "phone_number cannot be empty", null)
            return
        }

        val helper = getOrCreateAuthHelper(result)
        if (helper == null) {
            finishAuth()
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        helper.startSMSAuthentication(
            phoneNumber,
            scope,
            { response ->
                finishAuth()
                mainHandler.post { result.success(response) }
            },
            { error ->
                finishAuth()
                mainHandler.post { result.error(error.error_code.code, error.error_message, null) }
            }
        )
    }

    private fun handleVerifySMSOTP(call: MethodCall, result: Result) {
        if (!beginAuthRequest(result)) {
            return
        }

        val otpCode = call.argument<String>("otp_code") ?: ""
        val authReqId = call.argument<String>("auth_req_id") ?: ""
        val nonce = call.argument<String>("nonce") ?: ""
        if (otpCode.isBlank() || authReqId.isBlank() || nonce.isBlank()) {
            finishAuth()
            result.error("invalid_parameter", "otp_code, auth_req_id, and nonce are required", null)
            return
        }

        val helper = getOrCreateAuthHelper(result)
        if (helper == null) {
            finishAuth()
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        helper.verifySMSOTP(
            otpCode,
            authReqId,
            nonce,
            { response ->
                finishAuth()
                mainHandler.post { result.success(response) }
            },
            { error ->
                finishAuth()
                mainHandler.post { result.error(error.error_code.code, error.error_message, null) }
            }
        )
    }

    private fun handleCheckCoverage(result: Result) {
        if (!beginCoverageRequest(result)) {
            return
        }

        val helper = createCoverageHelper(result)
        if (helper == null) {
            finishCoverage()
            mainHandler.post {
                result.error("NO_ACTIVITY", "Activity not available", null)
            }
            return
        }

        helper.checkCoverage(
            { response ->
                finishCoverage()
                mainHandler.post {
                    result.success(response)
                }
            },
            { error ->
                finishCoverage()
                mainHandler.post {
                    result.error(error.error_code.code, error.error_message, null)
                }
            }
        )
    }

    private fun handleCheckCoverageWithPhoneNumber(call: MethodCall, result: Result) {
        if (!beginCoverageRequest(result)) {
            return
        }

        val phoneNumber = call.argument<String>("phone_number")
        if (phoneNumber.isNullOrEmpty()) {
            finishCoverage()
            mainHandler.post {
                result.error("invalid_parameter", "phoneNumber cannot be empty", null)
            }
            return
        }

        val helper = createCoverageHelper(result)
        if (helper == null) {
            finishCoverage()
            mainHandler.post {
                result.error("NO_ACTIVITY", "Activity not available", null)
            }
            return
        }

        helper.checkCoverage(phoneNumber,
            { response ->
                finishCoverage()
                mainHandler.post {
                    result.success(response)
                }
            },
            { error ->
                finishCoverage()
                mainHandler.post {
                    result.error(error.error_code.code, error.error_message, null)
                }
            }
        )
    }

    private fun handleSetConfiguration(call: MethodCall) {
        // Kept as a no-op for Flutter API compatibility.
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

    private fun handleSetBaseUrl(call: MethodCall) {
        val baseUrl = call.argument<String>("value")
        if (!baseUrl.isNullOrEmpty()) {
            activity?.let {
                IPConfiguration.getInstance().BASE_URL = baseUrl
            }
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

    private fun handleSetAuthChannels(call: MethodCall, result: Result) {
        val channels = call.argument<List<String>>("channels").orEmpty()
            .mapNotNull { value ->
                runCatching { AuthChannel.valueOf(value.uppercase()) }.getOrNull()
            }

        if (channels.isEmpty()) {
            result.error("invalid_parameter", "channels cannot be empty", null)
            return
        }

        IPConfiguration.getInstance().AUTH_CHANNELS = channels
        result.success(null)
    }

    private fun handleSetSMSConfiguration(call: MethodCall, result: Result) {
        IPConfiguration.getInstance().apply {
            call.argument<String>("sandbox_backend_url")?.takeIf(String::isNotBlank)?.let {
                SMS_BACKEND_URL_SANDBOX = it
            }
            call.argument<String>("production_backend_url")?.takeIf(String::isNotBlank)?.let {
                SMS_BACKEND_URL_PRODUCTION = it
            }
            call.argument<String>("auth_path")?.takeIf(String::isNotBlank)?.let {
                SMS_AUTH_PATH = it
            }
            call.argument<String>("token_path")?.takeIf(String::isNotBlank)?.let {
                SMS_TOKEN_PATH = it
            }
            call.argument<String>("scope")?.takeIf(String::isNotBlank)?.let {
                SMS_SCOPE_VERIFY_PHONE = it
            }
        }
        result.success(null)
    }

    private fun handleSetTS43Configuration(call: MethodCall, result: Result) {
        IPConfiguration.getInstance().apply {
            call.argument<String>("sandbox_backend_url")?.takeIf(String::isNotBlank)?.let {
                TS43_BACKEND_URL_SANDBOX = it
            }
            call.argument<String>("production_backend_url")?.takeIf(String::isNotBlank)?.let {
                TS43_BACKEND_URL_PRODUCTION = it
            }
            call.argument<String>("auth_path")?.takeIf(String::isNotBlank)?.let {
                TS43_AUTH_PATH = it
            }
            call.argument<String>("token_path")?.takeIf(String::isNotBlank)?.let {
                TS43_TOKEN_PATH = it
            }
            call.argument<String>("scope_verify_phone")?.takeIf(String::isNotBlank)?.let {
                TS43_SCOPE_VERIFY_PHONE = it
            }
            call.argument<String>("scope_get_phone")?.takeIf(String::isNotBlank)?.let {
                TS43_SCOPE_GET_PHONE = it
            }
            call.argument<String>("default_login_hint")?.takeIf(String::isNotBlank)?.let {
                TS43_DEFALT_LOGIN_HINT_SCOPE_GET_PHONE = it
            }
            call.argument<String>("default_carrier_hint")?.let {
                TS43_DEFAULT_CARRIER_HINT = it
            }
        }
        result.success(null)
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
            val unregisterResult = IPificationServices.unregisterNetwork(it)
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
        getOrCreateAuthHelper(result)?.let(action)
    }

    private fun getOrCreateAuthHelper(result: Result? = null): AuthenticationHelper? {
        val currentActivity = activity ?: return null

        if (authenticationHelper == null) {
            authenticationHelper = AuthenticationHelper(IPApiService(currentActivity))
        }

        return authenticationHelper
    }

    private fun createCoverageHelper(result: Result? = null): AuthenticationHelper? {
        val currentActivity = activity ?: return null

        return AuthenticationHelper(IPApiService(currentActivity))
    }

    private fun getConfigString(action: () -> String?): String? {
        return activity?.let { action() }
    }

    private fun beginAuthRequest(result: Result): Boolean {
        if (!authInProgress.compareAndSet(false, true)) {
            result.error("request_in_progress", "Authentication request already in progress", null)
            return false
        }
        return true
    }

    private fun beginCoverageRequest(result: Result): Boolean {
        if (!coverageInProgress.compareAndSet(false, true)) {
            result.error("request_in_progress", "Coverage request already in progress", null)
            return false
        }
        return true
    }

    private fun finishAuth() {
        authInProgress.set(false)
        authenticationHelper = null
    }

    private fun finishCoverage() {
        coverageInProgress.set(false)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        IMService.onActivityResult(requestCode, resultCode, data)
        return true
    }
}
