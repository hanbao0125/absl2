 DATA:  l_filename TYPE string,
       lv_out_xml type xstring,
       lv_raw_out type xstring,
        l_rawtab   TYPE STANDARD TABLE OF raw255,
        l_len      TYPE i.

  l_filename = 'C:\Users\i042416\Desktop\1.txt'.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = l_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = l_len
    CHANGING
      data_tab                = l_rawtab
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
  IF sy-subrc IS NOT INITIAL.

     WRITE:/ 'Error Occurred when Uploading zip file!' COLOR COL_NEGATIVE INTENSIFIED ON.
     RETURN.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = l_len
    IMPORTING
      buffer       = lv_out_xml
    TABLES
      binary_tab   = l_rawtab
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc IS NOT INITIAL.

  ENDIF.

* try.
*  call method cl_abap_gzip=>decompress_binary
*    EXPORTING
*       GZIP_IN = lv_out_xml
*    IMPORTING
*       RAW_OUT = lv_raw_out.
*catch cx_root into data(cx_root).
*   WRITE:/ cx_root->get_text( ).
*endtry.

data: lv_text type string.
try.
 call method cl_abap_gzip=>decompress_text
   EXPORTING
      GZIP_IN = lv_out_xml
   IMPORTING
      TEXT_OUT = lv_text.

 catch cx_root into data(cx_root).
   WRITE:/ cx_root->get_text( ).
endtry.

WRITE:/ 'decompressed:', lv_text.