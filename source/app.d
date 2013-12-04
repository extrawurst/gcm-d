
import gcm.gcm;

void main()
{
	auto gcm = new GCM("api key");

	auto request = GCMRequest();
	
	request.dry_run = true;
	
	request.registration_ids ~= 42;

	GCMResponse response;
	gcm.request(request,response);
}