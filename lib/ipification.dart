// ignore_for_file: constant_identifier_names

import 'ipification_plugin_platform_interface.dart';
import 'package:ipification_plugin/coverage_response.dart';
import 'package:ipification_plugin/authentication_response.dart';
import 'package:ipification_plugin/multi_authentication_response.dart';
import 'package:ipification_plugin/sms_auth_response.dart';
import 'package:ipification_plugin/sms_token_response.dart';

enum ENV { SANDBOX, PRODUCTION }

enum AuthChannel { TS43, IP, SMS }

class IPConfiguration {
  const IPConfiguration({
    this.debug,
    this.dnsDebug,
    this.extraDebug,
    this.env,
    this.clientId,
    this.redirectUri,
    this.authChannels,
    this.stateLength,
    this.currentState,
    this.currentUrl,
    this.automaticStateGenerationEnabled,
    this.sendErrorReportsEnabled,
    this.errorReportEnableCarrierHeaders,
    this.enableCarrierHeaders,
    this.errorReportTimeout,
    this.enableSingleRequest,
    this.defaultScope,
    this.okhttpUserAgent,
    this.okhttpAccept,
    this.sdkTypeValue,
    this.autoUnregisterNetwork,
    this.onlyAffectedBrands,
    this.retryOnConnectionFailure,
    this.maxRetries,
    this.enabledHandleCookie,
    this.coverageAlwaysTrue,
    this.responseTypeCode,
    this.coveragePathForcedTrue,
    this.loginHint,
    this.coverageUrlStage,
    this.coverageUrlLive,
    this.authUrlStage,
    this.authUrlLive,
    this.sdkLogUrlStage,
    this.sdkLogUrlLive,
    this.coverageUrl,
    this.authorizationUrl,
    this.customUrls,
    this.enableParamsValidation,
    this.baseUrl,
    this.realm,
    this.coveragePath,
    this.authPath,
    this.sdkLogPath,
    this.coverageReadTimeout,
    this.coverageConnectTimeout,
    this.authReadTimeout,
    this.authConnectTimeout,
    this.localNetworkPermissionFirstPromptTimeout,
    this.localNetworkPermissionTimeout,
    this.localNetworkPermissionGraceTimeout,
    this.connectNetworkTimeout,
    this.connectNetworkTimeoutShort,
    this.consentIdValue,
    this.timeoutReleaseNetwork,
    this.defaultTimeoutReleaseNetwork,
    this.cellularPrivateIp,
    this.bindAppToCellularNetwork,
    this.useWebViewInsteadOfApi,
    this.ipTokenUrl,
    this.enableSaveSessionInPreference,
    this.whatsappPackageName,
    this.telegramPackageName,
    this.telegramWebPackageName,
    this.viberPackageName,
    this.imAutoMode,
    this.imPriorityAppList,
    this.validateIMApps,
    this.notificationId,
    this.requestCode,
    this.maxLogLength,
    this.ts43SandboxBackendUrl,
    this.ts43ProductionBackendUrl,
    this.ts43AuthPath,
    this.ts43TokenPath,
    this.ts43ScopeVerifyPhone,
    this.ts43ScopeGetPhone,
    this.ts43DefaultLoginHint,
    this.ts43DefaultCarrierHint,
    this.smsSandboxBackendUrl,
    this.smsProductionBackendUrl,
    this.smsAuthPath,
    this.smsTokenPath,
    this.smsScopeVerifyPhone,
    this.smsServerId,
  });

  final bool? debug;
  final bool? dnsDebug;
  final bool? extraDebug;
  final ENV? env;
  final String? clientId;
  final String? redirectUri;
  final List<AuthChannel>? authChannels;
  final int? stateLength;
  final String? currentState;
  final String? currentUrl;
  final bool? automaticStateGenerationEnabled;
  final bool? sendErrorReportsEnabled;
  final bool? errorReportEnableCarrierHeaders;
  final bool? enableCarrierHeaders;
  final int? errorReportTimeout;
  final bool? enableSingleRequest;
  final String? defaultScope;
  final String? okhttpUserAgent;
  final String? okhttpAccept;
  final String? sdkTypeValue;
  final bool? autoUnregisterNetwork;
  final bool? onlyAffectedBrands;
  final bool? retryOnConnectionFailure;
  final int? maxRetries;
  final bool? enabledHandleCookie;
  final bool? coverageAlwaysTrue;
  final String? responseTypeCode;
  final String? coveragePathForcedTrue;
  final String? loginHint;
  final String? coverageUrlStage;
  final String? coverageUrlLive;
  final String? authUrlStage;
  final String? authUrlLive;
  final String? sdkLogUrlStage;
  final String? sdkLogUrlLive;
  final String? coverageUrl;
  final String? authorizationUrl;
  final bool? customUrls;
  final bool? enableParamsValidation;
  final String? baseUrl;
  final String? realm;
  final String? coveragePath;
  final String? authPath;
  final String? sdkLogPath;
  final int? coverageReadTimeout;
  final int? coverageConnectTimeout;
  final int? authReadTimeout;
  final int? authConnectTimeout;
  final int? localNetworkPermissionFirstPromptTimeout;
  final int? localNetworkPermissionTimeout;
  final int? localNetworkPermissionGraceTimeout;
  final int? connectNetworkTimeout;
  final int? connectNetworkTimeoutShort;
  final String? consentIdValue;
  final int? timeoutReleaseNetwork;
  final int? defaultTimeoutReleaseNetwork;
  final String? cellularPrivateIp;
  final bool? bindAppToCellularNetwork;
  final bool? useWebViewInsteadOfApi;
  final String? ipTokenUrl;
  final bool? enableSaveSessionInPreference;
  final String? whatsappPackageName;
  final String? telegramPackageName;
  final String? telegramWebPackageName;
  final String? viberPackageName;
  final bool? imAutoMode;
  final List<String>? imPriorityAppList;
  final bool? validateIMApps;
  final int? notificationId;
  final int? requestCode;
  final int? maxLogLength;
  final String? ts43SandboxBackendUrl;
  final String? ts43ProductionBackendUrl;
  final String? ts43AuthPath;
  final String? ts43TokenPath;
  final String? ts43ScopeVerifyPhone;
  final String? ts43ScopeGetPhone;
  final String? ts43DefaultLoginHint;
  final String? ts43DefaultCarrierHint;
  final String? smsSandboxBackendUrl;
  final String? smsProductionBackendUrl;
  final String? smsAuthPath;
  final String? smsTokenPath;
  final String? smsScopeVerifyPhone;
  final String? smsServerId;

