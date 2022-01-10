package com.ipification.sdk.ip_sdk

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
import com.example.ip_sdk.AuthenticationHelper
import com.example.ip_sdk.IPApiService
import com.ipification.mobile.sdk.android.CellularService
import com.ipification.mobile.sdk.android.IPConfigurationFile
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
import io.flutter.plugin.common.BinaryMessenger
import com.ipification.mobile.sdk.im.IMService
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

/** IpSdkPlugin */
class IpSdkPlugin: FlutterPlugin, MethodCallHandler ,ActivityAware, ActivityResultListener{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private  var activity: Activity? = null
  private val authInProgress: AtomicBoolean = AtomicBoolean(false)
  private var authenticationHelper: AuthenticationHelper?=null
  private val TAG = "IpSdk";
  private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null


  fun registerWith(registrar: Registrar) {
    val activity: Activity = registrar.activity()
    val plugin = IpSdkPlugin()
    plugin.setup(registrar.messenger(), activity, registrar, null)
  }
  private fun setup(
    messenger: BinaryMessenger?,
    activity: Activity?,
    registrar: Registrar?,
    activityBinding: ActivityPluginBinding?
  ) {
    if(messenger != null){
      channel = MethodChannel(messenger!!, "ip_sdk")
      channel.setMethodCallHandler(this)
    }
    
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
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ip_sdk")
    pluginBinding = flutterPluginBinding;
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    channel.setMethodCallHandler(this)
    setup(pluginBinding?.binaryMessenger, activity, null, binding);
  }

  override fun onDetachedFromActivity() {
    activity?.let {
       val result =  CellularService.Companion.unregisterNetwork(activity!!)
       if(BuildConfig.DEBUG) {
         Log.d(TAG, "unregisterNetwork: $result")
       }
       activity = null
       channel.setMethodCallHandler(null);
     }

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
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
        }

        override fun onFail(errorResult: AuthenticationError) {

          if (authInProgress.compareAndSet(true, false)) {
             activity?.runOnUiThread{
               result.error(errorResult.error_code.code,errorResult.error_message,null)
             }
          }
        }

        override fun onError(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
              result.error(errorResult.error_code.code, errorResult.error_message, null)
          }
        }
      }
      authenticationHelper?.doAuthentication(login_hint,listener)



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
        }
        override fun onFail(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
             activity?.runOnUiThread{
               result.error(errorResult.error_code.code,errorResult.error_message,null)
             }
          }
        }

        override fun onError(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
              result.error(errorResult.error_code.code, errorResult.error_message, null)
          }
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
        }
        override fun onFail(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
             activity?.runOnUiThread{
               result.error(errorResult.error_code.code,errorResult.error_message,null)
             }
          }
        }

        override fun onError(errorResult: AuthenticationError) {
          if (authInProgress.compareAndSet(true, false)) {
              result.error(errorResult.error_code.code, errorResult.error_message, null)
          }
        }
      }
      authenticationHelper?.startAuthorization(activity!!, channel, listener)
    }    
    else if(call.method=="checkCoverage") {

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
      },{
        if (authInProgress.compareAndSet(true, false)) {
          activity?.runOnUiThread{
            result.error(it.error_code.code, it.error_message, null)
          }
        }
      })

    }
    else if(call.method=="checkCoverageWithPhoneNumber") {

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
      },{
        if (authInProgress.compareAndSet(true, false)) {
          activity?.runOnUiThread{
            result.error(it.error_code.code, it.error_message, null)
          }
        }
      })
      

    }
    else if(call.method=="setConfiguration"){
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
    else if(call.method=="getConfiguration"){
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
    else if(call.method=="getClientId"){
      activity?.let {
        result.success(IPConfigurationFile.getInstance().CLIENT_ID)
      }
    }
    else if(call.method=="getRedirectUri"){
      activity?.let {
        result.success(IPConfigurationFile.getInstance().REDIRECT_URI.toString())
      }
    }
    else if(call.method=="setClientId"){
      val clientValue = call.argument<String>("value")
      if (!clientValue.isNullOrEmpty()){
        activity?.let {
          IPConfigurationFile.getInstance().CLIENT_ID = clientValue
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="setRedirectUri"){
      val redirectValue = call.argument<String>("value")
      if (!redirectValue.isNullOrEmpty()){
        activity?.let {
          IPConfigurationFile.getInstance().REDIRECT_URI = Uri.parse(redirectValue)
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="setCheckCoverageUrl"){
      val coverageValue = call.argument<String>("value")
      if (!coverageValue.isNullOrEmpty()){
        activity?.let {
          IPConfigurationFile.getInstance().COVERAGE_URL = Uri.parse(coverageValue)
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="setAuthorizationUrl"){
      val authorizationValue = call.argument<String>("value")
      if (!authorizationValue.isNullOrEmpty()){
        activity?.let {
          IPConfigurationFile.getInstance().AUTHORIZATION_URL = Uri.parse(authorizationValue)
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    
    else if(call.method=="unregisterNetwork"){
        activity?.let {
          val result =  CellularService.Companion.unregisterNetwork(activity!!)
          if(BuildConfig.DEBUG) {
            Log.d(TAG, "unregisterNetwork: $result")
          }
          activity = null
          channel.setMethodCallHandler(null);
        }
    }
    else if(call.method=="addQueryParam"){
      activity?.let {
        var key = call.argument<String>("key") ?: ""
        var value = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        authenticationHelper?.addQueryParam(key, value)
      }
    }
    else if(call.method=="setState"){
      activity?.let {
        var state = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        authenticationHelper?.setState(state)
      }
    }
    else if(call.method=="setScope"){
      activity?.let {
        var scope = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(activity!!))
        }
        authenticationHelper?.setScope(scope)
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    pluginBinding = null;
  }

  override fun onActivityResult(requestCode:Int, resultCode:Int, data:Intent): Boolean
  {
    IMService.onActivityResult(requestCode, resultCode, data)
    return true
  }

}
