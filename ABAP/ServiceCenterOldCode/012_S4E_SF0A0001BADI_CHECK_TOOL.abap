class name:SF0A0001BADI_CHECK_TOOL
backup date: 2009-04-02

class /SF0A0001/BADI_CHECK_TOOL definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/BADI_CHECK_TOOL
*"* do not include other source files here!!!

  types:
    BEGIN OF ty_badi_info,
         badi_impl TYPE ENH_BADI_IMPL,
         author TYPE RESPONSIBL,
         component TYPE DLVUNIT,
         active TYPE c LENGTH 1,
       END OF ty_badi_info .
  types:
    tt_badi_info TYPE STANDARD TABLE OF ty_badi_info .

  class-data LV_TEST type STRING .

  class-methods CHECK_MULTIPLE_EXIST
    importing
      !IM_BADI_NAME type ENHNAME .
  class-methods DISPLAY_ALV .
  type-pools ABAP .
  class-methods GET_BADI_BY_ROW
    importing
      !IM_ROW type SALV_DE_ROW
    exporting
      !EX_NAME type ENH_BADI_IMPL
      !EX_ACTIVE type ABAP_BOOL .
  class-methods GET_BADI_INTERFACE
    importing
      !IM_ERROR_EXIT type ABAP_BOOL
      !IM_BADI_NAME type ENHNAME
    exporting
      !EX_INTERFACE type ENHCHARBADIFILTER .
  class-methods LIST_BADI
    importing
      !IM_INTERFACE type ENHSTRING .
  class-methods GET_BADI_INFO
    importing
      !IM_ERROR_EXIT type ABAP_BOOL
      !IM_BADI_NAME type ENHNAME
    exporting
      !EX_BADI_INFO type ENH_BADI_IMPL_DATA .

private section.
*"* private components of class /SF0A0001/BADI_CHECK_TOOL
*"* do not include other source files here!!!

  class-data LT_BADI_INFO type TT_BADI_INFO .

  class-methods GET_FILTER_VALUE
    importing
      !IM_IMPLEMENTATION type ENH_BADI_IMPL_DATA
    exporting
      !EX_FILTER type ENHCHARBADIFILTER .

method CHECK_MULTIPLE_EXIST.
  DATA: lv_filter_name TYPE ENHCHARBADIFILTER,
        lv_other_filter_name TYPE ENHCHARBADIFILTER,
        lv_error TYPE string,
        lt_badi_table TYPE TABLE OF BADIIMPL_ENH,
        lt_dev_info TYPE TABLE OF TADIR,
        ls_dev_info TYPE TADIR,
        ls_badi_item TYPE BADIIMPL_ENH,
        ls_conflict_info TYPE ty_badi_info.

  CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>GET_BADI_INTERFACE
     EXPORTING
        im_error_exit = abap_true
        im_badi_name = im_badi_name
     IMPORTING
        ex_interface = lv_filter_name.

  IF lv_filter_name IS INITIAL.
     lv_error = 'Cannot find Service Interface for Badi: ' && im_badi_name.
     MESSAGE lv_error TYPE 'E'.
     EXIT.
  ENDIF.

  SELECT ENHNAME ACTIVE FROM BADIIMPL_ENH INTO CORRESPONDING FIELDS OF TABLE lt_badi_table WHERE ENHNAME LIKE '/SFA%'." AND ACTIVE = 'X'.

  LOOP AT lt_badi_table INTO ls_badi_item.
    CHECK ls_badi_item-enhname <> im_badi_name.
    CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>GET_BADI_INTERFACE
       EXPORTING
         im_error_exit = abap_false
         im_badi_name = ls_badi_item-enhname
       IMPORTING
         ex_interface = lv_other_filter_name.

    CHECK lv_other_filter_name = lv_filter_name.
    SELECT AUTHOR COMPONENT INTO CORRESPONDING FIELDS OF TABLE lt_dev_info FROM TADIR WHERE PGMID = 'R3TR' AND OBJECT = 'ENHO' AND OBJ_NAME = ls_badi_item-enhname.
    READ TABLE lt_dev_info INTO ls_dev_info INDEX 1.

    CLEAR ls_conflict_info.
    ls_conflict_info-badi_impl =  ls_badi_item-enhname.
    ls_conflict_info-author = ls_dev_info-author.
    ls_conflict_info-component = ls_dev_info-component.
    ls_conflict_info-active = ls_badi_item-active.
    APPEND ls_conflict_info TO lt_badi_info.
ENDLOOP.

  /SF0A0001/BADI_CHECK_TOOL=>DISPLAY_ALV( ).
endmethod.

