*&---------------------------------------------------------------------*
*& Report  /SF0A0001/CFCA_EN_DE_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/CFCA_EN_DE_TEST.


PARAMETERS: file TYPE localfile OBLIGATORY DEFAULT 'C:and Settingsf_435.xml',
            passwd TYPE /sf0a0001/cfca_string DEFAULT 'i042416' OBLIGATORY.
TYPES ty_content_line TYPE x LENGTH 1024.

DATA: lv_client_file_content TYPE xstring,
      lv_origin_file_content TYPE xstring,
      lv_final_content TYPE xstring,
      lv_client_private_content TYPE xstring,
      lv_subject TYPE /sf0a0001/cfca_string,
      lv_issuer TYPE /sf0a0001/cfca_string,
      lv_serial TYPE /sf0a0001/cfca_string,
      lv_rc TYPE i,
      lv_origin_file_path TYPE string,
      lv_decry TYPE xstring,
      lv_date_valid TYPE i,
      lv_file_length TYPE i,
      lt_doc_download            TYPE STANDARD TABLE OF sdok_sdatx,
      l_table_wa                 TYPE REF TO data,
      lv_signature TYPE i,
      lt_content TYPE STANDARD TABLE OF ty_content_line .

FIELD-SYMBOLS:
                <l_table_wa_flat>  TYPE any,
                <l_table_wa_struc> TYPE any.

DATA: RFCDEST like rfcdes-rfcdest VALUE 'JCO'. "corresponds to the destination namedefined in the SM59

START-OF-SELECTION.

cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = 'C:and Settings.cer'
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_file_length
      CHANGING
        data_tab                = lt_content
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
        OTHERS                  = 19
           ).
    IF sy-subrc = 1.
      WRITE:/ 'Please make sure Client1.cer is stored in desktop!'.
      RETURN.
    ELSE.
      ASSERT sy-subrc = 0.
    ENDIF.
    ASSERT lt_content IS NOT INITIAL.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_file_length
        IMPORTING
          buffer       = lv_client_file_content
        TABLES
          binary_tab   = lt_content
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
    ASSERT sy-subrc = 0.

    "********************** Upload Original file ****************************
    CLEAR: lt_content.
    lv_origin_file_path = file.
    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = lv_origin_file_path
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_file_length
      CHANGING
        data_tab                = lt_content
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
        OTHERS                  = 19
           ).

    IF sy-subrc = 1.
       WRITE:/ 'Can not open file:' , lv_origin_file_path.
       RETURN.
    ELSE.
       ASSERT sy-subrc = 0.
    ENDIF.
    ASSERT lt_content IS NOT INITIAL.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_file_length
        IMPORTING
          buffer       = lv_origin_file_content
        TABLES
          binary_tab   = lt_content
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
    ASSERT sy-subrc = 0.

    CALL FUNCTION '/SF0A0001/ENCRY_FILE'
      DESTINATION RFCDEST
        EXPORTING
           IN_CLIENT_FILE_CONTENT = lv_client_file_content
           IN_ORIGINAL_FILE_CONTENT = lv_origin_file_content
        IMPORTING
           OUT_ENCRIED_FILE_CONTENT = lv_decry
           out_rc = lv_rc.

    WRITE:/ lv_rc.

    ASSERT lv_decry IS NOT INITIAL.

    "download
    lv_file_length = xstrlen( lv_decry ).

    CREATE DATA l_table_wa LIKE LINE OF lt_doc_download.

    ASSIGN l_table_wa->* TO <l_table_wa_struc>.
    ASSIGN l_table_wa->* TO <l_table_wa_flat> CASTING TYPE x.

    DATA l_length TYPE i.
    l_length = 0.

    WHILE lv_file_length > l_length.
       <l_table_wa_flat> = lv_decry+l_length.
       l_length = l_length + 1022.  "1022 = table width
       APPEND <l_table_wa_struc> TO lt_doc_download[].
    ENDWHILE.

  lv_origin_file_path = lv_origin_file_path && '.enc'.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = lv_file_length
      filename                = lv_origin_file_path
      filetype                = 'BIN'
    TABLES
      data_tab                = lt_doc_download
*     FIELDNAMES              =
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc = 0.
    WRITE: / '***************** ENCry Senario *************'.
    WRITE: / 'Encryied File Generate successfully!'. "#EC NOTEXT
  ENDIF.

  WRITE:/ 'Encry Return Code:' , lv_rc.

  " test with decry now
  " upload private key
  CLEAR: lt_content.
  cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = 'C:and Settings.pfx'
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_file_length
      CHANGING
        data_tab                = lt_content
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
        OTHERS                  = 19
           ).
    IF sy-subrc = 1.
      WRITE:/ 'Please make sure client Private Key file is stored in desktop!'.
      RETURN.
    ELSE.
      ASSERT sy-subrc = 0.
    ENDIF.
    ASSERT lt_content IS NOT INITIAL.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_file_length
        IMPORTING
          buffer       = lv_client_private_content
        TABLES
          binary_tab   = lt_content
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
    ASSERT sy-subrc = 0.

    CALL FUNCTION '/SF0A0001/DECRY_FILE'
      DESTINATION RFCDEST
        EXPORTING
           IN_ENCRY_FILE = lv_decry
           IN_PRIVATE_KEY_FILE = lv_client_private_content
           IN_PASSWD = passwd
        IMPORTING
           OUT_DECRY_FILE = lv_final_content
           out_rc = lv_rc.

    BREAK-POINT.
