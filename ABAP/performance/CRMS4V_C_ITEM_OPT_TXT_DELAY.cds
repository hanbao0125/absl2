@AbapCatalog.sqlViewName: 'CRMS4VCITEMODL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Business Document Item consumption view'
define view CRMS4V_C_ITEM_OPT_TXT_DELAY as select from CRMS4V_I_ITEM_WO_STATUS_TEXT as item 
left outer to one join scpriot on  item.priority = scpriot.priority
                                  and scpriot.langu = $session.system_language
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
   scpriot.txt_long as priority_txt,
   item.valid_from,
   item.valid_to,
   item.sales_org_id,
   item.service_org_id,
   case when item.status_i1001_created = 'X' then 'I1001'
        when item.status_i1002_open = 'X' then 'I1002'
        when item.status_i1003_in_process = 'X' then 'I1003'
        when item.status_i1004_released = 'X' then 'I1004'
        when item.status_i1005_completed = 'X' then 'I1005'
        when item.status_i1007_confirmed = 'X' then 'I1007'
        when item.status_i1008_finished = 'X' then 'I1008'
        else ''
   end as status_id
   // CAST( operand AS dtype [PRESERVING TYPE]) ... 
   // cast ('' as char40 ) as concatstat
}
