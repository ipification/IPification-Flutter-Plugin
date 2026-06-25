import 'dart:convert';

class SmsAuthResponse {
  final String authReqId;
  final String nonce;
  final String? authServerId;
  final String? authServerUrl;
  final String? rawResponse;

  SmsAuthResponse({
    required this.authReqId,
    required this.nonce,
    this.authServerId,
    this.authServerUrl,
    this.rawResponse,
  });

  factory SmsAuthResponse.fromJson(String? str) {
    final json = str == null || str.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(str) as Map<String, dynamic>;
    final authServer = json["auth_server"] as Map<String, dynamic>?;
    return SmsAuthResponse(
      authReqId: json["auth_req_id"] as String? ?? "",
      nonce: json["nonce"] as String? ?? "",
      authServerId: authServer?["id"] as String?,
      authServerUrl: authServer?["url"] as String?,
      rawResponse: json["raw_response"] as String?,
    );
  }
}
