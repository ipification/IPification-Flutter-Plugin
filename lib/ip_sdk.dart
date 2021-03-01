import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class IpSdk {
  static const MethodChannel _channel = const MethodChannel('ip_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> doAuthentication({String loginHint}) async {
    if (loginHint == null) {
      loginHint = "";
    }
    final String result = await _channel
        .invokeMethod("doAuthentication", {"login_hint": loginHint});

    return result;
  }

  static Future<bool> get checkCoverage async {
    final bool result = await _channel.invokeMethod<bool>('checkCoverage');
    return result;
  }

  static void setAuthorizationServiceConfiguration(String fileName) {
    _channel
        .invokeMethod<bool>('setConfiguration', {"config_file_name": fileName});
  }

  static Future<String> getConfigurationByName(String configName) async {
    final String result = await _channel
        .invokeMethod<String>('getConfiguration', {"config_name": configName});
    return result;
  }

  static void unregisterNetwork() {
    _channel.invokeMethod("unregisterNetwork");
  }
}
