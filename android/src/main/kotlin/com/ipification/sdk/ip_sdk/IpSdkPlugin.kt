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

/** IpSdkPlugin */
class IpSdkPlugin: FlutterPlugin, MethodCallHandler ,ActivityAware{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private  var context: Activity? = null
  private val authInProgress: AtomicBoolean = AtomicBoolean(false)
  private var authenticationHelper: AuthenticationHelper?=null
  private val TAG = "IpSdk";

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ip_sdk")



  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    context = binding.activity
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromActivity() {
     context?.let {
       val result =  CellularService.Companion.unregisterNetwork(context!!)
       if(BuildConfig.DEBUG) {
         Log.d(TAG, "unregisterNetwork: $result")
       }
       context = null
       channel.setMethodCallHandler(null);
     }

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    context = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    context = null
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
          authenticationHelper = AuthenticationHelper(IPApiService(context!!))
      }

      val listener= object :AuthenticationListener{
        override fun onSuccess(response: String) {
          if (authInProgress.compareAndSet(true, false)) {
            context?.runOnUiThread{
              result.success(response)
            }

          }
        }

        override fun onFail(errorResult: AuthenticationError) {

          if (authInProgress.compareAndSet(true, false)) {
             context?.runOnUiThread{
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



    } else if(call.method=="checkCoverage") {

      if (authInProgress.get()) {
        return
      }

      authInProgress.set(true)
      if(authenticationHelper == null){
        authenticationHelper = AuthenticationHelper(IPApiService(context!!))
      }
      authenticationHelper?.checkCoverage({
        if (authInProgress.compareAndSet(true, false)) {
          context?.runOnUiThread {
            result.success(it)
          }
        }
      },{
        if (authInProgress.compareAndSet(true, false)) {
          context?.runOnUiThread{
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
        authenticationHelper = AuthenticationHelper(IPApiService(context!!))
      }
      //20092021
      var phoneNumber = call.argument<String>("phone_number")
      if(phoneNumber.isNullOrEmpty()){
        context?.runOnUiThread{
          result.error("invalid_parameter", "phoneNumber cannot be empty", null)
        }
        authInProgress.set(false)
        return
      }

      authenticationHelper?.checkCoverage(phoneNumber, {
        if (authInProgress.compareAndSet(true, false)) {
          context?.runOnUiThread {
            result.success(it)
          }
        }
      },{
        if (authInProgress.compareAndSet(true, false)) {
          context?.runOnUiThread{
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
          authenticationHelper = AuthenticationHelper(IPApiService(context!!))
        }
        authenticationHelper?.setConfiguration(json_config)
      }

    }
    else if(call.method=="getConfiguration"){
      val configName = call.argument<String>("config_name")
      if (!configName.isNullOrEmpty()){
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(context!!))
        }
        context?.runOnUiThread {
          result.success(authenticationHelper?.getConfigurationByName(configName))
        }

      }

    }
    else if(call.method=="getClientId"){
      context?.let {
        result.success(IPConfigurationFile.getInstance().CLIENT_ID)
      }
    }
    else if(call.method=="getRedirectUri"){
      context?.let {
        result.success(IPConfigurationFile.getInstance().REDIRECT_URI.toString())
      }
    }
    else if(call.method=="setClientId"){
      val clientValue = call.argument<String>("value")
      if (!clientValue.isNullOrEmpty()){
        context?.let {
          IPConfigurationFile.getInstance().CLIENT_ID = clientValue
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="setRedirectUri"){
      val redirectValue = call.argument<String>("value")
      if (!redirectValue.isNullOrEmpty()){
        context?.let {
          IPConfigurationFile.getInstance().REDIRECT_URI = Uri.parse(redirectValue)
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="setCheckCoverageUrl"){
      val coverageValue = call.argument<String>("value")
      if (!coverageValue.isNullOrEmpty()){
        context?.let {
          IPConfigurationFile.getInstance().COVERAGE_URL = Uri.parse(coverageValue)
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="setAuthorizationUrl"){
      val authorizationValue = call.argument<String>("value")
      if (!authorizationValue.isNullOrEmpty()){
        context?.let {
          IPConfigurationFile.getInstance().AUTHORIZATION_URL = Uri.parse(authorizationValue)
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    
    else if(call.method=="unregisterNetwork"){
      context?.let {
        val result =  CellularService.Companion.unregisterNetwork(context!!)
        if(BuildConfig.DEBUG) {
          Log.d(TAG, "unregisterNetwork: $result")
        }
        // context = null
        // channel.setMethodCallHandler(null);
      }
    }
    else if(call.method=="addQueryParam"){
      context?.let {
        var key = call.argument<String>("key") ?: ""
        var value = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(context!!))
        }
        authenticationHelper?.addQueryParam(key, value)
      }
    }
    else if(call.method=="setState"){
      context?.let {
        var state = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(context!!))
        }
        authenticationHelper?.setState(state)
      }
    }
    else if(call.method=="setScope"){
      context?.let {
        var scope = call.argument<String>("value") ?: ""
        if(authenticationHelper==null){
          authenticationHelper = AuthenticationHelper(IPApiService(context!!))
        }
        authenticationHelper?.setScope(scope)
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

  }

}
