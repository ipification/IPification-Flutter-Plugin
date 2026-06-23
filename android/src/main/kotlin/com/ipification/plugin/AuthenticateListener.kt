package com.ipification.plugin

/**
 * Receives normalized authentication outcomes from [AuthenticationHelper].
 */
interface AuthenticationListener {
    /**
     * Called when the SDK returns a successful authentication response.
     *
     * @param result Raw response data returned by the native SDK.
     */
    fun onSuccess(result: String)

    /**
     * Called when authentication fails before a successful response is available.
     *
     * @param result Normalized plugin error payload.
     */
    fun onFail(result: AuthenticationError)

    /**
     * Called when the user cancels Instant Messaging authentication.
     */
    fun onIMCancel()
}
