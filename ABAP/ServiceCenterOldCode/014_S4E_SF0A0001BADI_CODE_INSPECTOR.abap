class name:SF0A0001BADI_CODE_INSPECTOR
backup date: 2009-04-02

class /SF0A0001/BADI_CODE_INSPECTOR definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/BADI_CODE_INSPECTOR
*"* do not include other source files here!!!

  class-data LV_FOR_COPY type I .

  class-methods FILL_TASK
    importing
      !IN_OUTPUT_REQUEST type C
      !IN_FS_CHECK type C
      !IN_REF_CHECK type C
      !IN_READ_CHECK type C .
  class-methods DISPLAY .
  class-methods RUN
    importing
      !IN_BADI_IMPL_NAME type ENHNAME .

private section.
*"* private components of class /SF0A0001/BADI_CODE_INSPECTOR
*"* do not include other source files here!!!

  types SEOR_IMPLEMENTING_R type VSEOIMPLEM .
  types SEOP_SOURCE_STRING type RSWSOURCET .
  types:
    SEOR_IMPLEMENTINGS_R TYPE STANDARD TABLE OF SEOR_IMPLEMENTING_R
    WITH KEY CLSNAME REFCLSNAME VERSION .
  types:
    BEGIN OF ty_line,
           line_num TYPE i,
           line_text TYPE string,
         END OF ty_line .
  types:
    tt_line TYPE STANDARD TABLE OF ty_line WITH KEY line_num .
  types:
    BEGIN OF ty_error_log,
          class_name TYPE string,
          method_name TYPE string,
          author TYPE string,
          error_type TYPE string,
          error_line TYPE string,
          error_text TYPE string,
          error_description TYPE string,
    END OF ty_error_log .
  types:
    tt_error_log TYPE STANDARD TABLE OF ty_error_log .

  class-data LV_FS_CHECK type C .
  class-data LV_OR_CHECK type C .
  class-data LV_READ_CHECK type C .
  class-data LV_REFER_CHECK type C .
  class-data LV_FIRST_ERROR type I .
  class-data LT_REFERENCE_TAB type STRING_TABLE .
  class-data LT_FIELD_SYMBOL_TAB type STRING_TABLE .
  class-data LV_CURRENT_METHOD type STRING .
  class-data LV_AUTHOR type STRING .
  class-data LV_ERROR_FLAG type I .
  class-data LV_CURRENT_VARIABLE type STRING .
  class-data LT_WORKING_POOL type TT_LINE .
  type-pools SEOP .
  class-data LT_WORKING_SOURCE type SEOP_SOURCE_STRING .
  class-data LV_BADI_IMPL_NAME type STRING .
  class-data LT_ERROR_LOG type TT_ERROR_LOG .

  class-methods CHECK_READ_TABLE .
  class-methods _FIND_SUBRC
    importing
      !IN_CURRENT_LINE type I .
  class-methods CHECK_REFER_VARIABLE .
  class-methods FILL_REFERENCE_TAB
    importing
      !IN_CURRENT_LINE type I .
  class-methods MY_CONDENSE
    importing
      !IN_STRING type STRING
    exporting
      !OUT_STRING type STRING .
  class-methods _FIND_REF_CHECK_STATEMENT
    importing
      !IN_CURRENT_LINE type I .
  class-methods SCAN_REFER_VARIABLE .
  class-methods CHECK_FIELD_SYMBOL .
  class-methods FILL_FIELD_SYMBOL_TAB
    importing
      !IN_CURRENT_LINE type I .
  class-methods _FIND_FS_CHECK_STATEMENT
    importing
      !IN_CURRENT_LINE type I .
  class-methods SCAN_FIELD_SYMBOL .
  class-methods GET_AUTHOR .
  class-methods CHECK_OUTPUT_REQUEST .
  class-methods FETCH_VARIABLE_NAME
    importing
      !IN_STRING_TABLE type STRING_TABLE .
  class-methods _FIND_CHECK_OUTPUT_REQ
    importing
      !IN_CURRENT_LINE type I
      !IN_UPPER_RANGE type I .
  class-methods FIND_UPPER_RANGE
    importing
      !IN_CURRENT_LINE type I
    returning
      value(UPPER_LINE) type I .
  class-methods PACK_STRING_TABLE
    changing
      !C_STRING_TABLE type STRING_TABLE .
  class-methods GET_BADI_INFO
    importing
      !IM_BADI_NAME type ENHNAME .
  class-methods INIT
    importing
      !IN_BADI_IMPL_NAME type ENHNAME .
  class-methods FILL_SOURCE_TABLE .
  class-methods GET_INTERFACE_SOURCE .