*&---------------------------------------------------------------------*
*& Report  /SF0A0001/CFCA_VERIFY_SIGN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/CFCA_VERIFY_SIGN.


TYPES ty_content_line TYPE x LENGTH 1024.

DATA: lv_client_file_content TYPE xstring,
      lv_ca_file_content TYPE xstring,
      lv_subject TYPE /sf0a0001/cfca_string,
      lv_issuer TYPE /sf0a0001/cfca_string,
      lv_serial TYPE /sf0a0001/cfca_string,
      lv_rc TYPE i,
      lv_date_valid TYPE i,
      lv_file_length TYPE i,
      lv_signature TYPE i,
      lv_client_d TYPE /sf0a0001/cfca_c,
      lt_content TYPE STANDARD TABLE OF ty_content_line .

DATA: RFCDEST like rfcdes-rfcdest VALUE 'JCO'. "corresponds to the destination namedefined in the SM59

START-OF-SELECTION.

cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = 'C:and Settings.cer'
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_file_length
      CHANGING
        data_tab                = lt_content
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
        OTHERS                  = 19
           ).
    IF sy-subrc = 1.
      WRITE:/ 'Please make sure Client1.cer is stored in desktop!'.
      RETURN.
    ELSE.
      ASSERT sy-subrc = 0.
    ENDIF.
    ASSERT lt_content IS NOT INITIAL.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_file_length
        IMPORTING
          buffer       = lv_client_file_content
        TABLES
          binary_tab   = lt_content
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
    ASSERT sy-subrc = 0.

SELECT SINGLE * INTO lv_client_d FROM /sf0a0001/cfca_c.
ASSERT sy-subrc = 0.

CALL FUNCTION '/SF0A0001/CERT_VERIFY'
DESTINATION RFCDEST
  EXPORTING
     IN_CLIENT_FILE_CONTENT = lv_client_file_content
     IN_CA_FILE_CONTENT = lv_client_d-file_content
  IMPORTING
     OUT_SUBJECT         = lv_subject
     OUT_issuer          = lv_issuer
     out_serial_number   = lv_serial
     out_rc              = lv_rc
     OUT_DATE_VALID      = lv_date_valid
     OUT_SIGNATURE_CHECK = lv_signature.

ASSERT sy-subrc = 0.
WRITE:/ lv_rc.
WRITE:/ 'Subject:' ,lv_subject.
WRITE:/ lv_issuer.
WRITE:/ lv_serial.
WRITE:/ lv_date_valid.

*&---------------------------------------------------------------------*
*& Report  /SF0A0001/MAINTAIN_CA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/MAINTAIN_CA.

CONSTANTS: CA_FILE_NAME TYPE STRING VALUE 'CA_FILE'.
PARAMETERS:
  cafile TYPE localfile OBLIGATORY.

DATA: ls_ca TYPE /SF0A0001/CFCA_C,
      lv_file TYPE xstring.

START-OF-SELECTION.

  SELECT SINGLE * INTO ls_ca FROM /SF0A0001/CFCA_C WHERE FILE_NAME = CA_FILE_NAME.

  IF sy-subrc = 0.
     DELETE /SF0A0001/CFCA_C FROM ls_ca.
     ASSERT sy-subrc = 0.
     CLEAR: ls_ca.
  ENDIF.

  PERFORM upload CHANGING lv_file.
  ls_ca-file_name = ca_file_name.
  ls_ca-file_content = lv_file.
  INSERT /SF0A0001/CFCA_C FROM ls_ca.
  COMMIT WORK AND WAIT.
  ASSERT sy-subrc = 0.
  WRITE:/ 'CA Uploaded Successful!'.

********************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR cafile.
  DATA:
    file_table  TYPE filetable,
    action TYPE i,
    rc TYPE sysubrc.

  FIELD-SYMBOLS:
    <file> TYPE file_table.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      default_extension       = 'cer'
      "file_filter             = cl_gui_frontend_services=>filetype_xml
    CHANGING
      file_table              = file_table
      rc                      = rc
      user_action             = action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK action = cl_gui_frontend_services=>action_ok.

  READ TABLE file_table INDEX 1 ASSIGNING <file>.

  cafile = <file>.

  FORM upload CHANGING content TYPE xstring.
    TYPES ty_content_line TYPE x LENGTH 1024.
    DATA:
          lv_file_length TYPE i,
          file TYPE string,
          lt_content TYPE STANDARD TABLE OF ty_content_line .

    file = cafile.

    cl_gui_frontend_services=>gui_upload(
      EXPORTING
        filename                = file
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_file_length
      CHANGING
        data_tab                = lt_content
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
        OTHERS                  = 19
           ).
    ASSERT sy-subrc = 0.
    ASSERT lt_content IS NOT INITIAL.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = lv_file_length
        IMPORTING
          buffer       = content
        TABLES
          binary_tab   = lt_content
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
    ASSERT sy-subrc = 0.
  ENDFORM.


