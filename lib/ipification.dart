// ignore_for_file: constant_identifier_names

import 'ipification_plugin_platform_interface.dart';
import 'package:ipification_plugin/coverage_response.dart';
import 'package:ipification_plugin/authentication_response.dart';
import 'package:ipification_plugin/multi_authentication_response.dart';
import 'package:ipification_plugin/sms_auth_response.dart';
import 'package:ipification_plugin/sms_token_response.dart';

enum ENV { SANDBOX, PRODUCTION }

enum AuthChannel { TS43, IP, SMS }

class IPificationPlugin {
  Future<String?> getPlatformVersion() {
    return IPificationPluginPlatform.instance.getPlatformVersion();
  }

  Future<void> setAuthorizationServiceConfiguration(String fileName) {
    return IPificationPluginPlatform.instance
        .setAuthorizationServiceConfiguration(fileName);
  }

  Future<void> setEnv(ENV env) {
    return IPificationPluginPlatform.instance.setEnv(env);
  }

  Future<void> setClientId(String clientId) {
    return IPificationPluginPlatform.instance.setClientId(clientId);
  }

  Future<void> setScope({required String value}) {
    return IPificationPluginPlatform.instance.setScope(value);
  }

  Future<void> setAuthChannels({required List<AuthChannel> channels}) {
    return IPificationPluginPlatform.instance.setAuthChannels(channels);
  }

  Future<void> setSMSConfiguration({
    String? sandboxBackendUrl,
    String? productionBackendUrl,
    String? authPath,
    String? tokenPath,
    String? scope,
    String? serverId,
  }) {
    return IPificationPluginPlatform.instance.setSMSConfiguration(
      sandboxBackendUrl: sandboxBackendUrl,
      productionBackendUrl: productionBackendUrl,
      authPath: authPath,
      tokenPath: tokenPath,
      scope: scope,
      serverId: serverId,
    );
  }

  Future<void> setTS43Configuration({
    String? sandboxBackendUrl,
    String? productionBackendUrl,
    String? authPath,
    String? tokenPath,
    String? scopeVerifyPhone,
    String? scopeGetPhone,
    String? defaultLoginHint,
    String? defaultCarrierHint,
  }) {
    return IPificationPluginPlatform.instance.setTS43Configuration(
      sandboxBackendUrl: sandboxBackendUrl,
      productionBackendUrl: productionBackendUrl,
      authPath: authPath,
      tokenPath: tokenPath,
      scopeVerifyPhone: scopeVerifyPhone,
      scopeGetPhone: scopeGetPhone,
      defaultLoginHint: defaultLoginHint,
      defaultCarrierHint: defaultCarrierHint,
    );
  }

  Future<void> setState({required String value}) {
    return IPificationPluginPlatform.instance.setState(value);
  }

  Future<void> setRedirectUri(String redirectUri) {
    return IPificationPluginPlatform.instance.setRedirectUri(redirectUri);
  }

  Future<void> setAuthorizationUrl(String authUrl) {
    return IPificationPluginPlatform.instance.setAuthorizationUrl(authUrl);
  }

  Future<void> setBaseUrl(String baseUrl) {
    return IPificationPluginPlatform.instance.setBaseUrl(baseUrl);
  }

  Future<String?> getClientId() {
    return IPificationPluginPlatform.instance.getClientId();
  }

  Future<String?> getRedirectUri() {
    return IPificationPluginPlatform.instance.getRedirectUri();
  }

  Future<String> generateState() {
    return IPificationPluginPlatform.instance.generateState();
  }

  Future<void> unregisterNetwork() {
    return IPificationPluginPlatform.instance.unregisterNetwork();
  }

  Future<void> addQueryParam({required String key, required String value}) {
    return IPificationPluginPlatform.instance.addQueryParam(key, value);
  }

  Future<void> setCheckCoverageUrl(String checkCoverageUrl) {
    return IPificationPluginPlatform.instance.setCheckCoverageUrl(
      checkCoverageUrl,
    );
  }

  Future<CheckCoverageResponse> checkCoverage() {
    return IPificationPluginPlatform.instance.checkCoverage();
  }

  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(
    String phoneNumber,
  ) {
    return IPificationPluginPlatform.instance.checkCoverageWithPhoneNumber(
      phoneNumber,
    );
  }

  Future<AuthenticationResponse> doAuthentication({required String loginHint}) {
    return IPificationPluginPlatform.instance.doAuthentication(loginHint);
  }

  Future<AuthenticationResponse> doAuthenticationWithChannel({
    required String channel,
    required String loginHint,
  }) {
    return IPificationPluginPlatform.instance.doAuthenticationWithChannel(
      channel,
      loginHint,
    );
  }

  Future<AuthenticationResponse> doIMAuthentication({required String channel}) {
    return IPificationPluginPlatform.instance.doIMAuthentication(channel);
  }

  Future<MultiAuthenticationResponse> doAuthenticationWithChannels({
    required String loginHint,
  }) {
    return IPificationPluginPlatform.instance.doAuthenticationWithChannels(
      loginHint,
    );
  }

  Future<SmsAuthResponse> startSMSAuthentication({
    required String phoneNumber,
    String? scope,
  }) {
    return IPificationPluginPlatform.instance.startSMSAuthentication(
      phoneNumber,
      scope,
    );
  }

  Future<SmsTokenResponse> verifySMSOTP({
    required String otpCode,
    required String authReqId,
    required String nonce,
  }) {
    return IPificationPluginPlatform.instance.verifySMSOTP(
      otpCode,
      authReqId,
      nonce,
    );
  }

  Future<void> enableLog() {
    return IPificationPluginPlatform.instance.enableLog();
  }

  Future<String?> getLog() {
    return IPificationPluginPlatform.instance.getLog();
  }

  Future<void> showNotification(
    String title,
    String message,
    String notificationFolder,
    String notificationIcon,
  ) {
    return IPificationPluginPlatform.instance.showNotification(
      title,
      message,
      notificationFolder,
      notificationIcon,
    );
  }

  Future<void> updateIOSLocale(
    String titleBar,
    String mainTitle,
    String description,
    String whatsappBtnText,
    String telegramBtnText,
    String viberBtnText,
    String cancelBtnText,
  ) {
    return IPificationPluginPlatform.instance.updateIOSLocale(
      titleBar,
      mainTitle,
      description,
      whatsappBtnText,
      telegramBtnText,
      viberBtnText,
      cancelBtnText,
    );
  }

  Future<void> updateIOSTheme(
    String toolbarTitleColor,
    String titleColor,
    String descColor,
    String cancelBtnColor,
    String backgroundColor,
  ) {
    return IPificationPluginPlatform.instance.updateIOSTheme(
      toolbarTitleColor,
      titleColor,
      descColor,
      cancelBtnColor,
      backgroundColor,
    );
  }

  Future<void> updateAndroidLocale(
    String toolbarTitle,
    String mainTitle,
    String description,
    String whatsappBtnText,
    String telegramBtnText,
    String viberBtnText,
  ) {
    return IPificationPluginPlatform.instance.updateAndroidLocale(
      toolbarTitle,
      mainTitle,
      description,
      whatsappBtnText,
      telegramBtnText,
      viberBtnText,
    );
  }

  Future<void> updateAndroidTheme(
    String backgroundColor,
    String toolbarTextColor,
    String toolbarColor,
  ) {
    return IPificationPluginPlatform.instance.updateAndroidTheme(
      backgroundColor,
      toolbarTextColor,
      toolbarColor,
    );
  }
}