method DISPLAY.
  DATA: gr_alv TYPE REF TO cl_salv_table,
        column_table TYPE REF TO CL_SALV_COLUMNS_TABLE,
        column TYPE REF TO CL_SALV_COLUMN,
        gr_selections TYPE REF TO cl_salv_selections.

  IF lt_error_log IS INITIAL.
     MESSAGE I012(/SF0A0001/BADI_INSPE) WITH /SF0A0001/BADI_INTERFACE=>C_OUTPUT_REQUEST.
     RETURN.
  ENDIF.

  SORT lt_error_log BY AUTHOR.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table   = gr_alv
    CHANGING
      t_table        = lt_error_log.

  " Set up selections.
  gr_selections = gr_alv->get_selections( ).
  gr_selections->set_selection_mode( 1 ). "Single
  " Display
  column_table = gr_alv->GET_COLUMNS( ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'CLASS_NAME' ).
  column->SET_MEDIUM_TEXT( 'Badi Class' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 30 ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'METHOD_NAME' ).
  column->SET_MEDIUM_TEXT( 'Method Name' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 30 ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'AUTHOR' ).
  column->SET_MEDIUM_TEXT( 'Author' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 10 ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'ERROR_TYPE' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 4 ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'ERROR_LINE' ).
  column->SET_MEDIUM_TEXT( 'Line' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 4 ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'ERROR_TEXT' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 70 ).
  column->SET_MEDIUM_TEXT( 'Error Source Code' ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'ERROR_DESCRIPTION' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 30 ).
  column->SET_MEDIUM_TEXT( 'Error Description' ).

  CALL METHOD gr_alv->display.
endmethod.

method FILL_TASK.

  IF in_output_request IS INITIAL AND in_fs_check IS INITIAL
     AND in_ref_check IS INITIAL AND in_read_check IS INITIAL.
     MESSAGE e011(/SF0A0001/BADI_INSPE).
  ENDIF.
  lv_OR_CHECK = in_output_request.
  lv_fs_check = in_fs_check.
  lv_refer_check = in_ref_check.
  lv_read_check = in_read_check.


endmethod.

method RUN.
  CALL METHOD /SF0A0001/BADI_CODE_INSPECTOR=>INIT
     EXPORTING
       in_badi_impl_name = in_badi_impl_name.

  CHECK lv_error_flag = 0.

  GET_INTERFACE_SOURCE( ).

  FILL_SOURCE_TABLE( ).

  IF lv_or_check = 'X'.
    CHECK_OUTPUT_REQUEST( ).
  ENDIF.

  IF lv_fs_check = 'X'.
    CHECK_FIELD_SYMBOL( ).
  ENDIF.

  IF lv_refer_check = 'X'.
    CHECK_REFER_VARIABLE( ).
  ENDIF.

  IF lv_read_check = 'X'.
    CHECK_READ_TABLE( ).
  ENDIF.

endmethod.

