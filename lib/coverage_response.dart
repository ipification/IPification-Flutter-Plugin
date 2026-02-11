import 'dart:convert';

class CheckCoverageResponse {
  final bool isAvailable;
  final String? operatorCode;

  CheckCoverageResponse(this.isAvailable, this.operatorCode);

  factory CheckCoverageResponse.fromJson(String? str) {
    if (str == null || str.isEmpty) {
      return CheckCoverageResponse(false, null);
    }
    try {
      final Map<String, dynamic> json = jsonDecode(str);
      return CheckCoverageResponse(
        json['available'] as bool? ?? false,
        json['operator_code'] as String?,
      );
    } catch (e) {
      return CheckCoverageResponse(false, null);
    }
  }

  Map<String, dynamic> toJson() => {
        'available': isAvailable,
        'operator_code': operatorCode,
      };
}
