<?php
include 'vendor/autoload.php';
include 'config.php';

// The API key for Exlibris
$key=EXL_API_KEY;
// The job id to run
$jobId=EXL_JOB_ID;

$api = new RestClient([
	'base_url' => "https://api-na.hosted.exlibrisgroup.com/",
	'headers' => ['Authorization' => 'apikey '."$key",
				 'Accept' => 'application/json',
				 'Content-Type'=>' application/json',
				],
]);

// See: https://developers.exlibrisgroup.com/alma/apis/conf/
// Check to see if this job id is valid
$jobCall = $api->get("almaws/v1/conf/jobs/$jobId");
if ($jobCall && $jobCall->info->http_code === 200) {
	$job = json_decode($jobCall->response);
	if (!$job) {
		throw new Exception('Job '.$jobId.' had no content');
	}
} else if ($jobCall) {
	throw new Exception('GET for job '.$jobId.' returned '.$jobCall->info->http_code);
} else {
	throw new Exception('GET API call construction failed');
}
// Submit the job for a run
$jobCall = $api->post("almaws/v1/conf/jobs/$jobId?op=run", '{job}');
// TODO: confirm 201 response to POST
if ($jobCall && $jobCall->info->http_code === 201) {
	$instance = json_decode($jobCall->response);
	// TODO: check instance for possible error codes
	if ($instance) {
		print json_encode($instance);
	}
} else if ($jobCall) {
	throw new Exception('POST for job '.$jobId.' returned '.$jobCall->info->http_code);
} else {
	throw new Exception('GET API call construction failed');
}
?>


