import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'ipification.dart'; 
import 'package:flutter/services.dart';
import 'package:ipification_plugin/authentication_response.dart';
import 'package:ipification_plugin/coverage_response.dart';

import 'ipification_plugin_platform_interface.dart';

/// An implementation of [IPificationPluginPlatform] that uses method channels.
class MethodChannelIPificationPlugin extends IPificationPluginPlatform {
  static const MethodChannel _channel = MethodChannel('ipification_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> setAuthorizationServiceConfiguration(String fileName) async {
    await _channel.invokeMethod('setConfiguration', {"config_file_name": fileName});
  }

  @override
  Future<String?> getConfigurationByName(String configName) async {
    final String? result = await _channel.invokeMethod<String>('getConfiguration', {"config_name": configName});
    return result;
  }

  @override
  Future<void> setEnv(ENV env) async {
    if (env == ENV.SANDBOX) {
      await _channel.invokeMethod<String>('setEnv', {"value": 'sandbox'});
    }else{
      await _channel.invokeMethod<String>('setEnv', {"value": 'production'});
    }   
  }
  @override
  Future<void> setClientId(String clientId) async {
    await _channel.invokeMethod('setClientId', {"value": clientId});
  }
  @override
  Future<void> setRedirectUri(String redirectUri) async {
    await _channel.invokeMethod('setRedirectUri', {"value": redirectUri});
  }

  @override
  Future<void> setAuthorizationUrl(String authUrl) async {
    await _channel.invokeMethod('setAuthorizationUrl', {"value": authUrl});
  }

  @override
  Future<void> setCheckCoverageUrl(String checkCoverageUrl) async {
    await _channel.invokeMethod('setCheckCoverageUrl', {"value": checkCoverageUrl});
  }

  @override
  Future<String?> getClientId() async {
    return await _channel.invokeMethod<String>('getClientId');
  }

  @override
  Future<String?> getRedirectUri() async {
    return await _channel.invokeMethod<String>('getRedirectUri');
  }

  @override
  Future<String> generateState() async {
    final String? result = await _channel.invokeMethod<String>('generateState');
    return result ?? _generateRandomString(100);
  }

  String _generateRandomString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
  
  @override
  Future<void> addQueryParam(String key, String value) async {
     _channel.invokeMethod("addQueryParam", {"key": key, "value": value});
  }
  
  @override
  Future<CheckCoverageResponse> checkCoverage() async {
    final String? resultJson = await _channel.invokeMethod<String>('checkCoverage');
    var result = CheckCoverageResponse.fromJson(resultJson);
    return result;
  }
  
  @override
  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(String phoneNumber) async {
    final String? resultJson = await _channel.invokeMethod<String>(
        'checkCoverageWithPhoneNumber', {"phone_number": phoneNumber});
    var result = CheckCoverageResponse.fromJson(resultJson);
    return result;
  }
  
  @override
  Future<AuthenticationResponse> doAuthentication(String loginHint) async {
    final String? resultJson = await _channel
        .invokeMethod("doAuthentication", {"login_hint": loginHint});
    var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }
  
  @override
  Future<AuthenticationResponse> doAuthenticationWithChannel(String channel, String loginHint) async {
    final String? resultJson = await _channel.invokeMethod(
        "doAuthenticationWithChannel",
        {"channel": channel, "login_hint": loginHint});
    var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }
  
  @override
  Future<AuthenticationResponse> doIMAuthentication(String channel) async {
    final String? resultJson = await _channel
        .invokeMethod("doAuthenticationWithChannel", {"channel": channel});
    var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }
  
  @override
  Future<void> enableLog() async {
    await _channel.invokeMethod<String>('enableLog');
  }
  
  @override
  Future<String> getLog() async {
    final String? result = await _channel.invokeMethod<String>('getLog');
    return result ?? "";
  }
  
  @override
  Future<void> setScope(String value) async{
    _channel.invokeMethod("setScope", {"value": value});
  }
  
  @override
  Future<void> setState(String value) async {
    _channel.invokeMethod("setState", {"value": value});
  }
  
  @override
  Future<void> showNotification(String title, String message, String notificationFolder, String notificationIcon) async{
    _channel.invokeMethod<String>('showNotification', {
      "title": title,
      "message": message,
      "notificationFolder": notificationFolder,
      "notificationIcon": notificationIcon
    });
  }
  
  @override
  Future<void> unregisterNetwork() async {
    _channel.invokeMethod("unregisterNetwork");
  }
  
  @override
  Future<void> updateAndroidLocale(String toolbarTitle, String mainTitle, String description, String whatsappBtnText, String telegramBtnText, String viberBtnText) async {
    if (Platform.isAndroid) {
      {
        _channel.invokeMethod<String>('updateLocale', {
          "toolbarTitle": toolbarTitle,
          "mainTitle": mainTitle,
          "description": description,
          "whatsappBtnText": whatsappBtnText,
          "telegramBtnText": telegramBtnText,
          "viberBtnText": viberBtnText
        });
      }
    }
  }
  
  @override
  Future<void> updateAndroidTheme(String backgroundColor, String toolbarTextColor, String toolbarColor) async {
    if (Platform.isAndroid) {
      {
        _channel.invokeMethod<String>('updateTheme', {
          "backgroundColor": backgroundColor,
          "toolbarTextColor": toolbarTextColor,
          "toolbarColor": toolbarColor
        });
      }
    }
  }
  
  @override
  Future<void> updateIOSLocale(String titleBar, String mainTitle, String description, String whatsappBtnText, String telegramBtnText, String viberBtnText, String cancelBtnText) async {
    if (Platform.isIOS) {
      {
        _channel.invokeMethod<String>('updateLocale', {
          "titleBar": titleBar,
          "mainTitle": mainTitle,
          "description": description,
          "whatsappBtnText": whatsappBtnText,
          "telegramBtnText": telegramBtnText,
          "viberBtnText": viberBtnText,
          "cancelBtnText": cancelBtnText,
        });
      }
    }
  }
  
  @override
  Future<void> updateIOSTheme(String toolbarTitleColor, String titleColor, String descColor, String cancelBtnColor, String backgroundColor) async {
   if (Platform.isIOS) {
      {
        _channel.invokeMethod<String>('updateTheme', {
          "toolbarTitleColor": toolbarTitleColor,
          "cancelBtnColor": cancelBtnColor,
          "titleColor": titleColor,
          "descColor": descColor,
          "backgroundColor": backgroundColor
        });
      }
    }
  }
}