  Map<String, Object?> toMap() => {
    "debug": debug,
    "dns_debug": dnsDebug,
    "extra_debug": extraDebug,
    "env": env?.name.toLowerCase(),
    "client_id": clientId,
    "redirect_uri": redirectUri,
    "auth_channels": authChannels?.map((channel) => channel.name).toList(),
    "state_length": stateLength,
    "current_state": currentState,
    "current_url": currentUrl,
    "automatic_state_generation_enabled": automaticStateGenerationEnabled,
    "send_error_reports_enabled": sendErrorReportsEnabled,
    "error_report_enable_carrier_headers": errorReportEnableCarrierHeaders,
    "enable_carrier_headers": enableCarrierHeaders,
    "error_report_timeout": errorReportTimeout,
    "enable_single_request": enableSingleRequest,
    "default_scope": defaultScope,
    "okhttp_user_agent": okhttpUserAgent,
    "okhttp_accept": okhttpAccept,
    "sdk_type_value": sdkTypeValue,
    "auto_unregister_network": autoUnregisterNetwork,
    "only_affected_brands": onlyAffectedBrands,
    "retry_on_connection_failure": retryOnConnectionFailure,
    "max_retries": maxRetries,
    "enabled_handle_cookie": enabledHandleCookie,
    "coverage_always_true": coverageAlwaysTrue,
    "response_type_code": responseTypeCode,
    "coverage_path_forced_true": coveragePathForcedTrue,
    "login_hint": loginHint,
    "coverage_url_stage": coverageUrlStage,
    "coverage_url_live": coverageUrlLive,
    "auth_url_stage": authUrlStage,
    "auth_url_live": authUrlLive,
    "sdk_log_url_stage": sdkLogUrlStage,
    "sdk_log_url_live": sdkLogUrlLive,
    "coverage_url": coverageUrl,
    "authorization_url": authorizationUrl,
    "custom_urls": customUrls,
    "enable_params_validation": enableParamsValidation,
    "base_url": baseUrl,
    "realm": realm,
    "coverage_path": coveragePath,
    "auth_path": authPath,
    "sdk_log_path": sdkLogPath,
    "coverage_read_timeout": coverageReadTimeout,
    "coverage_connect_timeout": coverageConnectTimeout,
    "auth_read_timeout": authReadTimeout,
    "auth_connect_timeout": authConnectTimeout,
    "local_network_permission_first_prompt_timeout":
        localNetworkPermissionFirstPromptTimeout,
    "local_network_permission_timeout": localNetworkPermissionTimeout,
    "local_network_permission_grace_timeout":
        localNetworkPermissionGraceTimeout,
    "connect_network_timeout": connectNetworkTimeout,
    "connect_network_timeout_short": connectNetworkTimeoutShort,
    "consent_id_value": consentIdValue,
    "timeout_release_network": timeoutReleaseNetwork,
    "default_timeout_release_network": defaultTimeoutReleaseNetwork,
    "cellular_private_ip": cellularPrivateIp,
    "bind_app_to_cellular_network": bindAppToCellularNetwork,
    "use_web_view_instead_of_api": useWebViewInsteadOfApi,
    "ip_token_url": ipTokenUrl,
    "enable_save_session_in_preference": enableSaveSessionInPreference,
    "whatsapp_package_name": whatsappPackageName,
    "telegram_package_name": telegramPackageName,
    "telegram_web_package_name": telegramWebPackageName,
    "viber_package_name": viberPackageName,
    "im_auto_mode": imAutoMode,
    "im_priority_app_list": imPriorityAppList,
    "validate_im_apps": validateIMApps,
    "notification_id": notificationId,
    "request_code": requestCode,
    "max_log_length": maxLogLength,
    "ts43_sandbox_backend_url": ts43SandboxBackendUrl,
    "ts43_production_backend_url": ts43ProductionBackendUrl,
    "ts43_auth_path": ts43AuthPath,
    "ts43_token_path": ts43TokenPath,
    "ts43_scope_verify_phone": ts43ScopeVerifyPhone,
    "ts43_scope_get_phone": ts43ScopeGetPhone,
    "ts43_default_login_hint": ts43DefaultLoginHint,
    "ts43_default_carrier_hint": ts43DefaultCarrierHint,
    "sms_sandbox_backend_url": smsSandboxBackendUrl,
    "sms_production_backend_url": smsProductionBackendUrl,
    "sms_auth_path": smsAuthPath,
    "sms_token_path": smsTokenPath,
    "sms_scope_verify_phone": smsScopeVerifyPhone,
    "sms_server_id": smsServerId,
  }..removeWhere((_, value) => value == null);
}

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

  Future<void> setIPConfiguration(IPConfiguration configuration) {
    return IPificationPluginPlatform.instance.setIPConfiguration(configuration);
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