method CHECK_FIELD_SYMBOL.

  TYPE-POOLS seoo.
  TYPE-POOLS seoc.
  TYPE-POOLS seop.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_upper_range TYPE i,
        lt_method TYPE SEOO_METHODS_R,
        method_key TYPE SEOCPDKEY,
        ls_method LIKE LINE OF lt_method,
        lv_class TYPE SEOCLSKEY.

  lv_class-CLSNAME = lv_badi_impl_name.

  LOOP AT lt_working_pool INTO ls_line_pool.
     line_length = strlen( ls_line_pool-line_text ).
     CHECK line_length > 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_FIELD_SYMBOL IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     fill_field_symbol_tab( EXPORTING in_current_line = ls_line_pool-line_num ).
  ENDLOOP.

  LOOP AT lt_field_symbol_tab INTO lv_current_variable.
    scan_field_symbol( ).
  ENDLOOP.

  CALL FUNCTION 'SEO_METHOD_READ_ALL'
    EXPORTING
       CIFKEY = lv_class
    IMPORTING
       methods = lt_method.

  LOOP AT lt_method INTO ls_method.
    CLEAR: method_key,lt_working_source,lt_field_symbol_tab.
    method_key-CLSNAME = lv_badi_impl_name.
    method_key-CPDNAME = ls_method-CMPname.
    CALL FUNCTION 'SEO_METHOD_GET_SOURCE'
      EXPORTING
        MTDKEY = method_key
      IMPORTING
        SOURCE_expanded = lt_working_source.
    lv_current_method = ls_method-CMPname.
    FILL_SOURCE_TABLE( ).
    LOOP AT lt_working_pool INTO ls_line_pool.
      line_length = strlen( ls_line_pool-line_text ).
      CHECK line_length > 0.
      FIND /SF0A0001/BADI_INTERFACE=>C_FIELD_SYMBOL IN ls_line_pool-line_text.
      CHECK sy-subrc = 0.
      fill_field_symbol_tab( EXPORTING in_current_line = ls_line_pool-line_num ).
    ENDLOOP.

    LOOP AT lt_field_symbol_tab INTO lv_current_variable.
      scan_field_symbol( ).
    ENDLOOP.

  ENDLOOP.
endmethod.

method CHECK_OUTPUT_REQUEST.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_offset TYPE i,
        lv_output_request_call TYPE string,
        lv_upper_range TYPE i.

  LOOP AT lt_working_pool INTO ls_line_pool.
     line_length = strlen( ls_line_pool-line_text ).
     CHECK line_length > 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_OUTPUT_REQUEST IN ls_line_pool-line_text MATCH OFFSET lv_offset.
     IF SY-SUBRC = 0.
       SPLIT ls_line_pool-line_text AT SPACE INTO TABLE lt_string_table.
       CALL METHOD PACK_STRING_TABLE
          CHANGING
             c_string_table = lt_string_table.
       FETCH_VARIABLE_NAME( EXPORTING in_string_table = lt_string_table ).
     ENDIF.

     CHECK lv_current_variable IS NOT INITIAL.
     CONCATENATE lv_current_variable '->' INTO lv_output_request_call.
     FIND lv_output_request_call IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        find_upper_range( EXPORTING in_current_line = ls_line_pool-line_num
           RECEIVING upper_line = lv_upper_range ).
        _find_check_output_req( EXPORTING in_current_line = ls_line_pool-line_num
                                         in_upper_range = lv_upper_range ).
        RETURN.
     ENDIF.

  ENDLOOP.
endmethod.

method CHECK_READ_TABLE.
  TYPE-POOLS seoo.
  TYPE-POOLS seoc.
  TYPE-POOLS seop.

  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_upper_range TYPE i,
        lt_method TYPE SEOO_METHODS_R,
        method_key TYPE SEOCPDKEY,
        ls_method LIKE LINE OF lt_method,
        lv_class TYPE SEOCLSKEY.

  lv_class-CLSNAME = lv_badi_impl_name.

  LOOP AT lt_working_pool INTO ls_line_pool.
     line_length = strlen( ls_line_pool-line_text ).
     CHECK line_length > 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_READ IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_TABLE IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     _find_subrc( EXPORTING in_current_line = ls_line_pool-line_num ).
  ENDLOOP.

  CALL FUNCTION 'SEO_METHOD_READ_ALL'
    EXPORTING
       CIFKEY = lv_class
    IMPORTING
       methods = lt_method.

  LOOP AT lt_method INTO ls_method.
    CLEAR: method_key,lt_working_source,lt_field_symbol_tab.
    method_key-CLSNAME = lv_badi_impl_name.
    method_key-CPDNAME = ls_method-CMPname.
    CALL FUNCTION 'SEO_METHOD_GET_SOURCE'
      EXPORTING
        MTDKEY = method_key
      IMPORTING
        SOURCE_expanded = lt_working_source.
    lv_current_method = ls_method-CMPname.
    FILL_SOURCE_TABLE( ).
    LOOP AT lt_working_pool INTO ls_line_pool.
      line_length = strlen( ls_line_pool-line_text ).
      CHECK line_length > 0.
      FIND /SF0A0001/BADI_INTERFACE=>C_READ IN ls_line_pool-line_text.
      CHECK sy-subrc = 0.
      FIND /SF0A0001/BADI_INTERFACE=>C_TABLE IN ls_line_pool-line_text.
      CHECK sy-subrc = 0.
      _find_subrc( EXPORTING in_current_line = ls_line_pool-line_num ).
    ENDLOOP.

  ENDLOOP.
