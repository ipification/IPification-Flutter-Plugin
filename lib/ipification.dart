import 'ipification_plugin_platform_interface.dart';
import 'package:ipification_plugin/coverage_response.dart';
import 'package:ipification_plugin/authentication_response.dart';


enum ENV { SANDBOX, PRODUCTION }

class IPificationPlugin {
  Future<String?> getPlatformVersion() {
    return IPificationPluginPlatform.instance.getPlatformVersion();
  }

  Future<void> setAuthorizationServiceConfiguration(String fileName) {
    return IPificationPluginPlatform.instance.setAuthorizationServiceConfiguration(fileName);
  }

  Future<String?> getConfigurationByName(String configName) {
    return IPificationPluginPlatform.instance.getConfigurationByName(configName);
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

  Future<void> setState({required String value}) {
    return IPificationPluginPlatform.instance.setState(value);
  }

  Future<void> setRedirectUri(String redirectUri) {
    return IPificationPluginPlatform.instance.setRedirectUri(redirectUri);
  }

  Future<void> setAuthorizationUrl(String authUrl) {
    return IPificationPluginPlatform.instance.setAuthorizationUrl(authUrl);
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
    return IPificationPluginPlatform.instance.setCheckCoverageUrl(checkCoverageUrl);
  }

  Future<CheckCoverageResponse> checkCoverage() {
    return IPificationPluginPlatform.instance.checkCoverage();
  }

  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(String phoneNumber) {
    return IPificationPluginPlatform.instance.checkCoverageWithPhoneNumber(phoneNumber);
  }

  Future<AuthenticationResponse> doAuthentication({required String loginHint}) {
    return IPificationPluginPlatform.instance.doAuthentication(loginHint);
  }

  Future<AuthenticationResponse> doAuthenticationWithChannel({required String channel, required String loginHint}) {
    return IPificationPluginPlatform.instance.doAuthenticationWithChannel(channel, loginHint);
  }

  Future<AuthenticationResponse> doIMAuthentication({required String channel}) {
    return IPificationPluginPlatform.instance.doIMAuthentication(channel);
  }

  Future<void> enableLog() {
    return IPificationPluginPlatform.instance.enableLog();
  }

  Future<String?> getLog() {
    return IPificationPluginPlatform.instance.getLog();
  }

  Future<void> showNotification(
      String title, String message, String notificationFolder, String notificationIcon) {
    return IPificationPluginPlatform.instance.showNotification(
        title, message, notificationFolder, notificationIcon);
  }

  Future<void> updateIOSLocale(String titleBar, String mainTitle, String description,
      String whatsappBtnText, String telegramBtnText, String viberBtnText, String cancelBtnText) {
    return IPificationPluginPlatform.instance.updateIOSLocale(
        titleBar, mainTitle, description, whatsappBtnText, telegramBtnText, viberBtnText, cancelBtnText);
  }

  Future<void> updateIOSTheme(String toolbarTitleColor, String titleColor, String descColor,
      String cancelBtnColor, String backgroundColor) {
    return IPificationPluginPlatform.instance.updateIOSTheme(
        toolbarTitleColor, titleColor, descColor, cancelBtnColor, backgroundColor);
  }

  Future<void> updateAndroidLocale(String toolbarTitle, String mainTitle, String description,
      String whatsappBtnText, String telegramBtnText, String viberBtnText) {
    return IPificationPluginPlatform.instance.updateAndroidLocale(
        toolbarTitle, mainTitle, description, whatsappBtnText, telegramBtnText, viberBtnText);
  }

  Future<void> updateAndroidTheme(String backgroundColor, String toolbarTextColor, String toolbarColor) {
    return IPificationPluginPlatform.instance.updateAndroidTheme(
        backgroundColor, toolbarTextColor, toolbarColor);
  }
}