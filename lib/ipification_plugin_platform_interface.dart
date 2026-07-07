import 'package:ipification_plugin/authentication_response.dart';
import 'package:ipification_plugin/coverage_response.dart';
import 'package:ipification_plugin/multi_authentication_response.dart';
import 'package:ipification_plugin/sms_auth_response.dart';
import 'package:ipification_plugin/sms_token_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ipification_plugin_method_channel.dart';
import 'ipification.dart';

abstract class IPificationPluginPlatform extends PlatformInterface {
  /// Constructs a IPificationPluginPlatform.
  IPificationPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static IPificationPluginPlatform _instance = MethodChannelIPificationPlugin();

  /// The default instance of [IPificationPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelIPificationPlugin].
  static IPificationPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IPificationPluginPlatform] when
  /// they register themselves.
  static set instance(IPificationPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<void> setAuthorizationServiceConfiguration(String fileName);

  Future<void> setEnv(ENV env);

  Future<void> setClientId(String clientId);

  Future<void> setRedirectUri(String redirectUri);

  Future<void> setAuthorizationUrl(String authUrl);
  Future<void> setBaseUrl(String baseUrl);
  Future<void> setCheckCoverageUrl(String checkCoverageUrl);

  Future<String?> getClientId();

  Future<String?> getRedirectUri();

  Future<String> generateState();

  Future<void> addQueryParam(String key, String value);

  Future<void> setState(String value);

  Future<void> setScope(String value);

  Future<void> setAuthChannels(List<AuthChannel> channels);

  Future<void> setIPConfiguration(IPConfiguration configuration);

  Future<void> setSMSConfiguration({
    String? sandboxBackendUrl,
    String? productionBackendUrl,
    String? authPath,
    String? tokenPath,
    String? scope,
    String? serverId,
  });

  Future<void> setTS43Configuration({
    String? sandboxBackendUrl,
    String? productionBackendUrl,
    String? authPath,
    String? tokenPath,
    String? scopeVerifyPhone,
    String? scopeGetPhone,
    String? defaultLoginHint,
    String? defaultCarrierHint,
  });

  Future<void> unregisterNetwork();

  Future<void> enableLog();

  Future<String> getLog();

  Future<void> showNotification(
    String title,
    String message,
    String notificationFolder,
    String notificationIcon,
  );

  Future<void> updateIOSLocale(
    String titleBar,
    String mainTitle,
    String description,
    String whatsappBtnText,
    String telegramBtnText,
    String viberBtnText,
    String cancelBtnText,
  );

  Future<void> updateIOSTheme(
    String toolbarTitleColor,
    String titleColor,
    String descColor,
    String cancelBtnColor,
    String backgroundColor,
  );

  Future<void> updateAndroidLocale(
    String toolbarTitle,
    String mainTitle,
    String description,
    String whatsappBtnText,
    String telegramBtnText,
    String viberBtnText,
  );

  Future<void> updateAndroidTheme(
    String backgroundColor,
    String toolbarTextColor,
    String toolbarColor,
  );

  Future<CheckCoverageResponse> checkCoverage();

  Future<CheckCoverageResponse> checkCoverageWithPhoneNumber(
    String phoneNumber,
  );

  Future<AuthenticationResponse> doAuthentication(String loginHint);

  Future<AuthenticationResponse> doAuthenticationWithChannel(
    String channel,
    String loginHint,
  );

  Future<AuthenticationResponse> doIMAuthentication(String channel);

  Future<MultiAuthenticationResponse> doAuthenticationWithChannels(
    String loginHint,
  );

  Future<SmsAuthResponse> startSMSAuthentication(
    String phoneNumber,
    String? scope,
  );

  Future<SmsTokenResponse> verifySMSOTP(
    String otpCode,
    String authReqId,
    String nonce,
  );
}
