module namespace page = 'http://basex.org/modules/web-page';

(:Import other namespaces.  :)
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csr_proc = "https://github.com/openhie/openinfoman/csr_proc";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_mcs = "https://github.com/openhie/openinfoman/csd_mcs";
import module namespace functx = "http://www.functx.com";

declare namespace csd = "urn:ihe:iti:csd:2013";


declare function page:is_datim($search_name) {
  let $function := csr_proc:get_function_definition($csd_webconf:db,$search_name)
  let $ufunction := csr_proc:get_updating_function_definition($csd_webconf:db,$search_name)
  let $ext := $function//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter' and @type='datim']
  let $uext := $ufunction//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter' and @type='datim']
  return (count($uext) + count($ext) > 0) 
};


declare function page:get_actions($search_name) {
  let $function := csr_proc:get_function_definition($csd_webconf:db,$search_name)
  let $ufunction := csr_proc:get_updating_function_definition($csd_webconf:db,$search_name)
  return 
    (
    for $act in $function//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter:datim:action']/@type
    return string($act)
    ,for $act in $ufunction//csd:extension[  @urn='urn:openhie.org:openinfoman:adapter:datim:action']/@type
    return string($act)
  )
};



declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/datim")
  %output:method("xhtml")
  function page:show_endpoints($search_name,$doc_name) 
{  
    if (not(page:is_datim($search_name)) ) 
      then ('Not a DATIM Compatible stored function'    )
    else 
      let $actions := page:get_actions($search_name)
      let $contents := 
      <div>
        <h2>DATIM Operations on {$doc_name}</h2>
        { 
          if ($actions = 'createDXF')  
	  then
	   <span>
             <h3>Generate DATIM DXF Document</h3>
	     {
	       let $url := concat($csd_webconf:baseurl, "CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/datim/createDXF")
	       return <a href="{$url}">Get DXF</a>
	     }
	   </span>
	  else ()
	}
        { 
          if ($actions = 'upload')  
	  then
	   <span>
             <h3>Upload Document</h3>
	     {
	       let $function := csr_proc:get_updating_function_definition($csd_webconf:db,$search_name)
	       let $oid := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:oid']/@type)		 
	       let $codelist_prefix := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:codelist_prefix']/@type)		 
	       let $url := concat($csd_webconf:baseurl, "CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/datim/upload")
	       return 
	         <form action="{$url}" method="POST" enctype="multipart/form-data">
		   <label for='file' >Source Data File</label>
		   <input type='file' name='file'/>
		   <br/>
		   <label for='oid' >Root OID for SVS list ID</label>
		   <input type='text' size='60' value="{$oid}" name='oid'/>
		   <br/>
		   <label for='codelist_prefix' >Root CODELIST_PREFIX for use in ADX disaggregators</label>
		   <input type='text' size='60' value="{$codelist_prefix}" name='codelist_prefix'/>
		   <br/>
		   <input type='submit' value='Upload'/>
		 </form>
	     }
	   </span>
	  else ()
	}
        { 
          if ($actions = 'uploadCSV')  
	  then
	   <span>
             <h3>Upload Document</h3>
	     {
	       let $function := csr_proc:get_updating_function_definition($csd_webconf:db,$search_name)
	       let $oid := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:oid']/@type)		 
	       let $codelist_prefix := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:codelist_prefix']/@type)		 
	       let $url := concat($csd_webconf:baseurl, "CSD/csr/" , $doc_name , "/careServicesRequest/",$search_name, "/adapter/datim/uploadCSV")
	       return 
	         <form action="{$url}" method="POST" enctype="multipart/form-data">
		   <label for='file' >Source Data File</label>
		   <input type='file' name='file'/>
		   <br/>
		   <label for='oid' >Root OID for SVS list ID</label>
		   <input type='text' size='60' value="{$oid}" name='oid'/>
		   <br/>
		   <label for='codelist_prefix' >Root CODELIST_PREFIX for use in ADX disaggregators</label>
		   <input type='text' size='60' value="{$codelist_prefix}" name='codelist_prefix'/>
		   <br/>
		   <input type='submit' value='Upload'/>
		 </form>
	     }
	   </span>
	  else ()
	}

      </div>
      return csd_webconf:wrapper($contents)
};


 
declare
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/datim/createDXF")
  function page:execute2($search_name,$doc_name) 
{
  if (not(page:is_datim($search_name)) ) 
    then ('Not a DATIM Compatible stored function'    )
  else 
    let $doc :=  csd_dm:open_document($csd_webconf:db,$doc_name)
    let $function := csr_proc:get_function_definition($csd_webconf:db,$search_name)
    let $assName := "www.datim.org:orgid"
    let $requestParams := 
      <csd:requestParams function="{$search_name}" resource="{$doc_name}" base_url="{$csd_webconf:baseurl}">
        <assigningAuthorityName>{$assName}</assigningAuthorityName>
      </csd:requestParams>

    return csr_proc:process_CSR_stored_results($csd_webconf:db, $doc,$requestParams)
};

