*&---------------------------------------------------------------------*
*& Report  ZBM_TST_ZIP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbm_tst_zip.

DATA: lo_zip TYPE REF TO cl_abap_zip.
CREATE OBJECT lo_zip.

DATA: l_file_path           TYPE string.
DATA: lt_xml_rawtable       TYPE dcxmllines.
DATA: lv_xstring            TYPE xstring.
DATA: lv_upload_xstring     TYPE xstring.
DATA: lv_upload_string      TYPE string.
TRY.
    CALL METHOD cl_salv_test_data=>select_file
      IMPORTING
        filename = l_file_path.

  CATCH cx_root.
ENDTRY.
CALL METHOD cl_gui_frontend_services=>gui_upload
  EXPORTING
    filename = l_file_path
    filetype = 'BIN'
  CHANGING
    data_tab = lt_xml_rawtable
  EXCEPTIONS
    OTHERS   = 1.

LOOP AT lt_xml_rawtable INTO lv_xstring.
  CONCATENATE lv_upload_xstring lv_xstring INTO lv_upload_xstring IN BYTE MODE.
ENDLOOP.

DATA: lo_conv_in TYPE REF TO cl_abap_conv_in_ce.
TRY.
    lo_conv_in = cl_abap_conv_in_ce=>create( input = lv_upload_xstring ).
    lo_conv_in->read( IMPORTING data = lv_upload_string ).
  CATCH cx_root .
ENDTRY.


DATA: l_filename TYPE string VALUE 'T005'.
lo_zip->add( name = l_filename content = lv_upload_xstring ).

DATA: l_file TYPE xstring.
l_file = lo_zip->save( ).

WRITE: l_file.
WRITE: lv_upload_string.
*
DATA:  lt_xml_stream      TYPE etxml_xline_tabtype.
DATA:  lv_length          TYPE i.
TRY.
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer        = l_file
  IMPORTING
    output_length = lv_length
  TABLES
    binary_tab    = lt_xml_stream.

CALL METHOD cl_gui_frontend_services=>gui_download
  EXPORTING
    bin_filesize = lv_length
    filetype     = 'BIN'
    filename     = 'C:\Documents and Settings\I031791\Desktop\A1F 2 A1F\T002.zip'
  CHANGING
    data_tab     = lt_xml_stream
  EXCEPTIONS
    OTHERS       = 0.
CATCH cx_root.
  ENDTRY.

WRITE:/ 'END'.