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
            "setConfiguration" -> handleSetConfiguration(call, result)
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

    private fun handleSetConfiguration(call: MethodCall, result: Result) {
        if (call.argument<String>("config_file_name") != null) {
            // Kept as a no-op for Flutter API compatibility.
            result.success(null)
            return
        }

        val authChannels = call.argument<List<String>>("auth_channels")
        if (authChannels != null) {
            val channels = authChannels.mapNotNull { value ->
                runCatching { AuthChannel.valueOf(value.uppercase()) }.getOrNull()
            }
            if (channels.size != authChannels.size) {
                result.error("invalid_parameter", "Unsupported auth channel", null)
                return
            }
            IPConfiguration.getInstance().AUTH_CHANNELS = channels
        }

        IPConfiguration.getInstance().apply {
            call.argument<Boolean>("debug")?.let { debug = it }
            call.argument<Boolean>("dns_debug")?.let { dnsDebug = it }
            call.argument<Boolean>("extra_debug")?.let { extraDebug = it }
            call.argument<String>("env")?.let {
                ENV = if (it == "production") IPEnvironment.PRODUCTION else IPEnvironment.SANDBOX
            }
            call.argument<String>("client_id")?.let { CLIENT_ID = it }
            call.argument<String>("redirect_uri")?.let { REDIRECT_URI = Uri.parse(it) }
            call.argument<Number>("state_length")?.let { STATE_LENGTH = it.toInt() }
            call.argument<String>("current_state")?.let { currentState = it }
            call.argument<String>("current_url")?.let { currentUrl = it }
            call.argument<Boolean>("automatic_state_generation_enabled")?.let {
                automaticStateGenerationEnabled = it
            }
            call.argument<Boolean>("send_error_reports_enabled")?.let {
                sendErrorReportsEnabled = it
            }
            call.argument<Boolean>("error_report_enable_carrier_headers")?.let {
                errorReportEnableCarrierHeaders = it
            }
            call.argument<Number>("error_report_timeout")?.let { ERROR_REPORT_TIMEOUT = it.toLong() }
            call.argument<Boolean>("enable_single_request")?.let { enableSingleRequest = it }
            call.argument<String>("default_scope")?.let { DEFAULT_SCOPE = it }
            call.argument<String>("okhttp_user_agent")?.let { OKHTTP_USER_AGENT = it }
            call.argument<String>("okhttp_accept")?.let { OKHTTP_ACCEPT = it }
            call.argument<String>("sdk_type_value")?.let { SDK_TYPE_VALUE = it }
            call.argument<Boolean>("auto_unregister_network")?.let { autoUnregisterNetwork = it }
            call.argument<Boolean>("only_affected_brands")?.let { onlyAffectedBrands = it }
            call.argument<Boolean>("retry_on_connection_failure")?.let {
                retryOnConnectionFailure = it
            }
            call.argument<Number>("max_retries")?.let { MAX_RETRIES = it.toInt() }
            call.argument<Boolean>("enabled_handle_cookie")?.let { enabledHandleCookie = it }
            call.argument<Boolean>("coverage_always_true")?.let { coverageAlwaysTrue = it }
            call.argument<String>("response_type_code")?.let { RESPONSE_TYPE_CODE = it }
            call.argument<String>("coverage_path_forced_true")?.let {
                COVERAGE_PATH_FORCED_TRUE = it
            }
            call.argument<String>("login_hint")?.let { LOGIN_HINT = it }
            call.argument<String>("coverage_url_stage")?.let { COVERAGE_URL_STAGE = it }
            call.argument<String>("coverage_url_live")?.let { COVERAGE_URL_LIVE = it }
            call.argument<String>("auth_url_stage")?.let { AUTH_URL_STAGE = it }
            call.argument<String>("auth_url_live")?.let { AUTH_URL_LIVE = it }
            call.argument<String>("sdk_log_url_stage")?.let { SDK_LOG_URL_STAGE = it }
            call.argument<String>("sdk_log_url_live")?.let { SDK_LOG_URL_LIVE = it }
            call.argument<String>("coverage_url")?.let {
                customUrls = true
                COVERAGE_URL = Uri.parse(it)
            }
            call.argument<String>("authorization_url")?.let {
                customUrls = true
                AUTHORIZATION_URL = Uri.parse(it)
            }
            call.argument<Boolean>("custom_urls")?.let { customUrls = it }
            call.argument<Boolean>("enable_params_validation")?.let {
                enableParamsValidation = it
            }
            call.argument<String>("base_url")?.let { BASE_URL = it }
            call.argument<String>("realm")?.let { REALM = it }
            call.argument<String>("coverage_path")?.let { COVERAGE_PATH = it }
            call.argument<String>("auth_path")?.let { AUTH_PATH = it }
            call.argument<String>("sdk_log_path")?.let { SDK_LOG_PATH = it }
            call.argument<Number>("coverage_read_timeout")?.let {
                COVERAGE_READ_TIMEOUT = it.toLong()
            }
            call.argument<Number>("coverage_connect_timeout")?.let {
                COVERAGE_CONNECT_TIMEOUT = it.toLong()
            }
            call.argument<Number>("auth_read_timeout")?.let { AUTH_READ_TIMEOUT = it.toLong() }
            call.argument<Number>("auth_connect_timeout")?.let {
                AUTH_CONNECT_TIMEOUT = it.toLong()
            }
            call.argument<Number>("connect_network_timeout")?.let {
                CONNECT_NETWORK_TIMEOUT = it.toLong()
            }
            call.argument<Number>("connect_network_timeout_short")?.let {
                CONNECT_NETWORK_TIMEOUT_SHORT = it.toLong()
            }
            call.argument<String>("consent_id_value")?.let { CONSENT_ID_VALUE = it }
            call.argument<Number>("timeout_release_network")?.let {
                TIMEOUT_RELEASE_NETWORK = it.toLong()
            }
            call.argument<Number>("default_timeout_release_network")?.let {
                DEFAULT_TIMEOUT_RELEASE_NETWORK = it.toLong()
            }
            call.argument<String>("cellular_private_ip")?.let { CELLULAR_PRIVATE_IP = it }
            call.argument<Boolean>("bind_app_to_cellular_network")?.let {
                bindAppToCellularNetwork = it
            }
            call.argument<Boolean>("use_web_view_instead_of_api")?.let {
                useWebViewInsteadOfApi = it
            }
            call.argument<String>("ip_token_url")?.let { IP_TOKEN_URL = it }
            call.argument<Boolean>("enable_save_session_in_preference")?.let {
                enable_Save_Session_In_Preference = it
            }
            call.argument<String>("whatsapp_package_name")?.let { whatsappPackageName = it }
            call.argument<String>("telegram_package_name")?.let { telegramPackageName = it }
            call.argument<String>("telegram_web_package_name")?.let { telegramWebPackageName = it }
            call.argument<String>("viber_package_name")?.let { viberPackageName = it }
            call.argument<Boolean>("im_auto_mode")?.let { IM_AUTO_MODE = it }
            call.argument<List<String>>("im_priority_app_list")?.let {
                IM_PRIORITY_APP_LIST = it.toTypedArray()
            }
            call.argument<Boolean>("validate_im_apps")?.let { validateIMApps = it }
            call.argument<Number>("notification_id")?.let { NOTIFICATION_ID = it.toInt() }
            call.argument<Number>("request_code")?.let { REQUEST_CODE = it.toInt() }
            call.argument<String>("ts43_sandbox_backend_url")?.let {
                TS43_BACKEND_URL_SANDBOX = it
            }
            call.argument<String>("ts43_production_backend_url")?.let {
                TS43_BACKEND_URL_PRODUCTION = it
            }
            call.argument<String>("ts43_auth_path")?.let { TS43_AUTH_PATH = it }
            call.argument<String>("ts43_token_path")?.let { TS43_TOKEN_PATH = it }
            call.argument<String>("ts43_scope_verify_phone")?.let {
                TS43_SCOPE_VERIFY_PHONE = it
            }
            call.argument<String>("ts43_scope_get_phone")?.let { TS43_SCOPE_GET_PHONE = it }
            call.argument<String>("ts43_default_login_hint")?.let {
                TS43_DEFALT_LOGIN_HINT_SCOPE_GET_PHONE = it
            }
            call.argument<String>("ts43_default_carrier_hint")?.let {
                TS43_DEFAULT_CARRIER_HINT = it
            }
            call.argument<String>("sms_sandbox_backend_url")?.let {
                SMS_BACKEND_URL_SANDBOX = it
            }
            call.argument<String>("sms_production_backend_url")?.let {
                SMS_BACKEND_URL_PRODUCTION = it
            }
            call.argument<String>("sms_auth_path")?.let { SMS_AUTH_PATH = it }
            call.argument<String>("sms_token_path")?.let { SMS_TOKEN_PATH = it }
            call.argument<String>("sms_scope_verify_phone")?.let { SMS_SCOPE_VERIFY_PHONE = it }
        }
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
            // result.error("request_in_progress", "Authentication request already in progress", null)
            return false
        }
        return true
    }

    private fun beginCoverageRequest(result: Result): Boolean {
        if (!coverageInProgress.compareAndSet(false, true)) {
            // result.error("request_in_progress", "Coverage request already in progress", null)
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
