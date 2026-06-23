package com.ipification.plugin

/**
 * Error payload passed from the Android authentication layer back to Flutter.
 *
 * @property error_code Stable plugin error code used as the Flutter error code.
 * @property error_message Human-readable error message returned by the native SDK.
 */
class AuthenticationError(var error_code: ErrorCode = ErrorCode.AUTHENTICATE_FAIL, var error_message:String?="") {
}