endmethod.

method CHECK_REFER_VARIABLE.
  TYPE-POOLS seoo.
  TYPE-POOLS seoc.
  TYPE-POOLS seop.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_upper_range TYPE i,
        lt_method TYPE SEOO_METHODS_R,
        method_key TYPE SEOCPDKEY,
        ls_method LIKE LINE OF lt_method,
        lv_class TYPE SEOCLSKEY.

  lv_class-CLSNAME = lv_badi_impl_name.

  LOOP AT lt_working_pool INTO ls_line_pool.
     line_length = strlen( ls_line_pool-line_text ).
     CHECK line_length > 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_REFERENCE IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     fill_reference_tab( EXPORTING in_current_line = ls_line_pool-line_num ).
  ENDLOOP.

  LOOP AT lt_field_symbol_tab INTO lv_current_variable.
    scan_refer_variable( ).
  ENDLOOP.

  CALL FUNCTION 'SEO_METHOD_READ_ALL'
    EXPORTING
       CIFKEY = lv_class
    IMPORTING
       methods = lt_method.

  LOOP AT lt_method INTO ls_method.
    CLEAR: method_key,lt_working_source,lt_reference_tab.
    method_key-CLSNAME = lv_badi_impl_name.
    method_key-CPDNAME = ls_method-CMPname.
    CALL FUNCTION 'SEO_METHOD_GET_SOURCE'
      EXPORTING
        MTDKEY = method_key
      IMPORTING
        SOURCE_expanded = lt_working_source.
    lv_current_method = ls_method-CMPname.
    FILL_SOURCE_TABLE( ).
    LOOP AT lt_working_pool INTO ls_line_pool.
      line_length = strlen( ls_line_pool-line_text ).
      CHECK line_length > 0.
      FIND /SF0A0001/BADI_INTERFACE=>C_REFERENCE IN ls_line_pool-line_text.
      CHECK sy-subrc = 0.
      fill_reference_tab( EXPORTING in_current_line = ls_line_pool-line_num ).
    ENDLOOP.

    LOOP AT lt_reference_tab INTO lv_current_variable.
      scan_refer_variable( ).
    ENDLOOP.

  ENDLOOP.
endmethod.

method FETCH_VARIABLE_NAME.
  DATA: lv_string TYPE string,
        lv_hit TYPE i.

  CLEAR lv_current_variable.
  LOOP AT in_string_table INTO lv_string.
    IF lv_string = /SF0A0001/BADI_INTERFACE=>C_TYPE_DEFINITION.
       lv_hit = sy-tabix - 1.
       IF lv_hit <= 0 OR lv_hit > lines( in_string_table ).
           MESSAGE e001(/SF0A0001/BADI_INSPE) with lv_hit.
       ENDIF.
       READ TABLE in_string_table INTO lv_string INDEX lv_hit.
       CHECK sy-subrc = 0.
       lv_current_variable = lv_string.
    ENDIF.
  ENDLOOP.
  IF lv_current_variable IS INITIAL.
    ASSERT 1 = 0.
    MESSAGE e002(/SF0A0001/BADI_INSPE) WITH /SF0A0001/BADI_INTERFACE=>C_OUTPUT_REQUEST.
  ENDIF.
endmethod.

method FILL_FIELD_SYMBOL_TAB.
DATA:   ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_index TYPE i,
        lv_max_line TYPE i.

lv_max_line = lines( lt_working_pool ).
lv_index = in_current_line.

