//
//  AuthenticationError.swift
//  integration_test
//
//  Created by ipification on 1/20/21.
//

import Foundation

/// Error payload passed from the iOS authentication layer back to Flutter.
struct AuthenticationError {
    /// Stable plugin error code used as the Flutter error code.
    var error_code: ErrorCode = ErrorCode.COVERAGE_UNAVAILABLE
    /// Human-readable error message returned by the native SDK.
    var error_message:String? = ""
}
