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
  factory AuthenticationResponse.fromJson(dynamic str) {
    if (str == null || str == "") {
      return AuthenticationResponse(null, null, str);
    }
    var json = jsonDecode(str);
    
    return AuthenticationResponse(
          json['code'] as String, json['state'] as String, json['response_data'] as String);
  }
}
