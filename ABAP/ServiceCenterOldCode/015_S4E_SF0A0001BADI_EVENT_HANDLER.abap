class name:SF0A0001/BADI_EVENT_HANDLER
backup date: 2009-04-02

class /SF0A0001/BADI_EVENT_HANDLER definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/BADI_EVENT_HANDLER
*"* do not include other source files here!!!

  data LV_DUMMY type I .

  methods HANDLE_EVENT
    importing
      !IM_BADI_NAME type ENH_BADI_IMPL .
  methods ON_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .

private section.
*"* private components of class /SF0A0001/BADI_EVENT_HANDLER
*"* do not include other source files here!!!

  data LV_TEST type I .

  methods GET_USER_INPUT
    importing
      !IM_BADI_NAME type ENH_BADI_IMPL
    exporting
      !EX_ANSWER type C .
  methods DEACTIVE_BADI
    importing
      !IM_BADI_NAME type ENHNAME
    exporting
      !EX_TR_NO type TRKORR
      !EX_TOOL_REF type ref to CL_ENH_TOOL_BADI_IMPL .
  type-pools ABAP .
  methods GET_BADI_BY_ROW
    importing
      !IM_ROW type SALV_DE_ROW
    exporting
      !EX_NAME type ENH_BADI_IMPL
      !EX_ACTIVE type ABAP_BOOL .
  methods SAVE_AND_RELEASE
    importing
      !IM_TR_NO type TRKORR
      !IM_BADI_REF type ref to CL_ENH_TOOL_BADI_IMPL .

method HANDLE_EVENT.
  DATA: lv_tr_no TYPE TRKORR,
        lo_badi_tool TYPE REF TO cl_enh_tool_badi_impl.
  CALL METHOD me->DEACTIVE_BADI
      EXPORTING
        im_badi_name = im_badi_name
      IMPORTING
        ex_tr_no = lv_tr_no
        ex_tool_ref = lo_badi_tool.

  CALL METHOD me->save_and_release
      EXPORTING
        im_tr_no = lv_tr_no
        im_badi_ref = lo_badi_tool.
endmethod.

method ON_DOUBLE_CLICK.
  DATA lv_badi_name TYPE ENH_BADI_IMPL.
  DATA lv_active TYPE abap_bool.
  DATA lv_message TYPE string.
  DATA lv_input TYPE c.
  CALL METHOD me->get_badi_by_row
    EXPORTING
      im_row = row
    IMPORTING
      ex_name = lv_badi_name
      ex_active = lv_active.
  IF lv_active = abap_false.
     lv_message = 'Badi: ' && lv_badi_name && ' is already deactive!'.
     MESSAGE lv_message TYPE 'E'.
     RETURN.
  ENDIF.

  CALL METHOD me->get_user_input
    EXPORTING
      im_badi_name = lv_badi_name
    IMPORTING
      ex_answer = lv_input.

  IF lv_input <> '1'.
     RETURN.
  ENDIF.

  CALL METHOD me->handle_event
    EXPORTING
       im_badi_name = lv_badi_name.
endmethod.

method DEACTIVE_BADI.
  DATA: lo_enh_impl TYPE REF TO if_enh_tool,
        lo_badi_impl_tool TYPE REF TO cl_enh_tool_badi_impl,
        ls_data TYPE ENH_BADI_IMPL_DATA,
        lt_data TYPE ENH_BADI_IMPL_DATA_IT,
        lv_description TYPE string,
        lv_tr_desc TYPE AS4TEXT,
        lv_error TYPE string,
        lo_lock_exception TYPE REF TO CX_ENH_IS_LOCKED.

  TRY.
    lo_enh_impl = cl_enh_factory=>get_enhancement(
          lock                   = abap_true
          enhancement_id         = im_badi_name ).
    CATCH CX_ENH_IS_LOCKED INTO lo_lock_exception.
       lv_error = lo_lock_exception->get_text( ).
       MESSAGE lv_error TYPE 'E'.
    ENDTRY.
    lo_badi_impl_tool ?= lo_enh_impl.

  CALL METHOD lo_badi_impl_tool->get_implementation
     EXPORTING
       IMPL_NAME = im_badi_name
     RECEIVING
       RE_IMPLEMENTATION = ls_data.

  ls_data-active = ''.
  APPEND ls_data TO lt_data.

  CALL METHOD lo_badi_impl_tool->DELETE_IMPLEMENTATION
     EXPORTING
       IMPL_NAME = im_badi_name.

  CALL METHOD lo_badi_impl_tool->ADD_IMPLEMENTATION
     EXPORTING
       IM_IMPLEMENTATION = ls_data.

  lv_description = text-001 && im_badi_name.
  lv_tr_desc = lv_description.
  CALL METHOD /SF0A0001/BADI_TR_TOOL=>CREATE_TR
     EXPORTING
       IM_TR_DESC = lv_tr_desc
       IM_TR_TYPE = 'K'
       IM_TR_TARGET = '/SS4E_GRP/'
     IMPORTING
       EX_TR_NO = ex_tr_no.
  ex_tool_ref = lo_badi_impl_tool.
endmethod.

method GET_BADI_BY_ROW.
  CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>GET_BADI_BY_ROW
     EXPORTING
       im_row = im_row
     IMPORTING
       ex_name = ex_name
       ex_active = ex_active.
endmethod.

method GET_USER_INPUT.
  DATA lv_question TYPE string.
  lv_question = 'Do you Really Want To Deactive Badi: ' && im_badi_name && ' ?'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
       titlebar                    = 'Badi Activation Dialog'
       text_question               = lv_question
       text_button_1               = 'Yes'
       text_button_2               = 'No'
       display_cancel_button       = 'X'
       start_column                = 25
       start_row                   = 6
    IMPORTING
       answer                      = ex_answer.
endmethod.

method SAVE_AND_RELEASE.

  DATA: lv_wb_tr TYPE trkorr,
        lv_dev_tr TYPE trkorr,
        lo_cancel TYPE REF TO CX_ENH_CANCELED,
        lv_error TYPE string.

  lv_wb_tr = im_tr_no.
  lv_dev_tr = im_tr_no.
  TRY.
    CALL METHOD im_badi_ref->IF_ENH_OBJECT~SAVE
      CHANGING
        TRKORR = lv_dev_tr.
    CATCH CX_ENH_CANCELED INTO lo_cancel.
      lv_error = lo_cancel->get_text( ).
      MESSAGE lv_error TYPE 'E'.
  ENDTRY.

  im_badi_ref->IF_ENH_OBJECT~ACTIVATE( ).

  im_badi_ref->if_enh_object~generate( ).

  im_badi_ref->if_enh_object~unlock( ).

  CALL METHOD /SF0A0001/BADI_TR_TOOL=>RELEASE_TR
     EXPORTING
       im_tr_no = lv_dev_tr.

  CALL METHOD /SF0A0001/BADI_TR_TOOL=>RELEASE_TR
     EXPORTING
       im_tr_no = lv_wb_tr.
endmethod.