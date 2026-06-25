import 'dart:convert';

import 'authentication_response.dart';
import 'sms_auth_response.dart';

enum MultiAuthenticationResultType { authentication, otpRequired, unknown }

class MultiAuthenticationResponse {
  final MultiAuthenticationResultType type;
  final AuthenticationResponse? authenticationResponse;
  final SmsAuthResponse? smsAuthResponse;
  final String? responseString;

  MultiAuthenticationResponse({
    required this.type,
    this.authenticationResponse,
    this.smsAuthResponse,
    this.responseString,
  });

  factory MultiAuthenticationResponse.fromJson(String? str) {
    if (str == null || str.isEmpty) {
      return MultiAuthenticationResponse(
        type: MultiAuthenticationResultType.unknown,
        responseString: str,
      );
    }

    final json = jsonDecode(str) as Map<String, dynamic>;
    final type = json["type"] as String?;
    if (type == "authentication") {
      final response = json["authentication_response"] as String?;
      return MultiAuthenticationResponse(
        type: MultiAuthenticationResultType.authentication,
        authenticationResponse: AuthenticationResponse.fromUri(response),
        responseString: str,
      );
    }
    if (type == "otp_required") {
      final smsResponse = json["sms_auth_response"] as Map<String, dynamic>?;
      return MultiAuthenticationResponse(
        type: MultiAuthenticationResultType.otpRequired,
        smsAuthResponse: SmsAuthResponse.fromJson(
          jsonEncode(smsResponse ?? {}),
        ),
        responseString: str,
      );
    }

    return MultiAuthenticationResponse(
      type: MultiAuthenticationResultType.unknown,
      responseString: str,
    );
  }
}