WHILE lv_index < lv_max_line.
  READ TABLE lt_working_pool INTO ls_line_pool INDEX lv_index.
  FIND /SF0A0001/BADI_INTERFACE=>C_TYPE_DEFINITION IN ls_line_pool-line_text.
  IF sy-subrc <> 0.
     lv_index = lv_index + 1.
     CONTINUE.
  ENDIF.
  SPLIT ls_line_pool-line_text AT SPACE INTO TABLE lt_string_table.
  CALL METHOD PACK_STRING_TABLE
     CHANGING
         c_string_table = lt_string_table.
  FETCH_VARIABLE_NAME( EXPORTING in_string_table = lt_string_table ).
  APPEND lv_current_variable TO lt_field_symbol_tab.
  FIND /SF0A0001/BADI_INTERFACE=>C_END IN ls_line_pool-line_text.
  IF sy-subrc = 0.
     RETURN.
  ENDIF.
  lv_index = lv_index + 1.
ENDWHILE.

MESSAGE e009(/SF0A0001/BADI_INSPE).

endmethod.

method FILL_REFERENCE_TAB.
  DATA:
        ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_formatted TYPE string.


  READ TABLE lt_working_pool INTO ls_line_pool INDEX in_current_line.
  my_condense( EXPORTING in_string = ls_line_pool-line_text IMPORTING out_string = lv_formatted ).
  FIND /SF0A0001/BADI_INTERFACE=>C_REFERENCE_TO IN ls_line_pool-line_text.
  IF sy-subrc <> 0.
     RETURN.
  ENDIF.
  SPLIT ls_line_pool-line_text AT SPACE INTO TABLE lt_string_table.
  CALL METHOD PACK_STRING_TABLE
     CHANGING
         c_string_table = lt_string_table.
  FETCH_VARIABLE_NAME( EXPORTING in_string_table = lt_string_table ).
  APPEND lv_current_variable TO lt_reference_tab.

endmethod.

method FILL_SOURCE_TABLE.
  DATA: ls_source LIKE LINE OF lt_working_source,
        ls_line TYPE TY_LINE.
  CLEAR: lt_working_pool.
  LOOP AT lt_working_source INTO ls_source.
    ls_line-line_num = sy-tabix.
    ls_line-line_text = ls_source.
    TRANSLATE ls_line-line_text TO UPPER CASE.
    APPEND ls_line TO lt_working_pool.
    CLEAR: ls_line.
  ENDLOOP.

endmethod.

method FIND_UPPER_RANGE.
  DATA: ls_line LIKE LINE OF lt_working_pool,
        lv_index TYPE i.
  lv_index = 1.
  WHILE lv_index < in_current_line.
     READ TABLE lt_working_pool INTO ls_line INDEX lv_index.
     FIND /SF0A0001/BADI_INTERFACE=>C_DATA IN ls_line-line_text.
     IF sy-subrc = 0.
        upper_line = ls_line-line_num.
        RETURN.
     ENDIF.
     lv_index = lv_index + 1.
  ENDWHILE.
  IF upper_line IS INITIAL.
     MESSAGE e003(/SF0A0001/BADI_INSPE).
  ENDIF.
endmethod.

method GET_AUTHOR.
  DATA: lt_badi_table TYPE TABLE OF TADIR,
        ls_item TYPE TADIR.
  SELECT AUTHOR FROM TADIR INTO CORRESPONDING FIELDS OF TABLE lt_badi_table
    WHERE PGMID = 'R3TR' AND OBJECT = 'CLAS' AND OBJ_NAME = lv_badi_impl_name.

  READ TABLE lt_badi_table INTO ls_item INDEX 1.
  lv_author = ls_item-author.

endmethod.

