*&---------------------------------------------------------------------*
*& Report ZAPPOINTMENT_ADD_OPP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zappointment_overwrite_opp.

PARAMETERS: oppid   TYPE crmd_orderadm_h-object_id OBLIGATORY DEFAULT '1424',
            opptype TYPE crmd_orderadm_h-process_type OBLIGATORY DEFAULT 'OPPT'.

INCLUDE: crm_object_names_con,
            crm_object_types_con,
            crm_object_kinds_con,
            crm_mode_con.

DATA: ls_docflow        TYPE crmt_doc_flow_com,
      ct_doc_flow       TYPE crmt_doc_flow_comt,
      ls_link           TYPE LINE OF crmt_doc_flow_extdt,
      lv_opp_guid       TYPE crmd_orderadm_h-guid,
      lv_app_guid       LIKE lv_opp_guid,
      ct_input_fields   TYPE crmt_input_field_tab,
      cs_input          LIKE LINE OF ct_input_fields,
      cs_field          LIKE LINE OF cs_input-field_names,
      lv_opp_id         TYPE crmd_orderadm_h-object_id,
      lv_opp_type       TYPE crmd_orderadm_h-process_type,
      lt_save           TYPE crmt_object_guid_tab,
      lt_not_saved      LIKE lt_save,
      lt_header         TYPE crmt_object_guid_tab,
      lt_doc_flow       TYPE crmt_doc_flow_wrkt,
      ls_doc_flow       LIKE LINE OF lt_doc_flow,
      lt_save_exception TYPE crmt_exception_t,
      lt_exception      TYPE crmt_exception_t.

START-OF-SELECTION.
* Jerry comment: replace this appointment guid with your own one.
* One relation will be created. Relation source: the appointment of this guid
*   Relation target: the opportunity specified in this report
*
  lv_app_guid = '3440B5B172DE1ED590B1C3A05B175D6A'.
  PERFORM delete_existing_rel USING lv_app_guid.
  PERFORM add_new_rel USING lv_app_guid.

FORM add_new_rel USING iv_opp_guid TYPE crmd_orderadm_h-guid.
  lv_opp_id = oppid.
  lv_opp_type = opptype.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_opp_id
    IMPORTING
      output = lv_opp_id.

  SELECT SINGLE guid INTO lv_opp_guid FROM crmd_orderadm_h
    WHERE object_id EQ lv_opp_id AND process_type = lv_opp_type.
  ASSERT sy-subrc = 0.

  CLEAR: ls_docflow, ls_link, ct_doc_flow,ct_input_fields.
  ls_docflow-ref_kind = 'A'.
  ls_docflow-ref_guid = lv_app_guid.

  ls_link-objkey_a        = lv_opp_guid.
  ls_link-objtype_a       = gc_object_type-opportunity."'BUS2000111'.

  ls_link-objkey_b        = lv_app_guid.
  ls_link-objtype_b       = gc_object_type-businessactivity. "'BUS2000126'.
  ls_link-brel_kind       = 'A'.
  ls_link-brel_mode       = 'A'.
  ls_link-reltype         = 'VONA'.

  APPEND ls_link TO ls_docflow-doc_link.

  INSERT ls_docflow INTO TABLE ct_doc_flow.

  CLEAR: cs_input-field_names.
  cs_field = 'OBJKEY_A'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_field-fieldname = 'OBJTYPE_A'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_field-fieldname = 'OBJKEY_B'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_field-fieldname = 'OBJTYPE_B'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_field-fieldname = 'BREL_KIND'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_field-fieldname = 'RELTYPE'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_field-fieldname = 'RELATIONID'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_input-ref_guid    = lv_app_guid.
  cs_input-ref_kind    = gc_object_ref_kind-orderadm_h.
  cs_input-objectname  = gc_object_name-doc_flow.
  INSERT cs_input INTO TABLE ct_input_fields.

  CALL FUNCTION 'CRM_ORDER_MAINTAIN'
    IMPORTING
      et_exception      = lt_exception
    CHANGING
      ct_input_fields   = ct_input_fields
      ct_doc_flow       = ct_doc_flow
    EXCEPTIONS
      error_occurred    = 1
      document_locked   = 2
      no_change_allowed = 3
      no_authority      = 4.

  WRITE: / sy-subrc.

  APPEND lv_app_guid TO lt_save.

  CALL FUNCTION 'CRM_ORDER_SAVE'
    EXPORTING
      it_objects_to_save   = lt_save
    IMPORTING
      et_objects_not_saved = lt_not_saved
      et_exception         = lt_save_exception
    EXCEPTIONS
      document_not_saved   = 1.

  WRITE: / sy-subrc.

  COMMIT WORK AND WAIT.
ENDFORM.


FORM delete_existing_rel USING iv_app_guid TYPE crmd_orderadm_h-guid.

  APPEND iv_app_guid TO lt_header.

  CALL FUNCTION 'CRM_ORDER_READ'
    EXPORTING
      it_header_guid = lt_header
    IMPORTING
      et_doc_flow    = lt_doc_flow.

  IF lt_doc_flow IS INITIAL.
    WRITE: / 'no relation to delete.'.
    RETURN.
  ENDIF.

  ls_docflow-ref_kind = 'A'.
  ls_docflow-ref_guid = iv_app_guid.

* Jerry comment: for test purpose, one appointment has only one relationship of Opportunity,
* thus use INDEX 1
  READ TABLE lt_doc_flow INTO ls_doc_flow INDEX 1.
  ls_link-objkey_a        = ls_doc_flow-objkey_a.
  ls_link-objtype_a       = gc_object_type-opportunity."'BUS2000111'.

  ls_link-objkey_b        = ls_doc_flow-objkey_b.
  ls_link-objtype_b       = gc_object_type-businessactivity. "'BUS2000126'.
  ls_link-brel_kind       = 'A'.
  ls_link-brel_mode       = 'D'. " deletion
* Jerry: this line below is essential!! It points out which exactly relation should be deleted
  ls_link-relationid      = ls_doc_flow-relationid.
  ls_link-reltype         = 'VONA'.

  APPEND ls_link TO ls_docflow-doc_link.

  INSERT ls_docflow INTO TABLE ct_doc_flow.

  CLEAR: cs_input-field_names.
  cs_field = 'DOC_LINK'.
  INSERT cs_field INTO TABLE cs_input-field_names.

  cs_input-ref_guid    = lv_app_guid.
  cs_input-ref_kind    = gc_object_ref_kind-orderadm_h.
  cs_input-objectname  = gc_object_name-doc_flow.
  INSERT cs_input INTO TABLE ct_input_fields.

  CALL FUNCTION 'CRM_ORDER_MAINTAIN'
    IMPORTING
      et_exception      = lt_exception
    CHANGING
      ct_input_fields   = ct_input_fields
      ct_doc_flow       = ct_doc_flow
    EXCEPTIONS
      error_occurred    = 1
      document_locked   = 2
      no_change_allowed = 3
      no_authority      = 4.

  ASSERT sy-subrc = 0.
ENDFORM.