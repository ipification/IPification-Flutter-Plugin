//
//  ErrorCode.swift
//  integration_test
//
//  Created by ipification on 1/20/21.
//

import Foundation

enum ErrorCode  :String {
    case COVERAGE_UNAVAILABLE = "coverage_unavailable"
    case COVERAGE_ERROR = "coverage_error"
    case AUTHENTICATE_FAIL = "authenticate_fail"
    case AUTHENTICATE_IM_CANCEL = "im_canceled"
}
