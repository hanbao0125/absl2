class CL_ABAP_GIT_ISSUE_TOOL definition
  public
  final
  create public .

public section.

  class-methods READ_TXT_FILE
    importing
      !IV_PATH type STRING
    returning
      value(RV_TEXT) type STRING .
  class-methods DOWNLOAD_AS_TEXT_FILE
    importing
      !IV_FILE_PATH type STRING
      !IV_TEXT_CONTENT type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS CL_ABAP_GIT_ISSUE_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_TOOL=>DOWNLOAD_AS_TEXT_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILE_PATH                   TYPE        STRING
* | [--->] IV_TEXT_CONTENT                TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD download_as_text_file.
    DATA: lt_data_tab TYPE TABLE OF sdokcntasc.

    CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
      EXPORTING
        text      = iv_text_content
      TABLES
        ftext_tab = lt_data_tab.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename = iv_file_path
        codepage = '8400'
      CHANGING
        data_tab = lt_data_tab.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_TOOL=>READ_TXT_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PATH                        TYPE        STRING
* | [<-()] RV_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD read_txt_file.

    DATA: l_filename TYPE string,
          l_rawtab   TYPE string_table,
          l_len      TYPE i.

    l_filename = iv_path.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = l_filename
        filetype                = 'ASC'
        CODEPAGE                = '8400'
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

    ASSERT sy-subrc = 0.

    LOOP AT l_rawtab ASSIGNING FIELD-SYMBOL(<line>).
      rv_text = rv_text && <line>.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.