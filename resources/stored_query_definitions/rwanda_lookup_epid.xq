import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare namespace csd = "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 


let $id_number := ($careServicesRequest/id_number , $careServicesRequest/csd:id_number)[1]
let $id_type := ($careServicesRequest/id_type, $careServicesRequest/csd:id_type)[1]

let $provider := 
  if (exists($id_number) and exists($id_type))
  then 
     let $provs :=   /csd:CSD/csd:providerDirectory/csd:provider[./csd:otherID[./@code = $id_type and ./text() = $id_number]]
     return $provs[1]
  else ()

return $provider
