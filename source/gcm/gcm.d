module gcm.gcm;

import vibe.core.log;
import vibe.http.client;
import vibe.stream.operations;

import vibe.data.json;

///see http://developer.android.com/google/gcm/server.html#params
struct GCMRequest
{
	///A string array with the list of devices (registration IDs) receiving the message
	string[] registration_ids;

	///A string that maps a single user to multiple registration IDs associated with that user.
	string notification_key;

	///An arbitrary string (such as "Updates Available") that is used to collapse a group of like messages when the device is offline, so that only the last message gets sent to the client
	string collapse_key;

	///A JSON object whose fields represents the key-value pairs of the message's payload data
	Json data;

	///If included, indicates that the message should not be sent immediately if the device is idle
	bool delay_while_idle;

	///How long (in seconds) the message should be kept on GCM storage if the device is offline
	int time_to_live = -1;

	///A string containing the package name of your application
	string restricted_package_name;

	///If included, allows developers to test their request without actually sending a message
	bool dry_run;

	Json toJson()
	{
		Json result = Json.emptyObject;

		result.registration_ids = serializeToJson(registration_ids);

		if(data.type != Json.undefined)
			result.data = data;

		if(dry_run)
			result.dry_run = true;

		if(delay_while_idle)
			result.delay_while_idle = true;

		if(time_to_live > -1)
			result.time_to_live = time_to_live;

		if(collapse_key.length > 0)
			result.collapse_key = collapse_key;
		if(restricted_package_name.length > 0)
			result.restricted_package_name = restricted_package_name;
		if(notification_key.length > 0)
			result.notification_key = notification_key;

		return result;
	}
}

/// see http://developer.android.com/google/gcm/http.html
struct GCMResponse
{
	///Unique ID (number) identifying the multicast message.
	long multicast_id;

	///Number of messages that were processed without an error.
	long success;

	///Number of messages that could not be processed.
	long failure;

	///Number of results that contain a canonical registration ID. See Advanced Topics for more discussion of this topic.
	long canonical_ids;

	///
	Json results;
}

/// wrapper class
class GCM
{
	private string m_apikey;

public:

	///
	this(string _key)
	{
		m_apikey = _key;
	}

	///
	int request(GCMRequest _req, ref GCMResponse _res)
	{
		int statusCode;

		requestHTTP("https://android.googleapis.com/gcm/send",
					(scope req) {
						req.method = HTTPMethod.POST;

						req.headers["Authorization"] = "key=" ~ m_apikey;
						req.headers["Content-Type"] = "application/json";

						//logInfo("body: %s",_req.toJson().toString);

						req.writeJsonBody(_req.toJson());
					},
					(scope HTTPClientResponse res) {
						//logInfo("Response: %d", res.statusCode);

						statusCode = res.statusCode;

						//foreach (k, v; res.headers)
						//	logInfo("Header: %s: %s", k, v);

						if(statusCode == 200)
							parseSuccessResult(res.readJson(), _res);
						else
							logInfo("response: %s", cast(string)res.bodyReader.readAll());
					}
		);

		return statusCode;
	}

private:

	static void parseSuccessResult(Json _body, ref GCMResponse _res)
	{
		_res.multicast_id = _body.multicast_id.get!long;

		_res.canonical_ids = _body.canonical_ids.get!long;

		_res.failure = _body.failure.get!long;
		_res.success = _body.success.get!long;

		_res.results = _body.results;
	}
}