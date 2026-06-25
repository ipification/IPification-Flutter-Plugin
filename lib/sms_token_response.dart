import 'dart:convert';

class SmsTokenResponse {
  final String? sub;
  final String? phoneNumber;
  final bool phoneNumberVerified;
  final String? loginHint;
  final String? rawResponse;

  SmsTokenResponse({
    this.sub,
    this.phoneNumber,
    required this.phoneNumberVerified,
    this.loginHint,
    this.rawResponse,
  });

  factory SmsTokenResponse.fromJson(String? str) {
    final json = str == null || str.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(str) as Map<String, dynamic>;
    return SmsTokenResponse(
      sub: json["sub"] as String?,
      phoneNumber: json["phone_number"] as String?,
      phoneNumberVerified: json["phone_number_verified"] == true,
      loginHint: json["login_hint"] as String?,
      rawResponse: json["raw_response"] as String?,
    );
  }
}
