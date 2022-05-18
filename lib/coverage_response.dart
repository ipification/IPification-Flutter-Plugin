import 'dart:convert';

class CheckCoverageResponse {
  var isAvailable;
  var operatorCode;
  CheckCoverageResponse(bool isAvailable, String? operatorCode) {
    this.isAvailable = isAvailable;
    this.operatorCode = operatorCode;
  }
  factory CheckCoverageResponse.fromJson(dynamic str) {
    if (str == null || str == "") {
      return CheckCoverageResponse(false, null);
    }
    try {
      var json = jsonDecode(str);
      return CheckCoverageResponse(
          json['available'] as bool, json['operator_code'] as String?);
    } catch (e) {
      return CheckCoverageResponse(false, null);
    }
  }
}
