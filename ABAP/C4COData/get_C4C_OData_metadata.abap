*&---------------------------------------------------------------------*
*& Report  ZREAD_ODATA_METADATA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZREAD_ODATA_METADATA.

DATA:   lt_selection_param TYPE sesf_selection_parameters_tab,
        ls_selection_param TYPE sesf_selection_parameter,
        lt_node_id TYPE sesf_bo_node_id_tab,
        lv_node_id TYPE odata_extension_def_root1-node_id,
        lr_mo_acp TYPE REF TO if_esf_acp.

  TRY.
      lr_mo_acp = cl_esf_acp_factory=>get_acp(
          in_excl_transaction_owner = abap_false
      ).
    CATCH cx_esf_core_service INTO DATA(lx_core).
      RAISE EXCEPTION TYPE cx_fatal_exception
        EXPORTING
          previous = lx_core.
  ENDTRY.


    TRY.
        CLEAR: ls_selection_param.
        ls_selection_param-sign = 'I'.
        ls_selection_param-option = 'EQ'.
        ls_selection_param-low = 'opportunity'.
        ls_selection_param-attribute_name = bo_mdrs_odata_service=>root=>co_query_parameter-query_by_elements-service_name.
        APPEND ls_selection_param TO lt_selection_param.
        lr_mo_acp->query(
          EXPORTING
            in_bo_name               = bo_mdrs_odata_service=>co_bo_name
            in_bo_node_name          = bo_mdrs_odata_service=>root=>co_node_name
            in_query_name            = bo_mdrs_odata_service=>root=>co_query-query_by_elements
            in_selection_parameters  = lt_selection_param
            in_fill_data             = abap_false
        IMPORTING
            out_node_ids             = lt_node_id
        ).
      CATCH cx_esf_core_service INTO lx_core.
        RAISE EXCEPTION TYPE cx_fatal_exception
          EXPORTING
            previous = lx_core.
    ENDTRY.

 READ TABLE lt_node_id INTO DATA(node) INDEX 1.

 WRITE:/ node.