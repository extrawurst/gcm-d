module gcm.gcm;

import vibe.core.log;
import vibe.http.client;

import vibe.data.json;

///see http://developer.android.com/google/gcm/server.html#params
struct GCMRequest
{
	///A string array with the list of devices (registration IDs) receiving the message
	int[] registration_ids;

	///A string that maps a single user to multiple registration IDs associated with that user.
	string notification_key;

	///An arbitrary string (such as "Updates Available") that is used to collapse a group of like messages when the device is offline, so that only the last message gets sent to the client
	string collapse_key;

	///A JSON object whose fields represents the key-value pairs of the message's payload data
	Json data;

	///If included, indicates that the message should not be sent immediately if the device is idle
	bool delay_while_idle;

	///How long (in seconds) the message should be kept on GCM storage if the device is offline
	int time_to_live;

	///A string containing the package name of your application
	string restricted_package_name;

	///If included, allows developers to test their request without actually sending a message
	bool dry_run;

	Json toJson()
	{
		Json result = Json.emptyObject;

		result.registration_ids = serializeToJson(registration_ids);

		return result;
	}
}

/// see http://developer.android.com/google/gcm/http.html
struct GCMResponse
{
	///Unique ID (number) identifying the multicast message.
	int multicast_id;

	///Number of messages that were processed without an error.
	int success;

	///Number of messages that could not be processed.
	int failure;

	///Number of results that contain a canonical registration ID. See Advanced Topics for more discussion of this topic.
	int canonical_ids;
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

						logInfo("body: %s",_req.toJson().toString);

						req.writeJsonBody(_req.toJson());
					},
					(scope res) {
						logInfo("Response: %d", res.statusCode);

						statusCode = res.statusCode;

						foreach (k, v; res.headers)
							logInfo("Header: %s: %s", k, v);
					}
		);

		return statusCode;
	}
}