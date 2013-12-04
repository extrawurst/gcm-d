
import gcm.gcm;

void main()
{
	auto gcm = new GCM("AIzaSyCxwnHC-ZL1DKurSAcSQfC3rH5M6q4V9UQ");

	auto request = GCMRequest();
	
	request.dry_run = true;
	
	request.registration_ids ~= 42;

	GCMResponse response;
	gcm.request(request,response);
}