declare updating
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/datim/uploadCSV")
  %rest:POST
  %rest:form-param("file", "{$file}")
  %rest:form-param("oid", "{$oid}",'')
  %rest:form-param("codelist_prefix", "{$codelist_prefix}",'')
  function page:update_doc_csv($search_name,$doc_name,$file,$oid,$codelist_prefix) 
{
  if (not(page:is_datim($search_name)) ) then
    db:output(<restxq:redirect>{$csd_webconf:baseurl}CSD/bad</restxq:redirect>)
  else 
    let $function := csr_proc:get_updating_function_definition($csd_webconf:db,$search_name)
    let $d_oid := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:oid']/@type)    
    let $s_oid := if ($oid = '') then $d_oid else $oid

    let $codelist_prefix := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:codelist_prefix']/@type)		 
    let $d_codelist_prefix := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:codelist_prefix']/@type)    
    let $s_codelist_prefix := if ($codelist_prefix = '') then $d_codelist_prefix else $codelist_prefix

    let $name :=  map:keys($file)[1]
      
    let $path    := file:temp-dir() || $name
    let $res_0 := file:write-binary($path,$file($name))

    let $csv := 
      csv:parse(
        string(file:read-text($path,'Latin-1')), 
	map { 'header': true() , 'format': 'attributes' }
       )

    return 
       (
	 page:process_request($search_name,$doc_name,$csv,$s_oid,$s_codelist_prefix) 
	 , file:delete($path)
       )

};

declare updating
  %rest:path("/CSD/csr/{$doc_name}/careServicesRequest/{$search_name}/adapter/datim/upload")
  %rest:POST
  %rest:form-param("file", "{$file}")
  %rest:form-param("oid", "{$oid}",'')
  %rest:form-param("codelist_prefix", "{$codelist_prefix}",'')
  function page:update_doc($search_name,$doc_name,$file,$oid,$codelist_prefix) 
{
  if (not(page:is_datim($search_name)) ) then
    db:output(<restxq:redirect>{$csd_webconf:baseurl}CSD/bad</restxq:redirect>)
  else 
    let $function := csr_proc:get_updating_function_definition($csd_webconf:db,$search_name)
    let $d_oid := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:oid']/@type)    
    let $s_oid := if ($oid = '') then $d_oid else $oid

    let $codelist_prefix := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:codelist_prefix']/@type)		 
    let $d_codelist_prefix := string($function/csd:extension[@urn='urn:openhie.org:openinfoman:adapter:datim:action:uploadDXF:codelist_prefix']/@type)    
    let $s_codelist_prefix := if ($codelist_prefix = '') then $d_codelist_prefix else $codelist_prefix

    let $name :=  map:keys($file)[1]

    let $content := parse-xml(convert:binary-to-string($file($name)))

    return page:process_request($search_name,$doc_name,$content,$s_oid,$s_codelist_prefix)
};



declare updating function page:process_request($search_name,$doc_name,$content,$oid,$codelist_prefix) {

    let $careServicesRequest := 
      <csd:careServicesRequest>
       <csd:function urn="{$search_name}" resource="{$doc_name}" base_url="{$csd_webconf:baseurl}">
         <csd:requestParams >
           <file>{$content}</file>
           <oid>{$oid}</oid>
           <codelist_prefix>{$codelist_prefix}</codelist_prefix>
         </csd:requestParams>
       </csd:function>
      </csd:careServicesRequest>
    return 
       (
        csr_proc:process_updating_CSR_results($csd_webconf:db, $careServicesRequest)
        ,db:output(<restxq:redirect>{$csd_webconf:baseurl}CSD</restxq:redirect>)
       )

};
