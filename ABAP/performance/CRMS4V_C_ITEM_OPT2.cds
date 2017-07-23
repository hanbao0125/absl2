@AbapCatalog.sqlViewName: 'CRMS4VCITEMODL2'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Business Document Item consumption view'

define view CRMS4V_C_ITEM_OPT2 as select from CRMS4V_C_ITEM_OPT_txt_delay as item 
left outer to one join tj02t on item.status_id = tj02t.istat and tj02t.spras = $session.system_language 
association[0..1] to I_BusinessPartner as _soldTo on $projection.sold_to_party = _soldTo.BusinessPartner                               
association[0..1] to I_BusinessPartner as _contact on $projection.contact_person = _contact.BusinessPartner
association[0..1] to I_BusinessPartner as _serviceteam on $projection.service_team = _serviceteam.BusinessPartner
{
  key item.item_guid as item_guid,
   item.object_id,
   item.description,
   item.description_uc,
   item.posting_date,
   item.product_id,
   item.guid,
   item.priority,
   item.contact_person,
   item.sold_to_party,
   item.service_team,
   item.category_id,
   item.priority_txt,
   item.valid_from,
   item.valid_to,
   item.sales_org_id,
   item.service_org_id,
   item.status_id,
   tj02t.txt30 as concatstat,
   //'In process' as concatstat,
   _contact,
   _soldTo,
   _serviceteam
}
