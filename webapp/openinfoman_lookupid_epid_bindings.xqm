module namespace page = 'http://basex.org/modules/web-page';

(:Import other namespaces.  :)
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace request = "http://exquery.org/ns/request";


declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare namespace   xforms = "http://www.w3.org/2002/xforms";




declare function page:is_lookup_function($search_name) {
  let $function := csr_proc:get_function_definition($csd_webconf:db,$search_name)
  let $ext := $function//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter' and @type='lookup_epid']
  return (count($ext) > 0) 
};



declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/lookup_epid")
  %output:method("xhtml")
  function page:show_endpoints($search_name,$doc_name) 
{  
  let $contents := 
    if (not(page:is_lookup_function($search_name)) ) 
      then ('Not a compatible stored function for Lookup of EPID'    )
    else 
      let $url := concat($csd_webconf:baseurl, "CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/lookup_epid/lookup")
      return 
        <div>
          <h2>Lookup EPID Operations on {$doc_name}</h2>
	  <span>
	    <form action="{$url}" method="GET" >
	      <label for='id_type' >ID Type</label>
	      <select  name='id_type'>
		<option value='NID'>NID</option>
	      </select>
	      <br/>
	      <label for='id_number' >ID Number</label>
	      <input type='text' size='60'  name='id_number'/>
	      <br/>
	      <input type='submit' value='Lookup'/>
	    </form>
	  </span>
	</div>
  return csd_webconf:wrapper($contents)
};

declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/lookup_epid/lookup")
  %rest:query-param("id_type","{$id_type}")
  %rest:query-param("id_number","{$id_number}")
  function page:read_entity($search_name,$doc_name,$id_type,$id_number) 
{

  let $function := csr_proc:get_function_definition($csd_webconf:db,$search_name)
  let $doc := csd_dm:open_document($csd_webconf:db,$doc_name)
  
  let $requestParams := 
    <csd:requestParams function="{$search_name}" resource="{$doc_name}" base_url="{$csd_webconf:baseurl}">
      <id_type>{$id_type}</id_type>
      <id_number>{$id_number}</id_number>
    </csd:requestParams>

  let $results := csr_proc:process_CSR_stored_results($csd_webconf:db, $doc,$requestParams)
  let $epid := substring-after(string($provider[1]/@entityID),'urn:uuid:')

  return 
    if (exists($epid) and string-length($epid) > 0) 
      $epid
    else 
      (:error :)
      <http:response status="404" message="No provider found with ID number '{$id_number}' and ID type '{$id_type}'.">
	<http:header name="Content-Language" value="en"/>
	<http:header name="Content-Type" value="text/html; charset=utf-8"/>
      </http:response>

};


