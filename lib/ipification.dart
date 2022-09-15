import 'dart:async';
import 'dart:io';
import 'package:ipification_plugin/authentication_response.dart';
import 'package:ipification_plugin/coverage_response.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';

enum ENV { 
   SANDBOX, 
   PRODUCTION
}  
class IPificationPlugin {
  static const MethodChannel _channel =
      const MethodChannel('ipification_plugin');

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }
  @Deprecated('Use [setAuthorizationUrl()]')
  static void setAuthorizationServiceConfiguration(String fileName) {
    _channel
        .invokeMethod<bool>('setConfiguration', {"config_file_name": fileName});
  }

  @Deprecated('Deprecated')
  static Future<String?> getConfigurationByName(String configName) async {
    final String? result = await _channel
        .invokeMethod<String>('getConfiguration', {"config_name": configName});
    return result;
  }

  static Future<CheckCoverageResponse> checkCoverage() async {
    final String? resultJson =
        await _channel.invokeMethod<String>('checkCoverage');
    var result = CheckCoverageResponse.fromJson(resultJson);
    return result;
  }

  static Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(
      {required String phoneNumber}) async {
    final String? resultJson = await _channel.invokeMethod<String>(
        'checkCoverageWithPhoneNumber', {"phone_number": phoneNumber});
    var result = CheckCoverageResponse.fromJson(resultJson);
    return result;
  }

  static void addQueryParam({required String key, required String value}) {
    _channel.invokeMethod("addQueryParam", {"key": key, "value": value});
  }

  static void setState({required String value}) {
    _channel.invokeMethod("setState", {"value": value});
  }

  static void setScope({required String value}) {
    _channel.invokeMethod("setScope", {"value": value});
  }

  static Future<AuthenticationResponse> doAuthentication(
      {required String loginHint}) async {
    final String? resultJson = await _channel
        .invokeMethod("doAuthentication", {"login_hint": loginHint});
    var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }

  static Future<AuthenticationResponse> doAuthenticationWithChannel(
      {required String channel, required String loginHint}) async {
    final String? resultJson = await _channel.invokeMethod(
        "doAuthenticationWithChannel",
        {"channel": channel, "login_hint": loginHint});
    var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }

  static Future<AuthenticationResponse> doIMAuthentication(
      {required String channel}) async {
    final String? resultJson = await _channel
        .invokeMethod("doAuthenticationWithChannel", {"channel": channel});
    var result = AuthenticationResponse.fromUri(resultJson);
    return result;
  }

  static void unregisterNetwork() {
    _channel.invokeMethod("unregisterNetwork");
  }

  static void setClientId(String clientId) async {
    _channel.invokeMethod<String>('setClientId', {"value": clientId});
  }

  static void setEnv(ENV env) async {
    if (env == ENV.SANDBOX) {
      _channel.invokeMethod<String>('setEnv', {"value": 'sandbox'});
    }else{
      _channel.invokeMethod<String>('setEnv', {"value": 'production'});
    }    
  }

  static void setRedirectUri(String redirectUri) async {
    _channel.invokeMethod<String>('setRedirectUri', {"value": redirectUri});
  }
  
  static void setCheckCoverageUrl(String checkCoverageUrl) async {
    _channel.invokeMethod<String>(
        'setCheckCoverageUrl', {"value": checkCoverageUrl});
  }

  static void setAuthorizationUrl(String authUrl) async {
    _channel.invokeMethod<String>('setAuthorizationUrl', {"value": authUrl});
  }

  static Future<String?> getClientId() async {
    final String? result = await _channel.invokeMethod<String>('getClientId');
    return result;
  }

  static Future<String?> getRedirectUri() async {
    final String? result =
        await _channel.invokeMethod<String>('getRedirectUri');
    return result;
  }

  static Future<String> generateState() async {
    final String? result = await _channel.invokeMethod<String>('generateState');
    return result ?? getRandString(100);
  }

  static Future<void> enableLog() async {
    await _channel.invokeMethod<String>('enableLog');
  }

  static Future<String> getLog() async {
    final String? result = await _channel.invokeMethod<String>('getLog');
    return result ?? "";
  }

  static String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  static void showNotification(String title, String message,
      String notificationFolder, String notificationIcon) async {
    _channel.invokeMethod<String>('showNotification', {
      "title": title,
      "message": message,
      "notificationFolder": notificationFolder,
      "notificationIcon": notificationIcon
    });
  }

  static void updateIOSLocale(
      String titleBar,
      String mainTitle,
      String description,
      String whatsappBtnText,
      String telegramBtnText,
      String viberBtnText,
      String cancelBtnText) {
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

  static void updateIOSTheme(String toolbarTitleColor, String titleColor,
      String descColor, String cancelBtnColor, String backgroundColor) {
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

  static void updateAndroidLocale(String toolbarTitle, String mainTitle, String description,
      String whatsappBtnText, String telegramBtnText, String viberBtnText) {
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

  static void updateAndroidTheme(
      String backgroundColor, String toolbarTextColor, String toolbarColor) {
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
}
