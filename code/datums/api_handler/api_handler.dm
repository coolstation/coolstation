/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=API HANDLER BY WIRE-=-=-=-=-=-=*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/// Whether or not to log every API application error
#define API_LOG_ERRORS TRUE
/// Whether or not debug logging is enabled
#define API_LOG_DEBUG TRUE

/// Holder for [/datum/api]
var/global/datum/api/api

/**
 * # API Handler
 *
 * Holder datum for backend API communication
 *
 * Provides a thin wrapper over [/datum/http_request] to handle backend API
 * queries by attaching relevant metadata and authentication tokens.
 *
 * Usage:
 * ```
 * try
 *	var/list/response = api.post("/rounds/start", list(
 *		"server_id" = config.server_id,
 *		"map" = map_setting
 *	)).body
 *	round_id = text2num(response(["data"]))
 * catch(var/exception/e)
 * 	world.log << "Ruh roh: [e.name]"
 * ```
 */
/datum/api
	/// The base API URL
	var/base_url
	/// API authentication token
	var/auth_token

	New()
		..()
		src.base_url = config.api_base_url
		src.auth_token = config.api_auth_token

	/**
	 * Log an API application error
	 *
	 * Arguments:
	 * * request - An API request of type [/datum/api_request]
	 * * response - An API response of type [/datum/api_response]
	 */
	proc/log_error(datum/api_request/request, datum/api_response/response)
		var/url = replacetext(request.url, src.auth_token, "redacted")
		var/description = "Unknown error"
		if (response.body["error"] && response.body["error"]["message"])
			description = response.body["error"]["message"]
		var/err = "Error returned for query ([request.method]) [url]: [description]"
		logTheThing("debug", null, null, "<b>API Error</b>: [err]")
		logTheThing("diary", null, null, "API Error: [err]", "debug")

	/**
	 * Debug logging. Only does anything if the [API_LOG_DEBUG] define is truthy
	 *
	 * Arguments:
	 * * message - A string describing the event
	 * * data - Data of any type that will be appended to the log as a json encoded string
	 */
	proc/log_debug(message = "", data)
		#if API_LOG_DEBUG
		message = replacetext(message, src.auth_token, "redacted")
		data = replacetext(json_encode(data), src.auth_token, "redacted")
		logTheThing("debug", null, null, "<b>API Debug</b>: [message]. Data: [data]")
		#endif

	/**
	 * Build and send an API request
	 *
	 * Arguments:
	 * * method - HTTP Method to use, see code/rust_g.dm for a full list
	 * * route - The route to send the request to (e.g. /players)
	 * * data - The body of the request, if applicable
	 * * headers - Associative list of HTTP headers to send, if applicable
	 * * retry_attempts - How many times should we retry this request if it fails
	 */
	proc/request(method, route = "", list/data = list(), list/headers = list(), retry_attempts = 0)
		RETURN_TYPE(/datum/api_response)
		if (!src.base_url || !src.auth_token || !method)
			src.log_debug("Invalid request", list("base_url" = src.base_url, "auth_token" = src.auth_token, "method" = method))
			throw EXCEPTION("Invalid request")

		if (route && copytext(route, 1, 2) != "/") route = "/[route]"
		var/url = "[src.base_url][route]?api_token=[src.auth_token]"
		if (round_id) data["round_id"] = round_id

		// Transform data depending on method
		if (RUSTG_HTTP_METHOD_GET == method)
			if (length(data))
				url += "&[list2params(data)]"
				data = null
		else
			headers["Content-Type"] = "application/x-www-form-urlencoded"
			data = list2params(data)

		var/datum/api_request/api_request = new(method, url, data, headers)
		var/datum/api_response/response
		var/current_attempt = 1
		while(!response)
			try
				src.log_debug("Performing API request (attempt: [current_attempt]) to ([method]) [url]", list("body" = data, "headers" = headers))
				response = api_request.send(throw_app_errors = !!retry_attempts)
			catch (var/exception/e)
				// If we're retrying this query, we'll suppress any exceptions to let the loop
				// continue. Otherwise we're done here, so re-throw the exception
				if (!retry_attempts || (retry_attempts && current_attempt >= retry_attempts))
					throw EXCEPTION(replacetext(e.name, src.auth_token, "redacted"))
			current_attempt++

		src.log_debug("Received response", response.body)
		return response


/**
 * # API Request
 *
 * Holder datum for API requests
 *
 * Provides a thin wrapper over [/datum/http_request] that handles application
 * level errors, and can be re-used
 */
/datum/api_request
	/// HTTP method used
	var/method
	/// URL that the request is being sent to
	var/url
	/// Body of the request being sent
	var/body
	/// Request headers being sent
	var/headers

	/**
	 * Arguments:
	 * * method - HTTP Method to use, see code/rust_g.dm for a full list
	 * * url - The URL to send the request to
	 * * body - The body of the request, if applicable
	 * * headers - Associative list of HTTP headers to send, if applicable
	 */
	New(method, url, body, headers)
		..()
		src.method = method
		src.url = url
		src.body = body
		src.headers = headers

	/**
	 * Send a request
	 *
	 * Arguments:
	 * * throw_app_errors - Whether or not to treat API application errors as exceptions (generally only used by the request retry logic)
	 */
	proc/send(throw_app_errors = FALSE)
		var/datum/http_request/request = new()
		request.prepare(src.method, src.url, src.body, src.headers)
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/api_response/api_response = new(request.into_response())
		if (api_response.errored) throw EXCEPTION(api_response.error)

		// API application error occurred
		if (api_response.status_code != 200)
			#if API_LOG_ERRORS
			// Interceptor to globally log API application level errors
			api.log_error(src, api_response)
			#endif
			if (throw_app_errors)
				throw EXCEPTION("Failed to query API")

		return api_response

/**
 * # API Response
 *
 * Holder datum for API responses
 *
 * Provides a thin wrapper over [/datum/http_response] to make retrieving API
 * data slightly easier
 */
/datum/api_response
	/// The HTTP status code of the response
	var/status_code
	/// The decoded body of the response from the server
	var/list/body
	/// Associative list of headers sent from the server
	var/list/headers
	/// Has the request errored
	var/errored = FALSE
	/// Raw response if we errored
	var/error

	/**
	 * Arguments:
	 * * http_response - A HTTP response of type [/datum/http_response]
	 */
	New(datum/http_response/http_response)
		..()
		if (http_response.errored)
			src.errored = TRUE
			src.error = http_response.error
		else
			src.status_code = http_response.status_code
			src.body = json_decode(http_response.body)
			src.headers = http_response.status_code
