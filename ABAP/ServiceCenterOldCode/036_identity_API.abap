*&---------------------------------------------------------------------*
*& Report  Z_USER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_USER1.
  TYPES: BEGIN OF f4list_s,
            id TYPE apc_c_btd_id,
            user TYPE apc_c_user_account_id,
            date TYPE char14,
            node_id TYPE sesf_bo_node_id,
         END OF f4list_s.

  DATA: lt_node_id TYPE sesf_bo_node_id_tab,
        lt_data   TYPE if_apleo_bo_service_provider=>tt_root,
        ls_data   TYPE if_apleo_bo_service_provider=>ty_root,
        ls_f4list TYPE f4list_s,
        lt_f4list TYPE TABLE OF f4list_s,
        ls_query_options  TYPE  sesf_query_options,
        lo_lcp    TYPE REF TO if_esf_lcp,
        lv_date TYPE char24,
        ls_identity TYPE  suid_st_identity,
        MO_FACADE TYPE REF TO IF_ESF_LCP_FACADE,
        lv_suid_uuid  TYPE suid_uuid.

  IF NOT ( mo_facade IS BOUND ).
    CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
      RECEIVING
        out_lcp_facade = mo_facade.
  ENDIF.
  TRY.
      lo_lcp =  mo_facade->get_lcp( 'PRODUCTION_ORDER' ).
      ls_query_options-maximum_rows = '20'.
      CALL METHOD lo_lcp->query
        EXPORTING
          in_bo_node_name  = 'ROOT'
          in_query_name    = 'SELECT_ALL'
          in_fill_data     = abap_true
          in_query_options = ls_query_options
        IMPORTING
          out_node_ids     = lt_node_id
          out_data         = lt_data.
      CALL METHOD lo_lcp->retrieve
        EXPORTING
          in_bo_node_name = 'ROOT'
          in_node_ids     = lt_node_id
        IMPORTING
          out_data        = lt_data.
    CATCH cx_esf_core_service .
  ENDTRY.

  LOOP AT lt_data INTO ls_data.
    CLEAR: ls_f4list.
    ls_f4list-node_id = ls_data-node_id.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_data-id-content
      IMPORTING
        output = ls_f4list-id.
    lv_date = ls_data-system_administrative_data-creation_date_time.
    ls_f4list-date = lv_date+1(14).
    IF NOT ( ls_data-system_administrative_data-creation_identity_uuid IS INITIAL ).
      cl_gdt_conversion=>guid_outbound( EXPORTING im_guid_x = ls_data-system_administrative_data-creation_identity_uuid-content
                                       IMPORTING ex_value = lv_suid_uuid ).
      TRY.
          CALL METHOD cl_identity_factory=>query_identity_by_uuid
            EXPORTING
              iv_identity_uuid = lv_suid_uuid
            IMPORTING
              es_identity      = ls_identity.
        CATCH cx_suid_identity .
      ENDTRY.
    ENDIF.
    WRITE : 'NAME: ', LS_IDENTITY-BNAME.
    new-line.
  ENDLOOP.