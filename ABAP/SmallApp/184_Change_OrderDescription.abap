REPORT  zorder_search_update.

PARAMETERS: id   TYPE crmd_orderadm_h-object_id OBLIGATORY DEFAULT '8000000140',
            type TYPE char4 OBLIGATORY DEFAULT 'SRVO'.

DATA: lo_core                TYPE REF TO cl_crm_bol_core,
      lo_collection          TYPE REF TO if_bol_entity_col,
      lv_query_name          TYPE crmt_ext_obj_name,
      lt_selection_parameter TYPE genilt_selection_parameter_tab,
      ls_selection_parameter TYPE genilt_selection_parameter,
      lo_order               TYPE REF TO cl_crm_bol_entity,
      lo_header              TYPE REF TO cl_crm_bol_entity,
      lv_success             TYPE abap_bool,
      lv_changed             TYPE abap_bool,
      ls_query_parameters    TYPE genilt_query_parameters,
      lv_size                TYPE i.

START-OF-SELECTION.

  ls_selection_parameter-attr_name = 'OBJECTID'.
  ls_selection_parameter-option =  'EQ'.
  ls_selection_parameter-sign = 'I'.
  ls_selection_parameter-low =  id.

  APPEND ls_selection_parameter TO lt_selection_parameter.

  ls_selection_parameter-attr_name = 'MAINCATEGORY'.
  ls_selection_parameter-option =  'EQ'.
  ls_selection_parameter-sign = 'I'.
  ls_selection_parameter-low =  type.
  APPEND ls_selection_parameter TO lt_selection_parameter.
  lv_query_name = 'BTAdvQueryAUI'.

  lo_core = cl_crm_bol_core=>get_instance( ).
  lo_core->load_component_set( 'BT' ).

  lo_collection = lo_core->dquery(
          iv_query_name               = lv_query_name
          it_selection_parameters     = lt_selection_parameter
          is_query_parameters         = ls_query_parameters ).

  CHECK lo_collection IS NOT INITIAL.
  lv_size = lo_collection->size( ).
  WRITE: / 'Number of Service Order found: ' , lv_size COLOR COL_POSITIVE.
  CHECK lv_size > 0.
  lo_order = lo_collection->get_first( ).

  lo_header = lo_order->get_related_entity( 'BTOrderHeader' ).

  lo_header->switch_to_change_mode( ).

  lo_header->set_property( iv_attr_name = 'DESCRIPTION' iv_value = 'new' ).

  DATA: lo_transaction TYPE REF TO if_bol_transaction_context.

  lo_transaction = lo_core->get_transaction( ).
  lo_core->modify( ).
  lv_changed = lo_transaction->check_save_needed( ).

  CHECK lv_changed EQ abap_true.
  lv_success = lo_transaction->save( ).
  IF lv_success = abap_true.
    lo_transaction->commit( ).
    WRITE:/ 'Service Order changed Successfully'.
  ELSE.
    lo_transaction->rollback( ).
  ENDIF.