import module namespace csd_dm = "https://github.com/openhie/openinfoman/csd_dm";
import module namespace csd_webconf =  "https://github.com/openhie/openinfoman/csd_webconf";
import module namespace uuid = "https://github.com/openhie/openinfoman-datim/uuid";
declare namespace csd  =  "urn:ihe:iti:csd:2013";
let $facilities_service_dir := "Facilities"
let $CHW_doc_name := "CHW"
let $doc :=  csd_dm:open_document($csd_webconf:db,$facilities_service_dir)
let $chw_file := file:read-text("./chw.json")
let $json := json:parse($chw_file)
let $data :=
<csd:CSD xmlns:csd="urn:ihe:iti:csd:2013">
  <csd:organizationDirectory/>
  <csd:serviceDirectory/>
  <csd:facilityDirectory/>
  <csd:providerDirectory>
{
for $record in $json/json/_
let $facility_uuid := string($doc//csd:facility[string(./csd:otherID[@code="code"])=data($record/health__centre____code)]/@entityID)
let $referal_facility_uuid := string($doc//csd:facility[string(./csd:otherID[@code="code"])=data($record/referral__hospital____code)]/@entityID)
return
    <csd:provider xmlns:csd="urn:ihe:iti:csd:2013" entityID="{concat("urn:uuid:",random:uuid())}">
      <csd:demographic>
        <csd:name>
          <csd:commonName>{fn:normalize-space(concat(data($record/given__name),data($record/surname)))}</csd:commonName>
          <csd:surname>{fn:normalize-space(data($record/surname))}</csd:surname>
          <csd:forename>{fn:normalize-space(data($record/given__name))}</csd:forename>
        </csd:name>
        <csd:gender>{data($record/sex)}</csd:gender>
        <csd:dateOfBirth>{data($record/date__of__birth)}</csd:dateOfBirth>
      </csd:demographic>
      <csd:facilities>
        <csd:facility entityID="{$facility_uuid}">
        </csd:facility>
      </csd:facilities>
      <csd:referalHospital entityID="{$referal_facility_uuid}"></csd:referalHospital>
    </csd:provider>
}
</csd:providerDirectory>
</csd:CSD>
return
csd_dm:add($csd_webconf:db,$data,$CHW_doc_name)
