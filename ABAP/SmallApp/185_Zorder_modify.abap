REPORT zorder_modify.

DATA: lt_exception     TYPE crmt_exception_t,
      ls_exception     LIKE LINE OF lt_exception,
      lt_header        TYPE crmt_orderadm_h_comt,
      lt_saved_object  TYPE crmt_return_objects,
      lt_save_failed   TYPE crmt_object_guid_tab,
      lt_to_be_save    TYPE crmt_object_guid_tab,
      lt_changed_input TYPE crmt_input_field_tab,
      ls_changed_input LIKE LINE OF lt_changed_input,
      ls_header        LIKE LINE OF lt_header,
      lv_object_id     TYPE crmd_orderadm_h-object_id.

SELECTION-SCREEN BEGIN OF BLOCK b1
  WITH FRAME TITLE txt1.
SELECT-OPTIONS: orderid  FOR lv_object_id DEFAULT '8000000110' OBLIGATORY.
PARAMETERS: txt    TYPE char20 DEFAULT 'new description'.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  txt1 = 'Specify Service order ID and new description to be changed.'.

START-OF-SELECTION.

  PERFORM get_guid_by_id.
  PERFORM fill_header_tab.

  CALL FUNCTION 'CRM_ORDER_MAINTAIN'
    IMPORTING
      et_exception      = lt_exception
    CHANGING
      ct_orderadm_h     = lt_header
      ct_input_fields   = lt_changed_input
    EXCEPTIONS
      error_occurred    = 1
      document_locked   = 2
      no_change_allowed = 3
      no_authority      = 4
      OTHERS            = 5.

  IF sy-subrc <> 0 OR lt_exception IS NOT INITIAL.
    WRITE: / 'Modify API call failed.' COLOR COL_NEGATIVE.
    LOOP AT lt_exception INTO ls_exception.
      WRITE: / ls_exception-code COLOR COL_GROUP.
    ENDLOOP.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CRM_ORDER_SAVE'
    EXPORTING
      it_objects_to_save   = lt_to_be_save
    IMPORTING
      et_saved_objects     = lt_saved_object
      et_exception         = lt_exception
      et_objects_not_saved = lt_save_failed
    EXCEPTIONS
      document_not_saved   = 1.

  IF sy-subrc <> 0 OR lt_exception IS NOT INITIAL OR lt_save_failed IS NOT INITIAL.
    WRITE: / 'Save API call failed.' COLOR COL_NEGATIVE.
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.
  WRITE: / 'order saved'.

FORM get_guid_by_id.
  DATA: lt_temp TYPE STANDARD TABLE OF crmd_orderadm_h.
  FIELD-SYMBOLS:<line> TYPE crmd_orderadm_h.

  SELECT guid INTO CORRESPONDING FIELDS OF TABLE lt_temp FROM crmd_orderadm_h WHERE object_id IN orderid.
  LOOP AT lt_temp ASSIGNING <line>.
    APPEND <line>-guid TO lt_to_be_save.
  ENDLOOP.
ENDFORM.

FORM fill_header_tab.

  FIELD-SYMBOLS: <guid_line> LIKE LINE OF lt_to_be_save.
  LOOP AT lt_to_be_save ASSIGNING <guid_line>.
    ls_header-guid = <guid_line>.
    ls_header-description = txt.
    APPEND ls_header TO lt_header.

    ls_changed_input-ref_guid = <guid_line>.
    ls_changed_input-objectname = 'ORDERADM_H'.
    APPEND 'DESCRIPTION' TO ls_changed_input-field_names.
    APPEND ls_changed_input TO lt_changed_input.
  ENDLOOP.
ENDFORM.