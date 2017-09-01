*&---------------------------------------------------------------------*
*& Report  Z_ANNIE_TEST_CONVERT_KEY
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_ANNIE_TEST_CONVERT_KEY.


DATA: lo_lcp_transaction_handler TYPE REF TO if_esf_lcp_transaction,
      lo_lcp TYPE REF TO if_esf_lcp,

      ls_opportunity_id type if_apcrm_opportunity=>ty_key-root-id,
      lt_opportunity_ids type if_apcrm_opportunity=>tt_key-root-id,
      lt_opportunity_key_mapping type sesf_access_key_mapping_tab.



TRY.
    lo_lcp_transaction_handler = cl_esf_lcp_factory=>get_lcp_transaction_handler(
           ).
  CATCH cx_esf_core_service .
ENDTRY.
TRY.
    lo_lcp = lo_lcp_transaction_handler->if_esf_lcp_facade~get_lcp( in_bo_name = if_apcrm_opportunity=>co_bo_name ).
  CATCH cx_esf_core_service .
ENDTRY.

    ls_opportunity_id-content = '6'.
    APPEND ls_opportunity_id TO lt_opportunity_ids.
    ls_opportunity_id-content = '4'.
    APPEND ls_opportunity_id TO lt_opportunity_ids.

    TRY.
        lo_lcp->convert_key_to_node_id(
          EXPORTING
            in_bo_node_name    = if_apcrm_opportunity=>co_bo_node-root
            in_key_name        = if_apcrm_opportunity=>co_key-root-id
            in_keys            = lt_opportunity_ids
*    in_requested_image = IF_ESF_TYPES=>CO_IMAGE_TRANSACTIONAL_BUFFER
          IMPORTING
            out_key_mapping    = lt_opportunity_key_mapping
               ).
      CATCH cx_esf_core_service.
    ENDTRY.