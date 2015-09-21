declare namespace csd = "urn:ihe:iti:csd:2013"; 

declare namespace svs = "urn:ihe:iti:svs:2008";
declare namespace dxf = "http://dhis2.org/schema/dxf/2.0";
declare namespace adx = "http://www.datim.org/adx:2015";

import module namespace datim = "http://www.datim.org";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace svs_lsvs = "https://github.com/openhie/openinfoman/svs_lsvs";
import module namespace uuid = "https://github.com/openhie/openinfoman-datim/uuid";
import module namespace functx = "http://www.functx.com";

declare variable $careServicesRequest as item() external; 


let $dxf := $careServicesRequest/file
let $datim_oid := $careServicesRequest/oid/text()
let $codelist_prefix := $careServicesRequest/codelist_prefix/text()

let $orgUnits := $dxf/dxf:metaData/dxf:organisationUnits/dxf:organisationUnit
let $orgGroups := $dxf/dxf:metaData/dxf:organisationUnitGroups/dxf:organisationUnitGroup

let $site_codes := ('FACILITY','COUNTRY','OUSCOUNTRIES','COMMUNITIY')   (:Org Unit Groups that can report data and so should have a CSD facilities :)

let $doc_name := string($careServicesRequest/@resource)
let $doc := csd_dm:open_document($csd_webconf:db,$doc_name)
let $org_dir := $doc/csd:CSD/csd:organizationDirectory
let $fac_dir := $doc/csd:CSD/csd:facilityDirectory





let $now := current-dateTime()



let $entities:= 
  for $orgUnit in $orgUnits
  let $level := xs:integer($orgUnit/@level)
  let $id := $orgUnit/@id
  let $code := $orgUnit/@code
  let $uuid := string($orgUnit/@uuid)
  let $displayName:=string($orgUnit/@name)
  let $pid:=string($orgUnit/dxf:parent/@id)
  let $puuid := $orgUnits[@id=$pid]/@uuid
  let $lm := datim:fixup_date($orgUnit/@lastUpdated)
  let $created := datim:fixup_date($orgUnit/@created)
  let $groups := $orgGroups[./dxf:organisationUnits/dxf:organisationUnit[@id = $id]]
  let $group_codes := $groups/@code
  let $facEntityID := concat("urn:uuid:",uuid:generate(concat('facility:',$id),$datim:namespace_uuid))
  let $orgEntityID := concat("urn:uuid:",uuid:generate(concat('organization:',$id),$datim:namespace_uuid))
  let $parentEntityID := concat("urn:uuid:",uuid:generate(concat('organization:',$pid),$datim:namespace_uuid))

  let $fac_entity :=
    if ($group_codes = $site_codes)
    then
      <csd:facility entityID="{$facEntityID}">
        <csd:otherID assigningAuthorityName="http://www.datim.org/orgUnit" code="id">{string($id)}</csd:otherID>
        <csd:otherID assigningAuthorityName="http://www.datim.org/orgUnit" code="code">{string($code)}</csd:otherID>
	{
	  if (not(functx:all-whitespace($uuid)))
	  then <csd:otherID assigningAuthorityName="http://www.datim.org/orgUnit" code="uuid">{string($uuid)}</csd:otherID>
	  else ()
	}
	<csd:codedType codingScheme="urn:www.datim.org" code="site"/>
	  {
	    for $group_code in $group_codes
	    return <csd:codedType codingScheme="urn:www.datim.org:org-unit-group" code="{$group_code}" />
	  }
	<csd:primaryName>{$displayName}</csd:primaryName>
	{datim:get_geocode($doc,$orgUnit)}
	{ 
	  if (not(functx:all-whitespace($puuid))) 
	  then 
            <csd:organizations>
	      <csd:organization entityID="{$parentEntityID}"/>
	    </csd:organizations>
	  else () 
	}
	<csd:record created="{$created}" updated="{$lm}" status="Active" sourceDirectory="http://www.datim.org"/>
      </csd:facility>
    else ()
  let $org_entity :=
    <csd:organization entityID="{$orgEntityID}">
      <csd:otherID assigningAuthorityName="http://www.datim.org/orgUnit" code="id">{string($id)}</csd:otherID>
      <csd:otherID assigningAuthorityName="http://www.datim.org/orgUnit" code="code">{string($code)}</csd:otherID>
      {
	if (not(functx:all-whitespace($uuid)))
	then <csd:otherID assigningAuthorityName="http://www.datim.org/orgUnit" code="uuid">{string($uuid)}</csd:otherID>
	else ()
      }
      <csd:codedType code="{$level}" codingScheme="urn:www.datim.org:org-unit-level"/>
      {
	for $group_code in $group_codes
	return <csd:codedType codingScheme="urn:www.datim.org:org-unit-group" code="{$group_code}" />
      }
      <csd:primaryName>{$displayName}</csd:primaryName>
      {datim:get_geocode($doc,$orgUnit) (:Should put in a CP to point geo codes for orgs as service delivery area :)}
      {
	if (not(functx:all-whitespace($puuid))) 
	then 
          <csd:organizations>
	    <csd:organization entityID="{$parentEntityID}"/>
	  </csd:organizations>
	else () 
      }
      <csd:record created="{$created}" updated="{$lm}" status="Active" sourceDirectory="http://www.datim.org"/>
    </csd:organization>

  return ($org_entity,$fac_entity)

	

	
let $level_oid := concat($datim_oid,'.2')
let $levels := $dxf/dxf:metaData/dxf:organisationUnitLevels/dxf:organisationUnitLevel
let $level_version := max(for $date in $levels/@lastUpdated return xs:dateTime(datim:fixup_date($date)))
let $svs_levels :=
  <svs:ValueSet  xmlns:svs="urn:ihe:iti:svs:2008" id="{$level_oid}" version="{$level_version}" displayName="Organisation Unit Levels for DATIM">
    <svs:ConceptList xml:lang="en-US" >
      {
	for $level in $levels
	return <svs:Concept code="{$level/@level}" displayName="{$level/@name}" codeSystem="urn:www.datim.org:org-unit-level" />
      }
    </svs:ConceptList>
  </svs:ValueSet>

let $group_oid := concat($datim_oid,'.3')
let $group_version := max(for $date in $orgGroups/@lastUpdated return xs:dateTime(datim:fixup_date($date)))
let $svs_groups :=
  <svs:ValueSet  xmlns:svs="urn:ihe:iti:svs:2008" id="{$group_oid}" version="{$group_version}" displayName="Organisation Unit Groups for DATIM">
    <svs:ConceptList xml:lang="en-US" >
      {
	for $group in $orgGroups
	return <svs:Concept code="{$group/@code}" displayName="{$group/@name}" codeSystem="urn:www.datim.org:org-unit-group" />
      }
    </svs:ConceptList>
  </svs:ValueSet>


let $svs_docs := ($svs_levels,$svs_groups)


return (
  for $entity in $entities
  let $id := $entity/@entityID
  return 
    if (local-name($entity) = 'facility')
    then 
      let $existing_fac := $fac_dir/csd:facility[@entityID = $id]
      return
        if (not(exists($existing_fac)))
        then (insert node $entity into $fac_dir)
        else (replace node $existing_fac with $entity)
    else
      let $existing_org := $org_dir/csd:organization[@entityID = $id]
      return
        if (not(exists($existing_org)))
        then (insert node $entity into $org_dir)
        else (replace node $existing_org with $entity)
  ,
  for $svs_doc in $svs_docs return svs_lsvs:insert($csd_webconf:db,$svs_doc) 

)
