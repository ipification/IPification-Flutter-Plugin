//
//  AuthenticationError.swift
//  integration_test
//
//  Created by ipification on 1/20/21.
//

import Foundation
struct AuthenticationError {
    var error_code: ErrorCode = ErrorCode.COVERAGE_UNAVAILABLE
    var error_message:String? = ""
}
