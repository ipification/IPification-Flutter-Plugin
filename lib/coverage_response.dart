import 'dart:convert';

class CheckCoverageResponse {
  var isAvaiable;
  var operatorCode;
  CheckCoverageResponse(bool isAvaiable, String operatorCode) {
    this.isAvaiable = isAvaiable;
    this.operatorCode = operatorCode;
  }
  factory CheckCoverageResponse.fromJson(dynamic str) {
    if (str == null || str == "") {
      return CheckCoverageResponse(false, null);
    }
    var json = jsonDecode(str);
    return CheckCoverageResponse(
        json['available'] as bool, json['operator_code'] as String);
  }
}