method GET_BADI_INFO.
  DATA: lo_enh_impl TYPE REF TO if_enh_tool,
        lo_badi_impl_tool TYPE REF TO cl_enh_tool_badi_impl,
        lx_badi_impl_error TYPE REF TO CX_ENH_BADI_IMPL_NOT_VALID,
        lx_io_error TYPE REF TO CX_ENH_IO_ERROR,
        lv_error TYPE string,
        ex_badi_info TYPE ENH_BADI_IMPL_DATA.

  TRY.
    lo_enh_impl = cl_enh_factory=>get_enhancement(
          enhancement_id         = im_badi_name ).
    CATCH CX_ENH_IO_ERROR into lx_io_error.
       lv_error = lx_io_error->get_text( ).
       lv_error_flag = 1.
       EXIT.
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
    lv_error_flag = 1.
    EXIT.
    "MESSAGE lv_error TYPE 'E'.
  ENDTRY.

  IF ex_badi_info IS INITIAL.
     MESSAGE e004(/SF0A0001/BADI_INSPE) WITH im_badi_name.
  ENDIF.

  lv_badi_impl_name = ex_badi_info-IMPL_CLASS.


endmethod.

method GET_INTERFACE_SOURCE.

 DATA: lv_class TYPE SEOCLSKEY,
       lt_section_source TYPE SEO_SECTION_SOURCE,
       lv_incname TYPE PROGRAM,
       lt_SEOR_IMPLEMENTINGS_R TYPE SEOR_IMPLEMENTINGS_R,
       lt_SEO_REDEFINITIONS TYPE SEO_REDEFINITIONS,
       method_key type SEOCPDKEY.


 lv_class-CLSNAME = lv_badi_impl_name.

 CALL FUNCTION 'SEO_IMPLEMENTG_READ_ALL'
    EXPORTING
       CLSKEY = lv_class
    IMPORTING
       IMPLEMENTINGS = lt_SEOR_IMPLEMENTINGS_R
       IMPL_DETAILS = lt_SEO_REDEFINITIONS.

 IF lt_SEOR_IMPLEMENTINGS_R IS INITIAL.
    ASSERT 1 = 0.
    MESSAGE e000(/SF0A0001/BADI_INSPE) with LV_BADI_IMPL_NAME.
 ENDIF.

 method_key-CLSNAME = lv_badi_impl_name.
 method_key-CPDNAME = 'IF_SPAF_ENHANCE_ASSEMBLE_MSG~ENHANCE_ASSEMBLE_MSG'.
 lv_current_method = 'ENHANCE_ASSEMBLE_MSG'.
 CLEAR lt_working_source.
 CALL FUNCTION 'SEO_METHOD_GET_SOURCE'
    EXPORTING
      MTDKEY = method_key
    IMPORTING
      SOURCE_expanded = lt_working_source.

endmethod.

method INIT.

  CLEAR:
     lt_working_pool,
     lt_working_source,
     lv_badi_impl_name,
     lv_current_variable,
     lv_error_flag,
     lv_current_method,
     lt_field_symbol_tab,
     lt_reference_tab,
     lv_author,
     lv_first_error.

  get_badi_info( EXPORTING im_badi_name = in_badi_impl_name ).

  get_author( ).

endmethod.

method MY_CONDENSE.
  DATA: lt_temp TYPE string_table,
        ls_result TYPE string,
        ls_temp TYPE string.

  SPLIT in_string AT SPACE INTO TABLE lt_temp.
  LOOP AT lt_temp INTO ls_temp.
     ls_result = ls_result && ls_temp.
  ENDLOOP.

  out_string = ls_result.
endmethod.

method PACK_STRING_TABLE.
  DATA: lt_final_table TYPE string_table,
        lv_item TYPE string.

  lt_final_table = c_string_table.
  CLEAR c_string_table.
  LOOP AT lt_final_table INTO lv_item.
    CHECK strlen( lv_item ) > 0.
    APPEND lv_item TO c_string_table.
  ENDLOOP.
endmethod.

method SCAN_FIELD_SYMBOL.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_backup_error_line TYPE string,
        lv_backup_error_num TYPE string,
        ls_error_log TYPE ty_error_log.

  LOOP AT lt_working_pool INTO ls_line_pool.
     line_length = strlen( ls_line_pool-line_text ).
     CHECK line_length > 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_FIELD_ASSIGN IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     FIND lv_current_variable IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_LOOP IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        RETURN.
     ENDIF.
     _find_fs_check_statement( EXPORTING in_current_line = ls_line_pool-line_num ).
     RETURN.
  ENDLOOP.

