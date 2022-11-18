package com.ipification.plugin

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.ipification.plugin.AuthenticationHelper
import com.ipification.plugin.IPApiService
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.IPConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.ActivityLifecycleListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.atomic.AtomicBoolean
import android.net.Uri
import android.content.Intent;
import android.graphics.Color
import android.view.View
import com.ipification.mobile.sdk.android.IPificationServices
import com.ipification.mobile.sdk.android.utils.IPConstant
import com.ipification.mobile.sdk.im.IMLocale
import io.flutter.plugin.common.BinaryMessenger
import com.ipification.mobile.sdk.im.IMService
import com.ipification.mobile.sdk.im.IMTheme
import com.ipification.mobile.sdk.im.ui.IMVerificationActivity
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import com.ipification.mobile.sdk.android.IPEnvironment

/** IPificationPlugin */
class IPificationPlugin: FlutterPlugin, MethodCallHandler , ActivityAware, ActivityResultListener{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private val authInProgress: AtomicBoolean = AtomicBoolean(false)
  private var authenticationHelper: AuthenticationHelper?=null
  private val TAG = "IPificationPlugin";
  private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null


  fun registerWith(registrar: Registrar) {
    val activity: Activity? = registrar.activity()
    ContextHelper.context = activity
    val plugin = IPificationPlugin()
    plugin.setup(registrar.messenger(), activity, registrar, null)
  }
  private fun setup(
    messenger: BinaryMessenger?,
    activity: Activity?,
    registrar: Registrar?,
    activityBinding: ActivityPluginBinding?
  ) {
    if(messenger != null){
      channel = MethodChannel(messenger!!, "ipification_plugin")
      channel.setMethodCallHandler(this)
    }
    Log.e(TAG, "setup")
    if (registrar != null) {
      // V1 embedding setup for activity listeners.
      registrar.addActivityResultListener(this)
      // registrar.addRequestPermissionsResultListener(this)
    } else {
      // V2 embedding setup for activity listeners.
      activityBinding?.addActivityResultListener(this)
      // activityBinding.addRequestPermissionsResultListener(this)
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ipification_plugin")
    channel.setMethodCallHandler(this)
    pluginBinding = flutterPluginBinding;
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    ContextHelper.context = activity
    channel.setMethodCallHandler(this)
    setup(pluginBinding?.binaryMessenger, activity, null, binding);
  }

  override fun onDetachedFromActivity() {
    activity?.let {
       activity = null
       ContextHelper.context = null
       channel.setMethodCallHandler(null);
     }

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    ContextHelper.context = activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

    if (call.method == "doAuthentication") {

      if (authInProgress.get()) {
        return
      }
      var login_hint = call.argument<String>("login_hint")
      if(login_hint.isNullOrEmpty()){
        login_hint = ""
      }
      authInProgress.set(true)
      if(authenticationHelper == null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
      }

      val listener= object :AuthenticationListener{
        override fun onSuccess(response: String) {
          if (authInProgress.compareAndSet(true, false)) {
            activity?.runOnUiThread{
              result.success(response)
            }
          }
          authenticationHelper = null
        }

        override fun onFail(errorResult: AuthenticationError) {

          if (authInProgress.compareAndSet(true, false)) {
             activity?.runOnUiThread{
               result.error(errorResult.error_code.code,errorResult.error_message,null)
             }  
          }
          authenticationHelper = null
        }
        override fun onIMCancel() {
          result.error(ErrorCode.AUTHENTICATE_IM_CANCEL.code, "im_canceled", null)
        }

        // override fun onError(errorResult: AuthenticationError) {
        //   if (authInProgress.compareAndSet(true, false)) {
        //       result.error(errorResult.error_code.code, errorResult.error_message, null)
        //   }
        //   authenticationHelper = null
        // }
      }
      authenticationHelper?.doAuthentication(login_hint, listener)



    } 
    else if (call.method == "doAuthenticationWithChannel") {

      if (authInProgress.get()) {
        return
      }
      var login_hint = call.argument<String>("login_hint")
      if(login_hint.isNullOrEmpty()){
        login_hint = ""
      }
      var channel = call.argument<String>("channel")
      if(channel.isNullOrEmpty()){
        channel = ""
      }
      authInProgress.set(true)
      if(authenticationHelper == null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
      }

      val listener= object :AuthenticationListener{
        override fun onSuccess(response: String) {
          if (authInProgress.compareAndSet(true, false)) {
            activity?.runOnUiThread{
              result.success(response)
            }
            
          }
          authenticationHelper = null  
        }
        override fun onFail(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
             activity?.runOnUiThread{
               result.error(errorResult.error_code.code,errorResult.error_message,null)
             }
             
          }
          authenticationHelper = null
        }

        override fun onIMCancel() {
          result.error(ErrorCode.AUTHENTICATE_IM_CANCEL.code, "im_canceled", null)
        }
      }
      authenticationHelper?.startAuthorization(activity!!, login_hint ,channel,listener)
    } 
    else if (call.method == "doIMAuthentication") {

      if (authInProgress.get()) {
        return
      }
      var channel = call.argument<String>("channel")
      if(channel.isNullOrEmpty()){
        channel = ""
      }
      authInProgress.set(true)
      if(authenticationHelper == null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
      }

      val listener= object :AuthenticationListener{
        override fun onSuccess(response: String) {
          if (authInProgress.compareAndSet(true, false)) {
            activity?.runOnUiThread{
              result.success(response)
            }
          }
          authenticationHelper = null
        }
        override fun onFail(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
             activity?.runOnUiThread{
               result.error(errorResult.error_code.code,errorResult.error_message,null)
             }
          }
          authenticationHelper = null
        }
        override fun onIMCancel() {
          result.error(ErrorCode.AUTHENTICATE_IM_CANCEL.code, "im_canceled", null)
        }
      }
      authenticationHelper?.startAuthorization(activity!!, channel, listener)
    }    
    else if(call.method == "checkCoverage") {

      if (authInProgress.get()) {
        return
      }

      authInProgress.set(true)
      if(authenticationHelper == null){
        authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
      }
      authenticationHelper?.checkCoverage({
        if (authInProgress.compareAndSet(true, false)) {
          activity?.runOnUiThread {
            result.success(it)
          }
        }
        authenticationHelper = null
      }, {
        if (authInProgress.compareAndSet(true, false)) {
          activity?.runOnUiThread{
            result.error(it.error_code.code, it.error_message, null)
          }
        }
        authenticationHelper = null
      })

    }
    else if(call.method == "checkCoverageWithPhoneNumber") {

      if (authInProgress.get()) {
        return
      }

      authInProgress.set(true)
      if(authenticationHelper == null){
        authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
      }
      //20092021
      var phoneNumber = call.argument<String>("phone_number")
      if(phoneNumber.isNullOrEmpty()){
        activity?.runOnUiThread{
          result.error("invalid_parameter", "phoneNumber cannot be empty", null)
        }
        authInProgress.set(false)
        return
      }

      authenticationHelper?.checkCoverage(phoneNumber, {
        if (authInProgress.compareAndSet(true, false)) {
          activity?.runOnUiThread {
            result.success(it)
          }
        }
        authenticationHelper = null
      },{
        if (authInProgress.compareAndSet(true, false)) {
          activity?.runOnUiThread{
            result.error(it.error_code.code, it.error_message, null)
          }
        }
        authenticationHelper = null
      })
      

    }
    else if(call.method == "setConfiguration"){
      val json_config = call.argument<String>("config_file_name")
      if (!json_config.isNullOrEmpty()){
        if(BuildConfig.DEBUG) {
          Log.d(TAG, "config_file_name: $result")
        }
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        authenticationHelper?.setConfiguration(json_config)
      }

    }
    else if(call.method == "getConfiguration"){
      val configName = call.argument<String>("config_name")
      if (!configName.isNullOrEmpty()){
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        activity?.runOnUiThread {
          result.success(authenticationHelper?.getConfigurationByName(configName))
        }

      }

    }
    else if(call.method == "setEnv"){
      val env = call.argument<String>("value")
      if (env == "production"){
        activity?.let {
          IPConfiguration.getInstance().ENV = IPEnvironment.PRODUCTION
        }
      } else{
        activity?.let {
          IPConfiguration.getInstance().ENV = IPEnvironment.SANDBOX
        }
      }
    }
    else if(call.method == "getClientId"){
      activity?.let {
        result.success(IPConfiguration.getInstance().CLIENT_ID)
      }
    }
    else if(call.method == "getRedirectUri"){
      activity?.let {
        result.success(IPConfiguration.getInstance().REDIRECT_URI.toString())
      }
    }
    else if(call.method == "setClientId"){
      val clientValue = call.argument<String>("value")
      if (!clientValue.isNullOrEmpty()){
        activity?.let {
          IPConfiguration.getInstance().CLIENT_ID = clientValue
        }
      }
    }
    else if(call.method == "setRedirectUri"){
      val redirectValue = call.argument<String>("value")
      if (!redirectValue.isNullOrEmpty()){
        activity?.let {
          IPConfiguration.getInstance().REDIRECT_URI = Uri.parse(redirectValue)
        }
      }
    }
    else if(call.method == "setCheckCoverageUrl"){
      
      val coverageValue = call.argument<String>("value")
      if (!coverageValue.isNullOrEmpty()){
        activity?.let {
          IPConfiguration.getInstance().customUrls = true
          IPConfiguration.getInstance().COVERAGE_URL = Uri.parse(coverageValue)
        }
      }
    }
    else if(call.method == "setAuthorizationUrl"){
      
      val authorizationValue = call.argument<String>("value")
      if (!authorizationValue.isNullOrEmpty()){
        activity?.let {
          IPConfiguration.getInstance().customUrls = true
          IPConfiguration.getInstance().AUTHORIZATION_URL = Uri.parse(authorizationValue)
        }
      }
    }
    
    
    else if(call.method == "addQueryParam"){
      activity?.let {
        var key = call.argument<String>("key") ?: ""
        var value = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        authenticationHelper?.addQueryParam(key, value)
      }
    }
    else if(call.method == "setState"){
      activity?.let {
        var state = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        authenticationHelper?.setState(state)
      }
    }
    else if(call.method == "setScope"){
      activity?.let {
        var scope = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(it))
        }
        authenticationHelper?.setScope(scope)
      }
    }
    else if(call.method == "generateState"){
      activity?.let {
        result.success(IPConfiguration.getInstance().generateState())
      }
    }
    else if(call.method == "showNotification"){
      Log.d(TAG,"context: " + ContextHelper.context)
      if(activity == null){
        activity = ContextHelper.context
      }
      try{
        val title = call.argument<String>("title") ?: ""
        val message = call.argument<String>("message") ?: ""
        val notificationFolder = call.argument<String>("notificationFolder") ?: ""
        val notiIcon = call.argument<String>("notificationIcon") ?: ""
        Log.d(TAG,"context: " + notificationFolder + notiIcon)
        activity?.let {
          Log.e(TAG, "showNotification ")
          val notificationIcon = it.resources.getIdentifier(notiIcon, notificationFolder , it.packageName)
          IMService.showIPNotification(activity!!, title, message, notificationIcon);
        }
      }catch(e: Exception){
        Log.e(TAG, "showNotification error : ${e.message}")
      }
    } else if(call.method == "unregisterNetwork"){
      activity?.let {
        val result =  CellularService.unregisterNetwork(activity!!)
        if(BuildConfig.DEBUG) {
          Log.d(TAG, "unregisterNetwork: $result")
        }
      }
    }
    else if(call.method == "enableLog"){
      IPConfiguration.getInstance().debug = true
    }
    else if(call.method == "getLog"){
      result.success(IPConstant.getInstance().LOG ?: "")
    }
    else if(call.method == "updateLocale"){
      activity?.let {
        try{
          val mainTitle = call.argument<String>("mainTitle") ?: ""
          val description = call.argument<String>("description") ?: ""
          val whatsappBtnText = call.argument<String>("whatsappBtnText") ?: ""
          val telegramBtnText = call.argument<String>("telegramBtnText") ?: ""
          val viberBtnText = call.argument<String>("viberBtnText") ?: ""
          val toolbarTitle = call.argument<String>("toolbarTitle") ?: ""
          val isVisible = call.argument<Boolean>("isVisible") ?: true
          IPificationServices.locale = IMLocale(mainTitle = mainTitle,
            description = description,
            whatsappText = whatsappBtnText,
            telegramText = telegramBtnText,
            viberText = viberBtnText,
            toolbarTitle = toolbarTitle,
            toolbarVisibility = if(isVisible) { View.VISIBLE } else View.GONE
            )
          
        }catch (e: java.lang.Exception){
          Log.e(TAG, "updateLocale: ${e.message}")
        }
      }
    }
    else if(call.method == "updateTheme"){
      activity?.let {
        try{
          val backgroundColor = call.argument<String>("backgroundColor") ?: ""
          val toolbarTextColor = call.argument<String>("toolbarTextColor") ?: ""
          val toolbarColor = call.argument<String>("toolbarColor") ?: ""
          
          Log.d(TAG, "backgroundColor")

          Log.d(TAG, backgroundColor ?: "")
          IPificationServices.theme = IMTheme(
            backgroundColor = Color.parseColor(backgroundColor),
            toolbarTextColor = Color.parseColor(toolbarTextColor),
            toolbarColor = Color.parseColor(toolbarColor)
            
          )

        }catch (e: java.lang.Exception){
          Log.e(TAG, "updateTheme: ${e.message}")
        }
      }
    }
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = null;
  }

  override fun onActivityResult(requestCode:Int, resultCode:Int, data: Intent?): Boolean
  {
    IMService.onActivityResult(requestCode, resultCode, data)
    return true
  }
  

}
