* Create Interaction Record
* Created by Jerry Wang on Mar 27, 2014

REPORT ZCREATE_IR.
DATA ls_ic_profile TYPE crmc_ic_profile.
DATA ls_bt_profile TYPE crmc_ic_btprof.

DATA lt_detail TYPE crmt_name_value_pair_tab.

DATA lr_col_wrap TYPE REF TO cl_bsp_wd_collection_wrapper.
DATA lr_irec TYPE REF TO cl_crm_bol_entity.
DATA lr_core TYPE REF TO cl_crm_bol_core.
DATA lr_factory TYPE REF TO cl_crm_bol_entity_factory.
DATA lv_transaction TYPE REF TO if_bol_transaction_context.
DATA lr_msg_service TYPE REF TO cl_bsp_wd_message_service.
DATA lv_bt_type_description TYPE crmt_description_20.
DATA lr_gdc TYPE REF TO if_crm_ui_data_context.

FIELD-SYMBOLS: <ls_detail> TYPE crmt_name_value_pair.

lr_core = cl_crm_bol_core=>get_instance( ).
lr_core->load_component_set( 'ONEORDER' ).
lr_factory = lr_core->get_entity_factory( 'BTOrder' ).
lt_detail = lr_factory->get_parameter_table( ).
LOOP AT lt_detail ASSIGNING <ls_detail>.
CASE <ls_detail>-name.
WHEN 'PROCESS_TYPE'.
<ls_detail>-value = '0010'.
ENDCASE.
ENDLOOP.
lr_irec ?= lr_factory->create( iv_params = lt_detail ).
lv_transaction = lr_core->get_transaction( ).

CHECK lv_transaction->check_save_possible( ) = abap_true.
CHECK lv_transaction->save( ) EQ abap_true.
lv_transaction->commit( ).
DATA(lo_header) = lr_irec->get_related_entity( 'BTOrderHeader' ).
DATA: lv_id TYPE crmst_adminh_btil-object_id.

lv_id = lo_header->get_property_as_string( 'OBJECT_ID' ).
WRITE: / 'Interaction record created successful: ' , lv_id.