endmethod.

method SCAN_REFER_VARIABLE.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_backup_error_line TYPE string,
        lv_backup_error_num TYPE string,
        ls_error_log TYPE ty_error_log.

  LOOP AT lt_working_pool INTO ls_line_pool.
     line_length = strlen( ls_line_pool-line_text ).
     CHECK line_length > 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_LOOP IN ls_line_pool-line_text.
     CHECK sy-subrc <> 0.
     FIND /SF0A0001/BADI_INTERFACE=>C_REFER_ASSIGN IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.
     FIND lv_current_variable IN ls_line_pool-line_text.
     CHECK sy-subrc = 0.

     _find_ref_check_statement( EXPORTING in_current_line = ls_line_pool-line_num ).
     RETURN.
  ENDLOOP.
endmethod.

method _FIND_CHECK_OUTPUT_REQ.
  DATA: ls_item LIKE LINE OF lt_working_pool,
        lv_index TYPE i,
        ls_error_log TYPE ty_error_log.

  lv_index = in_upper_range.
  WHILE lv_index < in_current_line.
    READ TABLE lt_working_pool INTO ls_item INDEX lv_index.
    FIND /SF0A0001/BADI_INTERFACE=>C_CHECK IN ls_item-line_text.
    IF sy-subrc = 0.
       FIND lv_current_variable IN ls_item-line_text.
       IF sy-subrc = 0.
          RETURN.
       ENDIF.
    ENDIF.
    lv_index = lv_index + 1.
  ENDWHILE.

  READ TABLE lt_working_pool INTO ls_item INDEX lv_index.
  IF lv_first_error = 0.
     lv_first_error = 1.
     CLEAR ls_error_log.
     ls_error_log-class_name = lv_badi_impl_name.

  ENDIF.

  ls_error_log-method_name = lv_current_method.
  ls_error_log-author = lv_author.
  ls_error_log-error_type = '@0A@'.
  ls_error_log-error_line = in_current_line.
  ls_error_log-error_text = ls_item-line_text.
  ls_error_log-error_description = 'Output Request must be checked before using it'.
  APPEND ls_error_log TO lt_error_log.

endmethod.

method _FIND_FS_CHECK_STATEMENT.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_index TYPE i,
        lv_max_line TYPE i,
        ls_error_log TYPE ty_error_log.

   lv_max_line = lines( lt_working_pool ).
   lv_index = in_current_line + 1.
   WHILE lv_index < lv_max_line.
     READ TABLE lt_working_pool INTO ls_line_pool INDEX lv_index.
     IF sy-subrc <> 0.
        MESSAGE e010(/SF0A0001/BADI_INSPE) WITH lv_current_variable.
     ENDIF.
     FIND /SF0A0001/BADI_INTERFACE=>C_FS_CHECK IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        RETURN.
     ENDIF.
     FIND /SF0A0001/BADI_INTERFACE=>C_SYSTEM_RETURN IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        RETURN.
     ENDIF.
     FIND lv_current_variable IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        FIND /SF0A0001/BADI_INTERFACE=>C_LOOP IN ls_line_pool-line_text.
        IF sy-subrc = 0.
           RETURN.
        ENDIF.
        IF lv_first_error = 0.
           lv_first_error = 1.
           CLEAR ls_error_log.
           ls_error_log-class_name = lv_badi_impl_name.
        ENDIF.

        ls_error_log-error_type = '@0A@'.
        ls_error_log-error_line = ls_line_pool-line_num.
        ls_error_log-error_text = ls_line_pool-line_text.
        "ls_error_log-class_name = lv_badi_impl_name.
        ls_error_log-method_name = lv_current_method.
        ls_error_log-author = lv_author.
        ls_error_log-error_description = 'Check field-symbol before using it'.
        APPEND ls_error_log TO lt_error_log.
        RETURN.
     ENDIF.
     lv_index = lv_index + 1.
   ENDWHILE.

   ASSERT 1 = 0.
endmethod.

