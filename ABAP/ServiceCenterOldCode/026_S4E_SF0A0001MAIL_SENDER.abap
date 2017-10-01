class name: SF0A0001MAIL_SENDER
backup date: 2009-04-02

class /SF0A0001/MAIL_SENDER definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/MAIL_SENDER
*"* do not include other source files here!!!

  class-data LV_TEST type I .

  class-methods INIT .
  class-methods SEND .

private section.
*"* private components of class /SFA00031/MAIL_SENDER
*"* do not include other source files here!!!

  class-data LV_REMOTE_MAIL type STRING value 'mail\jerry.txt'. "#EC NOTEXT .
  class-data LV_LOCAL_MAIL_PATH type STRING value 'C:\Documents and Settings\I042416\Desktop\jerry.txt'. "#EC NOTEXT .

method INIT.
  CONSTANTS: c_linelen TYPE i VALUE 255.
  DATA: wa_data(c_linelen) TYPE x,
        it_data LIKE TABLE OF wa_data,
        lv_xstring TYPE xstring,
        lv_length TYPE i.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_local_mail_path
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_length
    CHANGING
      data_tab                = it_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_length
    IMPORTING
      buffer       = lv_xstring
    TABLES
      binary_tab   = it_data
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DATA: mess(60).

  OPEN DATASET lv_remote_mail FOR OUTPUT IN BINARY MODE MESSAGE mess.
  IF sy-subrc <> 0.
    WRITE: 'SY-SUBRC:', sy-subrc,
         / 'System Message:', mess. "#EC NOTEXT
    RETURN.
  ENDIF.

  TRANSFER lv_xstring TO lv_remote_mail.
  IF sy-subrc <> 0.
    WRITE: 'SY-SUBRC:', sy-subrc.
    RETURN.
  ENDIF.

  CLOSE DATASET lv_remote_mail.
endmethod.

method SEND.

CONSTANTS:
      c_linelen TYPE i VALUE 255.

DATA:
      ls_document_data TYPE sodocchgi1,
      ls_packing_list TYPE sopcklsti1,
      lt_packing_list TYPE TABLE OF sopcklsti1,
      ls_contents_txt TYPE solisti1,
      lt_contents_txt TYPE TABLE OF solisti1,
      ls_receivers TYPE somlreci1,
      lt_receivers TYPE TABLE OF somlreci1,
      ls_xdata TYPE solix-line,
      lt_xdata LIKE TABLE OF ls_xdata,
      ls_data TYPE solisti1-line,
      lt_data LIKE TABLE OF ls_data,
      lv_xstring TYPE xstring,
      lv_string TYPE string,
      lv_xlength TYPE i,
      lv_length TYPE i,
      lv_linenum TYPE i.

CLEAR ls_document_data.
ls_document_data-obj_name = 'mail'.
ls_document_data-obj_descr = 'Form Print Tool Update: both print and preview are supported now'. "#EC NOTEXT


OPEN DATASET lv_remote_mail FOR INPUT IN BINARY MODE.
IF sy-subrc <> 0.
  MESSAGE 'Can''t find template file' TYPE 'I'. "#EC NOTEXT
  RETURN.
ENDIF.
READ DATASET lv_remote_mail INTO lv_xstring.
CLOSE DATASET lv_remote_mail.
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer        = lv_xstring
  IMPORTING
    output_length = lv_xlength
  TABLES
    binary_tab    = lt_xdata.
CALL FUNCTION 'SCMS_BINARY_TO_STRING'
  EXPORTING
    input_length  = lv_xlength
  IMPORTING
    text_buffer   = lv_string
    output_length = lv_length
  TABLES
    binary_tab    = lt_xdata
  EXCEPTIONS
    failed        = 1
    OTHERS        = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
  EXPORTING
    text      = lv_string
  IMPORTING
    length    = lv_length
  TABLES
    ftext_tab = lt_data.
LOOP AT lt_data INTO ls_data.
  ls_contents_txt-line = ls_data.
  APPEND ls_contents_txt TO lt_contents_txt.
ENDLOOP.
lv_linenum = ( lv_length + c_linelen - 1 ) DIV c_linelen.

CLEAR ls_packing_list.
ls_packing_list-body_start = 1.
ls_packing_list-body_num = lv_linenum.
ls_packing_list-doc_size = lv_length.
ls_packing_list-doc_type = 'txt'.
APPEND ls_packing_list TO lt_packing_list.

FREE lt_receivers.
CLEAR ls_receivers.
*ls_receivers-receiver = 'jerry.wang@sap.com'.
*ls_receivers-rec_type = 'U'.
*APPEND ls_receivers TO lt_receivers.
ls_receivers-receiver = 'jerry.wang@sap.com'.
ls_receivers-rec_type = 'U'.
APPEND ls_receivers TO lt_receivers.

CALL FUNCTION 'SO_DOCUMENT_SEND_API1' DESTINATION 'VCUCLNT100'
  EXPORTING
    document_data              = ls_document_data
    commit_work                = 'X'
* IMPORTING
*   SENT_TO_ALL                =
*   NEW_OBJECT_ID              =
*   SENDER_ID                  =
  TABLES
    packing_list               = lt_packing_list
*   OBJECT_HEADER              =
    contents_txt               = lt_contents_txt
*   CONTENTS_HEX               =
*   OBJECT_PARA                =
*   OBJECT_PARB                =
    receivers                  = lt_receivers
  EXCEPTIONS
    too_many_receivers         = 1
    document_not_sent          = 2
    document_type_not_exist    = 3
    operation_no_authorization = 4
    parameter_error            = 5
    x_error                    = 6
    enqueue_error              = 7
    OTHERS                     = 8.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
endmethod.

