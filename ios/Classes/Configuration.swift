//
//  Configuration.swift
//  integration_test
//
//  Created by ipification on 1/26/21.
//

import Foundation

/// Codable configuration values used by the iOS wrapper.
struct Configuration: Codable {
    /// Coverage endpoint override.
    var COVERAGE_ENDPOINT:String?
    /// Authorization endpoint override.
    var AUTHORIZE_ENDPOINT:String?
    /// Redirect URI configured for authorization.
    var REDIRECT_URI:String?
    /// Client identifier configured for authorization.
    var CLIENT_ID:String?
}
