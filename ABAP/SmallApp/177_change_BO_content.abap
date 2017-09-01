

REPORT  Z_update.
   DATA lo_lcp TYPE REF TO IF_ESF_LCP.
   DATA lo_facade TYPE REF TO if_esf_lcp_facade.
   DATA lv_out_rejected    TYPE abap_bool.
   DATA lx_core_excep      TYPE REF TO cx_esf_core_service.
   DATA lv_text            TYPE string.
   DATA lo_lcp_transaction TYPE REF TO if_esf_lcp_transaction.
   DATA ls_node_container TYPE REF TO IF_LOGISTICS_TASK_TEMPLATE=>TY_ROOT.
   DATA lt_data TYPE IF_LOGISTICS_TASK_TEMPLATE=>TT_ROOT.
   DATA ls_data TYPE IF_LOGISTICS_TASK_TEMPLATE=>TY_ROOT.
   DATA lv_bo_node_name TYPE STRING value 'ROOT'.
   DATA in_bo_proxy_name TYPE string value 'SITE_LOGISTICS_TASK'.
   DATA lt_modifications TYPE  sesf_access_modify_tab.
   DATA ls_modifications TYPE sesf_access_modify.
   DATA lt_selection_parameter    TYPE sesf_selection_parameters_tab.
   DATA ls_selection_parameter    TYPE sesf_selection_parameter.
   DATA lt_out_change_notifications TYPE  if_esf_types=>ty_change_notifications.
   DATA ls_out_change_notifications LIKE LINE OF lt_out_change_notifications-SUC_CREATE_NOTIFICATIONS.
   DATa out_message TYPE IF_ESF_TYPES=>TY_MESSAGES.
   DATA lt_node_id TYPE SESF_BO_NODE_ID_TAB.
   DATA lr_object TYPE REF TO CM_ESI_ROOT.
   DATA lv_error TYPE string.

   CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
          RECEIVING
            out_lcp_facade = lo_facade.
   lo_lcp_transaction = cl_esf_lcp_factory=>get_lcp_transaction_handler( ).
   TRY.
       lo_lcp = lo_lcp_transaction->if_esf_lcp_facade~get_lcp( in_bo_proxy_name ).
*
       CATCH cx_esf_core_service.
*
   ENDTRY.

   CLEAR lt_selection_parameter.
   CLEAR ls_selection_parameter.
   CLEAR lt_node_id.
   ls_selection_parameter-sign = 'I'.
   ls_selection_parameter-option = 'EQ'.
   ls_selection_parameter-low = '23'.
   ls_selection_parameter-attribute_name = 'ID-CONTENT'.
   APPEND ls_selection_parameter TO lt_selection_parameter.

    CALL METHOD lo_lcp->query
      EXPORTING
        in_bo_node_name         = 'ROOT'
        in_query_name           = 'QUERY_BY_ELEMENTS'
        in_selection_parameters = lt_selection_parameter
        in_fill_data            = 'X'
      IMPORTING
        out_data                = lt_data
        out_node_ids            = lt_node_id.
   READ TABLE lt_data INTO ls_data INDEX 1.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.

   GET REFERENCE OF ls_data INTO ls_node_container.
   CLEAR: ls_modifications, lt_modifications.
   ls_modifications-bo_node_name =  lv_bo_node_name.
   ls_modifications-node_id = ls_data-node_id..
   ls_modifications-change_mode = 'U'.
   ls_node_container->EARLIEST_EXECUTION_PERIOD-START_DATE_TIME = '20081001025947'.
   ls_modifications-data = ls_node_container.

   APPEND 'EARLIEST_EXECUTION_PERIOD-START_DATE_TIME' TO ls_modifications-changed_attributes.

   ls_modifications-association_name = ''.
   ls_modifications-source_bo_node_name = ''.
   ls_modifications-source_node_id = ''.
   ls_modifications-source_node_id_is_handle = ''.
   APPEND ls_modifications TO lt_modifications.
   TRY.
   CALL METHOD lo_lcp->modify
       EXPORTING
           in_modifications         = lt_modifications
       IMPORTING
           out_messages             = out_message
           out_change_notifications = lt_out_change_notifications.
   CATCH cx_esf_core_service.

   ENDTRY.

       TRY.
        CALL METHOD lo_lcp_transaction->save_transaction
          IMPORTING
            out_rejected = lv_out_rejected.

        IF lv_out_rejected = abap_true.
          WRITE 'Saving failed --> left program '.
          EXIT.
        ENDIF.

      CATCH cx_esf_core_service INTO lx_core_excep.
        lv_text = lx_core_excep->get_text( ).
        WRITE: / lv_text.
        WRITE 'Saving failed --> left program '.
        EXIT.
    ENDTRY.

   write: 'ok'.