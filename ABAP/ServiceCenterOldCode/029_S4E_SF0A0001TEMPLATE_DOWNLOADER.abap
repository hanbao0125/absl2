class name: SF0A0001TEMPLATE_DOWNLOADER
backup date: 2009-04-02

class /SF0A0001/TEMPLATE_DOWNLOADER definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/TEMPLATE_DOWNLOADER
*"* do not include other source files here!!!

  class-data LV_TEST type I .

  class-methods DOWNLOAD_BINARY_STRING
    importing
      !IV_FILE_NAME type STRING
      !IV_BINARY_CONTENT type XSTRING
    returning
      value(RV_RC) type I .

METHOD download_binary_string.
  "Convert binary string to BINTAB
  TYPES:  ty_bin_data(1024) TYPE x .                        "#EC NEEDED
  TYPES:  tt_bin_data       TYPE STANDARD TABLE OF ty_bin_data."#EC NEEDED

  DATA: lp_data TYPE REF TO data.
  DATA: lf_bin_length TYPE i,
        lf_pos        TYPE i,
        lf_n          TYPE i.
  FIELD-SYMBOLS: <fs_data>   TYPE any,
                 <fs_binary> TYPE x.
  DATA: et_binary_tab TYPE tt_bin_data,
        e_binary_size TYPE i.
* --------------------------------------------------------------------
  CLEAR et_binary_tab.
  e_binary_size = xstrlen( iv_binary_content ).

  CREATE DATA lp_data LIKE LINE OF et_binary_tab[].
  ASSIGN lp_data->* TO <fs_data>.

  ASSIGN COMPONENT 1 OF STRUCTURE <fs_data> TO <fs_binary> CASTING TYPE x.
  IF sy-subrc = 4.
    ASSIGN COMPONENT 0 OF STRUCTURE <fs_data> TO <fs_binary> CASTING TYPE x.
  ENDIF.

  DESCRIBE FIELD <fs_binary> LENGTH lf_bin_length IN BYTE MODE.
  lf_n = ( e_binary_size + lf_bin_length - 1 ) DIV lf_bin_length.

  DO lf_n TIMES.
    <fs_binary> = iv_binary_content+lf_pos.
    lf_pos = lf_pos + lf_bin_length.
    APPEND <fs_data> TO et_binary_tab.
  ENDDO.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      bin_filesize              = e_binary_size
      filename                  = iv_file_name
      filetype                  = 'BIN'
      CONFIRM_OVERWRITE         = 'X'
*      append                    = SPACE
*      write_field_separator     = SPACE
*      header                    = '00'
*      trunc_trailing_blanks     = SPACE
*      write_lf                  = 'X'
*      col_select                = SPACE
*      col_select_mask           = SPACE
*      dat_mode                  = SPACE
*      confirm_overwrite         = SPACE
*      no_auth_check             = SPACE
*      codepage                  = SPACE
*      ignore_cerr               = ABAP_TRUE
*      replacement               = '#'
*      write_bom                 = SPACE
*      trunc_trailing_blanks_eol = 'X'
*      wk1_n_format              = SPACE
*      wk1_n_size                = SPACE
*      wk1_t_format              = SPACE
*      wk1_t_size                = SPACE
*    IMPORTING
*      filelength                =
    CHANGING
      data_tab                  = et_binary_tab
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24.
  rv_rc = sy-subrc.


ENDMETHOD.