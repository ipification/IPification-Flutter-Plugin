import 'dart:convert';

class AuthenticationResponse {
  var code;
  var state;
  var responseString;
  AuthenticationResponse(String code, String state, String responseString) {
    this.code = code;
    this.state = state;
    this.responseString = responseString;
  }
  factory AuthenticationResponse.fromUri(dynamic str) {
    if (str == null || str == "") {
      return AuthenticationResponse(null, null, str);
    }
    var uri = Uri.parse(str);
    var code = "";
    var state = "";
    var responseString = str;
    uri.queryParameters.forEach((k, v) {
      if (k == "code") {
        code = v;
      }
      if (k == "state") {
        state = v;
      }
    });
    return AuthenticationResponse(code, state, responseString);
  }
}