method DISPLAY_ALV.
  DATA: gr_alv TYPE REF TO cl_salv_table,
        column_table TYPE REF TO CL_SALV_COLUMNS_TABLE,
        column TYPE REF TO CL_SALV_COLUMN,
        gr_events TYPE REF TO cl_salv_events_table,
        gr_selections TYPE REF TO cl_salv_selections,
        lo_event_handler TYPE REF TO /SF0A0001/BADI_EVENT_HANDLER.

  IF lt_badi_info IS INITIAL.
     EXIT.
  ENDIF.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table   = gr_alv
    CHANGING
      t_table        = lt_badi_info.

  gr_events = gr_alv->get_event( ).
  CREATE OBJECT lo_event_handler.
  SET HANDLER lo_event_handler->on_double_click FOR gr_events.

  " Set up selections.
  gr_selections = gr_alv->get_selections( ).
  gr_selections->set_selection_mode( 1 ). "Single
  " Display
  column_table = gr_alv->GET_COLUMNS( ).


  column = column_table->GET_COLUMN( COLUMNNAME = 'BADI_IMPL' ).
  column->SET_MEDIUM_TEXT( 'Implementation Name' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 40 ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'AUTHOR' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 30 ).
  column->SET_MEDIUM_TEXT( 'Author' ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'COMPONENT' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 30 ).
  column->SET_MEDIUM_TEXT( 'Software Component' ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'ACTIVE' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 10 ).
  column->SET_MEDIUM_TEXT( 'Active Or Not' ).

  CALL METHOD gr_alv->display.
endmethod.

method GET_BADI_BY_ROW.
  DATA ls_entry TYPE ty_badi_info.
  IF im_row <= 0.
     EXIT.
  ENDIF.
  READ TABLE lt_badi_info into ls_entry INDEX im_row.
  IF sy-subrc = 0.
     ex_name = ls_entry-badi_impl.
     ex_active = ls_entry-active.
  ENDIF.
endmethod.

method GET_BADI_INFO.
  DATA: lo_enh_impl TYPE REF TO if_enh_tool,
        lo_badi_impl_tool TYPE REF TO cl_enh_tool_badi_impl,
        lx_badi_impl_error TYPE REF TO CX_ENH_BADI_IMPL_NOT_VALID,
        lx_io_error TYPE REF TO CX_ENH_IO_ERROR,
        lv_error TYPE string.

  TRY.
    lo_enh_impl = cl_enh_factory=>get_enhancement(
          enhancement_id         = im_badi_name ).
    CATCH CX_ENH_IO_ERROR into lx_io_error.
       lv_error = lx_io_error->get_text( ).
       IF im_error_exit = abap_true.
          MESSAGE lv_error TYPE 'E'.
          EXIT.
       ENDIF.
  ENDTRY.

  lo_badi_impl_tool ?= lo_enh_impl.
  TRY.
     CALL METHOD lo_badi_impl_tool->GET_IMPLEMENTATION
     EXPORTING
       IMPL_NAME         = im_badi_name
     RECEIVING
       RE_IMPLEMENTATION = ex_badi_info.
  CATCH CX_ENH_BADI_IMPL_NOT_VALID into lx_badi_impl_error.
    lv_error = lx_badi_impl_error->get_text( ).
    IF im_error_exit = abap_true.
       MESSAGE lv_error TYPE 'E'.
          EXIT.
       ENDIF.
  ENDTRY.
endmethod.

method GET_BADI_INTERFACE.

  DATA ls_impl_data TYPE ENH_BADI_IMPL_DATA.
  CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>GET_BADI_INFO
    EXPORTING
       im_error_exit = im_error_exit
       im_badi_name = im_badi_name
    IMPORTING
       ex_badi_info = ls_impl_data.

  CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>GET_FILTER_VALUE
    EXPORTING
       im_implementation = ls_impl_data
    IMPORTING
       ex_filter = ex_interface.
endmethod.

method LIST_BADI.
  DATA: lv_filter_name TYPE ENHCHARBADIFILTER,
        lv_other_filter_name TYPE ENHCHARBADIFILTER,
        lv_error TYPE string,
        lt_badi_table TYPE TABLE OF BADIIMPL_ENH,
        lt_dev_info TYPE TABLE OF TADIR,
        ls_dev_info TYPE TADIR,
        ls_badi_item TYPE BADIIMPL_ENH,
        ls_conflict_info TYPE ty_badi_info.

  SELECT ENHNAME ACTIVE FROM BADIIMPL_ENH INTO CORRESPONDING FIELDS OF TABLE lt_badi_table WHERE ENHNAME LIKE '/SFA%'.

  LOOP AT lt_badi_table INTO ls_badi_item.
    CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>GET_BADI_INTERFACE
       EXPORTING
         im_error_exit = abap_false
         im_badi_name = ls_badi_item-enhname
       IMPORTING
         ex_interface = lv_other_filter_name.

    CHECK lv_other_filter_name = im_interface.
    SELECT AUTHOR COMPONENT INTO CORRESPONDING FIELDS OF TABLE lt_dev_info FROM TADIR WHERE PGMID = 'R3TR' AND OBJECT = 'ENHO' AND OBJ_NAME = ls_badi_item-enhname.
    READ TABLE lt_dev_info INTO ls_dev_info INDEX 1.

    CLEAR ls_conflict_info.
    ls_conflict_info-badi_impl =  ls_badi_item-enhname.
    ls_conflict_info-author = ls_dev_info-author.
    ls_conflict_info-component = ls_dev_info-component.
    ls_conflict_info-active = ls_badi_item-active.
    APPEND ls_conflict_info TO lt_badi_info.
ENDLOOP.

  /SF0A0001/BADI_CHECK_TOOL=>DISPLAY_ALV( ).
endmethod.

method GET_FILTER_VALUE.
  DATA: ls_filter TYPE ENH_BADIIMPL_FILTER_VALUE.
  READ TABLE im_implementation-filter_values INTO ls_filter INDEX 1.
  ex_filter = ls_filter-FILTER_STRING_VALUE1.
endmethod.

