
class AuthenticationResponse {
  final String? code;
  final String? state;
  final String? responseString;

  AuthenticationResponse(this.code, this.state, this.responseString);

  factory AuthenticationResponse.fromUri(String? str) {
    if (str == null || str.isEmpty) {
      return AuthenticationResponse(null, null, str);
    }

    try {
      final uri = Uri.parse(str);
      return AuthenticationResponse(
        uri.queryParameters["code"],
        uri.queryParameters["state"],
        str,
      );
    } catch (e) {
      return AuthenticationResponse(null, null, str);
    }
  }

  @override
  String toString() {
    return 'AuthenticationResponse(code: $code, state: $state, responseString: $responseString)';
  }
}