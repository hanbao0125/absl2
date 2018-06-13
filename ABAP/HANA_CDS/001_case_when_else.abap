@AbapCatalog.sqlViewName: 'ZMATTYPE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'material type'
define view Zmaterial_Type as select from mara inner join t134 on mara.mtart 
= t134.mtart {
  key mara.scm_matid_guid16 as product_guid,
   case 
    when ( mara.mtart = 'SERV') or t134.prod_type_code = '2'
     then '02'
    else '01'
  end as product_type
}