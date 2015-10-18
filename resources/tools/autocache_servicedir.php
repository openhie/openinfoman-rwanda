<?php
	#####Set variables#####
	$ihris_url=array("manage"=>"http://localhost/HRIS","qualify"=>"http://localhost/NCNM");
	$openinfoman_url="http://localhost:8984/CSD";
	$ihris_oim_service_dir=array("manage"=>"Manage-HW","qualify"=>"qualify-HW");
	$OIM_service_dir=array("chw"=>"CHW","manage"=>"Manage-HW","qualify"=>"qualify-HW");
	$ihris_credentials=array("manage"=>"uname:passwd","qualify"=>"uname:passwd");
	#####End of setting variables#####
	foreach ($ihris_url as $index=>$url) {
	#####Preparing iHRIS CSD Caches#####
	$url=$url."/csd_cache?action=full_update";
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL,$url);
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
	curl_setopt($ch, CURLOPT_USERPWD, $ihris_credentials[$index]);
	curl_setopt($ch, CURLOPT_VERBOSE, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$output = curl_exec ($ch);
	curl_error($ch);
	curl_close ($ch);
	var_dump($output);
	#####End of preparing iHRIS CSD Caches#####

	#####Pull any new iHRIS records into openinfoman#####
	$doc=str_replace(".xml","",$ihris_oim_service_dir[$index]);
	exec("curl $openinfoman_url/pollService/directory/$doc/update_cache");
	#####End of pulling any new iHRIS contacts into openinfoman#####
	}
?>