method _FIND_REF_CHECK_STATEMENT.
  DATA: ls_line_pool LIKE LINE OF lt_working_pool,
        line_length TYPE i,
        lt_string_table TYPE string_table,
        lv_output_request_call TYPE string,
        lv_index TYPE i,
        lv_max_line TYPE i,
        ls_error_log TYPE ty_error_log.

   lv_max_line = lines( lt_working_pool ).
   lv_index = in_current_line + 1.
   WHILE lv_index < lv_max_line.
     READ TABLE lt_working_pool INTO ls_line_pool INDEX lv_index.
     IF sy-subrc <> 0.
        MESSAGE e010(/SF0A0001/BADI_INSPE) WITH lv_current_variable.
     ENDIF.
     FIND /SF0A0001/BADI_INTERFACE=>C_REFER_CHECK IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        RETURN.
     ENDIF.
     FIND /SF0A0001/BADI_INTERFACE=>C_SYSTEM_RETURN IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        RETURN.
     ENDIF.
     FIND lv_current_variable IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        FIND /SF0A0001/BADI_INTERFACE=>C_LOOP IN ls_line_pool-line_text.
        IF sy-subrc = 0.
           RETURN.
        ENDIF.
        IF lv_first_error = 0.
          lv_first_error = 1.
          CLEAR ls_error_log.
          ls_error_log-class_name = lv_badi_impl_name.
        ENDIF.
        ls_error_log-error_type = '@0A@'.
        ls_error_log-error_line = ls_line_pool-line_num.
        ls_error_log-error_text = ls_line_pool-line_text.
        "ls_error_log-class_name = lv_badi_impl_name.
        ls_error_log-method_name = lv_current_method.
        ls_error_log-author = lv_author.
        ls_error_log-error_description = 'Check reference variable before using it'.
        APPEND ls_error_log TO lt_error_log.
        RETURN.
     ENDIF.
     lv_index = lv_index + 1.
   ENDWHILE.

   ASSERT 1 = 0.
endmethod.

method _FIND_SUBRC.
  DATA: lv_current_index TYPE i,
        lv_max_level TYPE i VALUE 5,
        ls_line_pool LIKE LINE OF lt_working_pool,
        lt_string_table TYPE string_table,
        ls_error_log TYPE ty_error_log,
        lv_max_line TYPE i.

  lv_max_line = in_current_line + lv_max_level.
  lv_current_index = in_current_line.
  WHILE lv_current_index < lv_max_line.
     READ TABLE lt_working_pool INTO ls_line_pool INDEX lv_current_index.
     FIND /SF0A0001/BADI_INTERFACE=>C_SYSTEM_RETURN IN ls_line_pool-line_text.
     IF sy-subrc = 0.
        RETURN.
     ENDIF.
     lv_current_index = lv_current_index + 1.
  ENDWHILE.

  CLEAR ls_line_pool.
  READ TABLE lt_working_pool INTO ls_line_pool INDEX in_current_line.
  IF lv_first_error = 0.
     lv_first_error = 1.
     CLEAR ls_error_log.
     ls_error_log-class_name = lv_badi_impl_name.
  ENDIF.
  ls_error_log-error_type = '@09@'.
  ls_error_log-error_line = ls_line_pool-line_num.
  ls_error_log-error_text = ls_line_pool-line_text.
  "ls_error_log-class_name = lv_badi_impl_name.
  ls_error_log-method_name = lv_current_method.
  ls_error_log-author = lv_author.
  ls_error_log-error_description = 'Check sy-subrc to make sure Read is successful'.
  APPEND ls_error_log TO lt_error_log.

endmethod.

message class:/SF0A0001/BADI_INSPE
000:Interface IF_SPAF_ENHANCE_ASSEMBLE_MSG Missing for Badi:&1
001:Invalid Table Index: &1
002:Can not Find Variable Name for TYPE:&1
003:Exception is not caught in TRY Block!
004:Can not find Implementation Class for badi:&1
005:Can not Get Picture Repository for:&1
006:Can not Load Picture of:&1
007:File Upload Error:&1
008:Data Transfer Error:&1
009:Invalid Field Symbol Statement!
010:Cannot Read Next Statement for Field Symbol/ Reference Variable:&1
011:At Least One Check Option Must be Selected!
012:No Error Found!





