import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ip_sdk/authentication_response.dart';
import 'package:ip_sdk/coverage_response.dart';

class IpSdk {
  static const MethodChannel _channel = const MethodChannel('ip_sdk');

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  static void setAuthorizationServiceConfiguration(String fileName) {
    _channel
        .invokeMethod<bool>('setConfiguration', {"config_file_name": fileName});
  }

  static Future<String> getConfigurationByName(String configName) async {
    final String result = await _channel
        .invokeMethod<String>('getConfiguration', {"config_name": configName});
    return result;
  }
  

  static Future<CheckCoverageResponse> checkCoverage() async {
    final String resultJson =
        await _channel.invokeMethod<String>('checkCoverage');    
    var result = CheckCoverageResponse.fromJson(resultJson);
    return result;
  }
  
  static Future<CheckCoverageResponse> checkCoverageWithPhoneNumber({String phoneNumber}) async {
    final String resultJson =
        await _channel.invokeMethod<String>('checkCoverageWithPhoneNumber', {"phone_number": phoneNumber});    
    var result = CheckCoverageResponse.fromJson(resultJson);
    return result;
  }

  static void addQueryParam({String key, String value}) {
    if (key == null) {
      key = "";
    }
    if (value == null) {
      value = "";
    }
    _channel.invokeMethod("addQueryParam", {"key": key, "value": value});
  }

  static void setState({String value}) {
    if (value == null) {
      value = "";
    }
    _channel.invokeMethod("setState", {"value": value});
  }

  static void setScope({String value}) {
    if (value == null) {
      value = "";
    }
    _channel.invokeMethod("setScope", {"value": value});
  }
  static Future<AuthenticationResponse> doAuthentication({String loginHint}) async {
    if (loginHint == null) {
      loginHint = "";
    }
    final String resultJson = await _channel
        .invokeMethod("doAuthentication", {"login_hint": loginHint});
   var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }



  static void unregisterNetwork() {
    _channel.invokeMethod("unregisterNetwork");
  }
}
