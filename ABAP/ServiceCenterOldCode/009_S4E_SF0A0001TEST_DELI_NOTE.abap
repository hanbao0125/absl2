*&---------------------------------------------------------------------*
*& Report  /SF0A0001/TEST_DELI_NOTE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/TEST_DELI_NOTE.
*&---------------------------------------------------------------------*
*& Report  Z_TEST_DELIVERY_NOTE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*


TYPE-POOLS: tstr, icon.

SELECTION-SCREEN BEGIN OF BLOCK bo_na WITH FRAME TITLE text-299.
PARAMETERS:
  DE_ID       TYPE char32 DEFAULT '00145EF53A8C1DDD8189CB483CEB4FB0'.
SELECTION-SCREEN END OF BLOCK bo_na.

SELECTION-SCREEN BEGIN OF BLOCK bo_name WITH FRAME TITLE text-298.
PARAMETERS:
  p_med TYPE apc_c_commun_medium_type_code DEFAULT 'INT',
  p_em TYPE char256 DEFAULT 'jerry.wang@sap.com',
  p_pc TYPE apc_c_printer_code.
SELECTION-SCREEN END OF BLOCK bo_name.

SELECTION-SCREEN BEGIN OF BLOCK bo_form WITH FRAME TITLE text-296.
PARAMETERS:
  p_fg LIKE /doc/c_om_fmg-form_group_code DEFAULT 'ME7',
  p_ftpc TYPE	om_form_tp_code DEFAULT 'ME_07',
  p_ftpid   TYPE fpwbformname DEFAULT 'A1S_ODP_PF_EN_DELIVERY_NOTE'.
SELECTION-SCREEN END OF BLOCK bo_form.

SELECTION-SCREEN BEGIN OF BLOCK bo_nap WITH FRAME TITLE text-297.
PARAMETERS:
  p_file TYPE localfile DEFAULT 'C:\Documents and Settings\I042416\Desktop\TEST.XML',
  p_pdf TYPE localfile DEFAULT 'C:\Documents and Settings\I042416\Desktop\TEST.PDF'.
SELECTION-SCREEN END OF BLOCK bo_nap.

CONSTANTS: lc_buffer_size TYPE i VALUE 2000.

DATA:
      lo_lcp                     TYPE REF TO if_esf_lcp,
      ls_sesf_bo_node_id         TYPE sesf_bo_node_id,
      lv_uuid                    TYPE /ueo/rt_node_uuid,
      lt_node_id_tmp             TYPE sesf_bo_node_id_tab,
      ls_node_id_tmp             TYPE sesf_bo_node_id,
      ls_node_id                 TYPE sesf_bo_node_id,
      lt_node_id                 TYPE sesf_bo_node_id_tab,
      lt_node_id_action          TYPE sesf_bo_node_id_tab,
      lt_node_id_item            TYPE sesf_bo_node_id_tab,
      lt_node_id_root            TYPE sesf_bo_node_id_tab,
      lt_selection_parameters    TYPE  sesf_selection_parameters_tab,
      lo_facade                  TYPE REF TO if_esf_lcp_facade,
      lv_nr                      TYPE int4,
      lv_nr_node_ids             TYPE int4,
      lv_nr_node_data            TYPE int4,
      lt_data_root               TYPE IF_APDL_DELIVERY_TEMPLATE=>tt_root,
      ls_data_root               TYPE IF_APDL_DELIVERY_TEMPLATE=>ty_root,
      ls_data_print_root         TYPE /doc/if_om_ctrl_output_request=>ty_root,
      lt_data_print_root         TYPE /doc/if_om_ctrl_output_request=>tt_root,
      lt_modifications           TYPE  sesf_access_modify_tab,
      ls_modifications           TYPE sesf_access_modify,
      ls_refresh_def_or          TYPE /doc/om_s_refdefitem_ac,
      ls_send_output_item        TYPE  /doc/om_s_sendoutputitem_ac,
      ls_data_print_item         TYPE /doc/if_om_ctrl_output_request=>ty_item,
      lt_data_print_item         TYPE /doc/if_om_ctrl_output_request=>tt_item,
      ls_data_email              TYPE if_addrp_address=>ty_email,
      lt_com_data                TYPE if_addrp_address=>tt_root,
      ls_com_data                TYPE if_addrp_address=>ty_root,
      lr_tr_handler              TYPE REF TO if_esf_lcp_transaction,
      ls_item_container          TYPE REF TO  data,
      ls_email_container         TYPE REF TO  data,
      ls_messages                TYPE REF TO cm_esi_root,
      lt_messages                TYPE  if_esf_types=>ty_messages,
      lv_msg_string              TYPE string,
      lv_bo_node_name_root       TYPE string,
      lv_bo_node_name_item       TYPE string,
      lv_bo_node_name_e_mail     TYPE string,
      lv_file_name               TYPE localfile,
      lv_electronic_msg_subject_text  TYPE apc_v_electr_mess_subj_text,
      lv_filename                TYPE  string,
      lv_xml                     TYPE string,
      lv_exe_path                TYPE string,
      lv_exe_par                 TYPE string,
      lv_bo_name                 TYPE  string,
      lv_bo_node_name            TYPE  string,
      lv_association_name        TYPE string,
      lv_btd_id                  TYPE apc_c_btd_id,
      lt_out_change_notifications TYPE  if_esf_types=>ty_change_notifications,
      lt_out_messages            TYPE  if_esf_types=>ty_messages,
      lv_form_fm_name            TYPE funcname,
      ls_fp_output_params        TYPE sfpoutputparams,
      ls_fp_doc_params           TYPE sfpdocparams,
      ls_fp_result               TYPE fpformoutput,
      ls_job_output              TYPE sfpjoboutput,
      lv_form_name               TYPE fpname,
      lv_pdf                     TYPE xstring,
      lv_doc_filesize            TYPE i,
      lv_fp_input_data_string    TYPE string,
      lv_fp_input_data_xml       TYPE xstring,
      lt_fp_input_data_string    TYPE TABLE OF string,
      wa_string LIKE LINE OF lt_fp_input_data_string,

      lv_buffer(lc_buffer_size)  TYPE c,
      lt_buffer                  LIKE TABLE OF lv_buffer,
      lv_file_size               TYPE i,
      l_table_wa                 TYPE REF TO data,
      l_length                   TYPE i,
      lt_doc_download            TYPE STANDARD TABLE OF sdok_sdatx,
      ls_doc_d_om_his            TYPE /doc/d_om_his,
      lt_doc_d_om_his            TYPE TABLE OF /doc/d_om_his,
      lv_om_output_data          TYPE om_output_data,
      lo_abap_conv_in_ce         TYPE REF TO cl_abap_conv_in_ce,
      l_uuid_16                  TYPE sysuuid_x16,
      lv_guid_32                 TYPE  guid_32,
      loref                      TYPE REF TO cx_uuid_error.

FIELD-SYMBOLS:  <item_ref>       TYPE /doc/if_om_ctrl_output_request=>ty_item,
                <email_ref>      TYPE if_addrp_address=>ty_email,
                <l_table_wa_flat>  TYPE any,
                <l_table_wa_struc> TYPE any.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR DE_ID.
  PERFORM f4_p_order USING 'DE_ID'.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fg.
  PERFORM f4_p_fg USING 'P_FG'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ftpc.
  PERFORM f4_p_ftpc USING 'P_FTPC'.

AT SELECTION-SCREEN OUTPUT.

    p_fg = 'ME7'.
    p_ftpc = 'ME_07'.
    p_ftpid = 'A1S_ODP_PF_EN_DELIVERY_NOTE'.


***********************************
START-OF-SELECTION.
**********************************


    TRY.
          ls_sesf_bo_node_id = DE_ID. lv_bo_name = 'APDL_OUTBOUND_DELIVERY'.
          lv_bo_node_name = if_apleo_bo_service_provider=>co_bo_node-root.
          lv_association_name = if_apleo_bo_service_provider=>co_assoc-root-controlled_output_reques.
          CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.' /doc/if_om_ctrl_output_request=>co_bo_node-root INTO lv_bo_node_name_root.
          CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.' /doc/if_om_ctrl_output_request=>co_bo_node-item INTO lv_bo_node_name_item.
          CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.' /doc/if_om_ctrl_output_request=>co_bo_node-root INTO lv_bo_node_name_e_mail.
          "ControlledOutputRequest.ItemCommunicationData.EMAIL"

        INSERT ls_sesf_bo_node_id INTO TABLE lt_node_id_root.

        CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
          RECEIVING
            out_lcp_facade = lo_facade.
        lo_lcp =  lo_facade->get_lcp( lv_bo_name ).

        "IF p_order = abap_true.
          CALL METHOD lo_lcp->retrieve
            EXPORTING
              in_bo_node_name = lv_bo_node_name
              in_node_ids     = lt_node_id_root
            IMPORTING
              out_data        = lt_data_root.
          READ TABLE lt_data_root INDEX 1 INTO ls_data_root.
          IF NOT ( sy-subrc IS INITIAL ).
            WRITE: 'Sorry, no order found  -> nothing to do, try it again :-)  '.NEW-LINE.
            WRITE: 'Search for a another order via F4-Help '.NEW-LINE.
            EXIT.
          ELSE.
            lv_btd_id = ls_data_root-id-content.
          ENDIF.

        "ENDIF.
        CALL METHOD lo_lcp->retrieve_by_association
          EXPORTING
            in_bo_node_name     = lv_bo_node_name
            in_association_name = 'CNTRD_OUTPUT_REQUEST'"lv_association_name
            in_node_ids         = lt_node_id_root
            in_fill_data        = abap_true
          IMPORTING
            out_data            = lt_data_print_root.

        LOOP AT lt_data_print_root INTO ls_data_print_root.
          INSERT ls_data_print_root-node_id INTO TABLE lt_node_id_action.
        ENDLOOP.

*       create default item
        ls_refresh_def_or-form_template_group_code-content = p_fg.
        CALL METHOD lo_lcp->execute_action
          EXPORTING
            in_bo_node_name      = lv_bo_node_name_root
            in_action_name       = /doc/if_om_ctrl_output_request=>co_action-root-refresh_def_or
            in_node_ids          = lt_node_id_action
            in_action_parameters = ls_refresh_def_or.
*       navigate to default item
        CALL METHOD lo_lcp->retrieve_by_association
          EXPORTING
            in_bo_node_name     = lv_bo_node_name_root
            in_association_name = /doc/if_om_ctrl_output_request=>co_assoc-root-item
            in_node_ids         = lt_node_id_action
            in_fill_data        = abap_true
          IMPORTING
            out_data            = lt_data_print_item.
        IF   ( lt_data_print_item IS INITIAL ).
          WRITE 'no print items generated nothing to print check input data or customzing'.
          EXIT.
        ENDIF.
*       there shouldn't be more than 1
        READ TABLE lt_data_print_item INDEX 1 INTO ls_data_print_item.
        READ TABLE lt_data_print_root INTO ls_data_print_root WITH KEY node_id = ls_data_print_item-parent_node_id .
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_btd_id
          IMPORTING
            output = lv_btd_id.

        TRY.
            l_uuid_16 = cl_system_uuid=>create_uuid_x16_static( ).
            lv_guid_32 = l_uuid_16.
          CATCH cx_uuid_error INTO loref.
            l_uuid_16 = '0'.
        ENDTRY.
        CONCATENATE lv_bo_name lv_btd_id lv_guid_32 INTO lv_electronic_msg_subject_text SEPARATED BY space.
        ls_item_container = lo_facade->get_bo_node_struct_container(
                                         in_bo_name      = lv_bo_name
                                         in_bo_node_name = lv_bo_node_name_item ).
        ASSIGN ls_item_container->* TO <item_ref>.
        <item_ref> = ls_data_print_item.
        <item_ref>-electronic_msg_subject_text = lv_electronic_msg_subject_text.
        IF p_med = 'INT'.
          <item_ref>-communication_medium_type_code-content = 'INT'.
*            <item_ref>-email_uri-content = p_em.
          <item_ref>-printer_code-content = ''.
        ELSE.
          <item_ref>-communication_medium_type_code-content = 'PRT'.
          IF NOT ( p_pc IS INITIAL ) .
            <item_ref>-printer_code-content = p_pc.
          ENDIF.
        ENDIF.

        CLEAR: ls_modifications, lt_modifications.
        ls_modifications-bo_node_name =  lv_bo_node_name_item.
        ls_modifications-node_id = ls_data_print_item-node_id.
        ls_modifications-change_mode = 'U'.
        ls_modifications-data = ls_item_container.
        APPEND /doc/if_om_ctrl_output_request=>co_attr-item-printer_code-content TO ls_modifications-changed_attributes.
        APPEND /doc/if_om_ctrl_output_request=>co_attr-item-electronic_msg_subject_text TO ls_modifications-changed_attributes.
        APPEND /doc/if_om_ctrl_output_request=>co_attr-item-communication_medium_type_code-content TO ls_modifications-changed_attributes.
        ls_modifications-association_name = ''.
        ls_modifications-source_bo_node_name = ''.
        ls_modifications-source_node_id = ''.
        ls_modifications-source_node_id_is_handle = ''.
        APPEND ls_modifications TO lt_modifications.
        APPEND ls_data_print_item-node_id TO lt_node_id_item.

        CALL METHOD lo_lcp->modify
          EXPORTING
            in_modifications         = lt_modifications
          IMPORTING
            out_messages             = lt_out_messages
            out_change_notifications = lt_out_change_notifications.

*  now go to do communication data
        CALL METHOD lo_lcp->retrieve_by_association
          EXPORTING
            in_bo_node_name     = lv_bo_node_name_item
            in_association_name = /doc/if_om_ctrl_output_request=>co_assoc-item-communication_data
            in_node_ids         = lt_node_id_item
            in_fill_data        = abap_true
          IMPORTING
            out_data            = lt_com_data.
        READ TABLE  lt_com_data INDEX 1 INTO ls_com_data.
        IF  NOT ( sy-subrc IS INITIAL ).
          WRITE 'no communication data node found.'.
          EXIT.
        ENDIF.
*  we need to create a new default_email node
        ls_email_container = lo_facade->get_bo_node_struct_container(
                                         in_bo_name      = lv_bo_name
                                         in_bo_node_name = 'ControlledOutputRequest.ItemCommunicationData.EMAIL' ). "lv_bo_node_name_e_mail ).
        ASSIGN ls_email_container->* TO <email_ref>.
        <email_ref> = ls_data_email.
        <email_ref>-uri-content = p_em.
        <email_ref>-parent_node_id = ls_com_data-node_id.
        CLEAR: ls_modifications, lt_modifications.
* create default email node
        ls_modifications-bo_node_name = 'ControlledOutputRequest.ItemCommunicationData.EMAIL'.
        ls_modifications-node_id = '$tmp$8864'.
        ls_modifications-change_mode = 'C'.
        ls_modifications-data = ls_email_container.
        APPEND if_addrp_address=>co_attr-email-uri-content TO ls_modifications-changed_attributes.
        ls_modifications-association_name = 'DEFAULT_EMAIL'.
        ls_modifications-source_bo_node_name = 'ControlledOutputRequest.ItemCommunicationData.ROOT'.
        ls_modifications-source_node_id = ls_com_data-node_id.
        ls_modifications-source_node_id_is_handle = ''.
        APPEND ls_modifications TO lt_modifications.
        CALL METHOD lo_lcp->modify
          EXPORTING
            in_modifications         = lt_modifications
          IMPORTING
            out_messages             = lt_out_messages
            out_change_notifications = lt_out_change_notifications.

        ls_send_output_item-form_template_group_code-content = p_fg.
        CALL METHOD lo_lcp->execute_action
          EXPORTING
            in_bo_node_name      = lv_bo_node_name_root
            in_action_name       = /doc/if_om_ctrl_output_request=>co_action-root-send_output_request_item
            in_node_ids          = lt_node_id_action
            in_action_parameters = ls_send_output_item.

        lr_tr_handler = cl_esf_lcp_factory=>get_lcp_transaction_handler( ).
        lr_tr_handler->save_transaction( IMPORTING out_messages = lt_messages ).
        COMMIT WORK AND WAIT.

        WRITE : lv_bo_name, ' printed '. NEW-LINE.
        LOOP AT lt_messages INTO ls_messages.
          lv_msg_string = ls_messages->get_text( ).
          WRITE: '--> ', lv_msg_string. NEW-LINE.
        ENDLOOP.

      CATCH cx_esf_core_service .
        WRITE : 'exception: cx_esf_core_service '. NEW-LINE.
      CATCH cx_fatal_exception.
        WRITE : 'exception: cx_fatal_exception '. NEW-LINE.
      CATCH cx_root.
        WRITE : 'exception: cx_fatal_exception '. NEW-LINE.
    ENDTRY.


  IF ( DE_ID IS NOT INITIAL ).
      SELECT * FROM /doc/d_om_his INTO TABLE lt_doc_d_om_his WHERE bo_id = DE_ID.
* workaround: can't select via EMAIL_SUBject
    LOOP AT lt_doc_d_om_his INTO ls_doc_d_om_his.
      IF ls_doc_d_om_his-email_subject = lv_electronic_msg_subject_text.
        lv_om_output_data = ls_doc_d_om_his-output_data.
        lv_fp_input_data_xml = lv_om_output_data.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_fp_input_data_xml IS INITIAL.
      WRITE: 'no data found '.
      EXIT.
    ENDIF.
    WRITE: / 'Form Template Code: ', p_ftpc.
    WRITE: / 'Subject: ', ls_doc_d_om_his-email_subject.
    WRITE: / 'Output date: ', ls_doc_d_om_his-output_dt_c.

    lo_abap_conv_in_ce = cl_abap_conv_in_ce=>create( ).

    CALL METHOD lo_abap_conv_in_ce->convert
      EXPORTING
        input = lv_om_output_data
      IMPORTING
        data  = lv_xml.
*   CATCH cx_sy_conversion_codepage .
*   CATCH cx_sy_codepage_converter_init .
*   CATCH cx_parameter_invalid_type .
*  ENDTRY.

    WRITE: / 'XML data:'.
    WRITE: / lv_xml.
    lv_file_size = strlen( lv_xml ).
    WHILE strlen( lv_xml ) >= lc_buffer_size .
      lv_buffer = lv_xml.
      APPEND lv_buffer TO lt_buffer.
      SHIFT lv_xml BY lc_buffer_size PLACES.
    ENDWHILE.
    lv_buffer = lv_xml.
    APPEND lv_buffer TO lt_buffer.
  ENDIF.
  IF DE_ID IS NOT INITIAL.
    lv_filename = p_file.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_filename
        write_lf                = ''
      TABLES
        data_tab                = lt_buffer
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
      WRITE: /.
      WRITE: / 'XML data is downloaded to ', p_file.
    ELSE.
      WRITE: / 'file download error.'.
    ENDIF.
  ENDIF.

* now start with transformation into pdf
  CHECK p_ftpid IS NOT INITIAL.    " no adobe form
  IF DE_ID IS NOT INITIAL.
* get data from file
    lv_filename = p_file.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = lv_filename
        filetype                = 'ASC'
      TABLES
        data_tab                = lt_fp_input_data_string
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
        OTHERS                  = 17.
    IF sy-subrc = 0. " No error in GUI Upload of selected Data XML
      LOOP AT lt_fp_input_data_string INTO wa_string.
        CONCATENATE lv_fp_input_data_string wa_string INTO lv_fp_input_data_string.
      ENDLOOP.

      CALL METHOD cl_xms_main=>convert_string_to_xstring
        EXPORTING
          im_string  = lv_fp_input_data_string
        IMPORTING
          ex_xstring = lv_fp_input_data_xml.
    ELSE.
      WRITE: ' file ', lv_filename, ' not found'. EXIT.
    ENDIF.
  ELSE.
*    CALL METHOD cl_xms_main=>convert_string_to_xstring
*      EXPORTING
*        im_string  = ls_debug-xml_data
*      IMPORTING
*        ex_xstring = lv_fp_input_data_xml.
  ENDIF.

* get form function module name
  TRY.
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = p_ftpid
        IMPORTING
          e_funcname = lv_form_fm_name.

    CATCH cx_fp_api_repository                          "#EC NO_HANDLER
          cx_fp_api_usage
          cx_fp_api_internal.
      WRITE: ' Form not found / Error with form: ', p_ftpid .  EXIT.
  ENDTRY.

* set output parameter
  ls_fp_output_params-nodialog = abap_true.
  ls_fp_output_params-noprint = abap_false.
  ls_fp_output_params-getpdf = abap_true.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = ls_fp_output_params
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
  ENDIF.

* set parameters for form processing
*      IF iv_i_ind = abap_true.
*        ls_fp_doc_params-fillable = abap_true.
*      ENDIF.

* call form function module
  CALL FUNCTION lv_form_fm_name
    EXPORTING
      /1bcdwb/docparams  = ls_fp_doc_params
      /1bcdwb/docxml     = lv_fp_input_data_xml
    IMPORTING
      /1bcdwb/formoutput = ls_fp_result
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    WRITE: / 'Form error ',sy-subrc, ' usage_error = 1, system_error = 2, internal_error = 3 '.
    EXIT.
  ENDIF.

* fill export parameter
  lv_pdf = ls_fp_result-pdf.

  CALL FUNCTION 'FP_JOB_CLOSE'
    IMPORTING
      e_result       = ls_job_output
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
  ENDIF.

*fill table for GUI_Download (lt_doc_download) from result xstring (lv_pdf) from form processing
  lv_doc_filesize = xstrlen( lv_pdf ).

* Create workarea corresponding to requested table
  CREATE DATA l_table_wa LIKE LINE OF lt_doc_download.

  ASSIGN l_table_wa->* TO <l_table_wa_struc>.
  ASSIGN l_table_wa->* TO <l_table_wa_flat> CASTING TYPE x.

  l_length = 0.

*   Split xstring into table
  WHILE lv_doc_filesize > l_length.
    <l_table_wa_flat> = lv_pdf+l_length.
    l_length = l_length + 1022.  "1022 = table width
    APPEND <l_table_wa_struc> TO lt_doc_download[].
  ENDWHILE.

  lv_filename = p_pdf.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = lv_doc_filesize
      filename                = lv_filename
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
    WRITE / 'PDF Generate successfully!'.
  ENDIF.




************** END OF REPORT ***************************************************

FORM f4_p_order USING iv_dynprofld TYPE help_info-dynprofld.

  TYPES: BEGIN OF f4list_s,
            id TYPE apc_c_btd_id,
            user TYPE apc_c_user_account_id,
            date TYPE char14,
            node_id TYPE sesf_bo_node_id,
         END OF f4list_s.

  DATA: lt_node_id TYPE sesf_bo_node_id_tab,
        ls_node_id TYPE sesf_bo_node_id,
        lt_data   TYPE if_apleo_bo_service_provider=>tt_root,
        ls_data   TYPE if_apleo_bo_service_provider=>ty_root,
        ls_f4list TYPE f4list_s,
        lt_f4list TYPE TABLE OF f4list_s,
        lo_lcp    TYPE REF TO if_esf_lcp,
        lt_requested_attributes	TYPE sesf_string_tab,
        lv_date TYPE char24,
        lv_suid_uuid  TYPE suid_uuid,
        ls_identity TYPE  suid_st_identity,
        ls_query_options  TYPE  sesf_query_options,
        lo_facade             TYPE REF TO if_esf_lcp_facade.

  lo_facade = cl_esf_lcp_factory=>get_lcp_facade( ).

  TRY.
      lo_lcp =  lo_facade->get_lcp( 'APDL_OUTBOUND_DELIVERY' ).
      ls_query_options-maximum_rows = '20000'.
      APPEND 'SYSTEM_ADMINISTRATIVE_DATA-CREATION_DATE_TIME' TO  lt_requested_attributes.
      APPEND 'SYSTEM_ADMINISTRATIVE_DATA-CREATION_IDENTITY_UUID' TO  lt_requested_attributes.
      APPEND 'NODE_ID' TO  lt_requested_attributes.
      CALL METHOD lo_lcp->query
        EXPORTING
          in_bo_node_name         = 'ROOT'
          in_query_name           = 'SELECT_ALL'
          "in_requested_attributes = lt_requested_attributes
          "in_fill_data            = abap_true
          in_query_options        = ls_query_options
        IMPORTING
          out_node_ids            = lt_node_id.
          "out_data                = lt_data.
    CATCH cx_esf_core_service .
  ENDTRY.

  "LOOP AT lt_data INTO ls_data.
   LOOP AT lt_node_id INTO ls_node_id.
    CLEAR: ls_f4list.
    "ls_f4list-node_id = ls_data-node_id.
    ls_f4list-node_id = ls_node_id.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        "input  = ls_data-id-content
        input = ls_node_id
      IMPORTING
        output = ls_f4list-id.
    lv_date = ls_data-system_administrative_data-creation_date_time.
    ls_f4list-date = lv_date+1(14).
    IF NOT ( ls_data-system_administrative_data-creation_identity_uuid IS INITIAL ).
      cl_gdt_conversion=>guid_outbound( EXPORTING im_guid_x = ls_data-system_administrative_data-creation_identity_uuid-content
                                       IMPORTING ex_value = lv_suid_uuid ).
      TRY.
          CALL METHOD cl_identity_factory=>query_identity_by_uuid
            EXPORTING
              iv_identity_uuid = lv_suid_uuid
            IMPORTING
              es_identity      = ls_identity.
        CATCH cx_suid_identity .
      ENDTRY.

      ls_f4list-user = ls_identity-bname.
    ENDIF.
    APPEND ls_f4list TO lt_f4list.
  ENDLOOP.
  SORT lt_f4list BY id DESCENDING.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'NODE_ID'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = iv_dynprofld
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4list
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.                                                    "f4_p_order


*&---------------------------------------------------------------------*
*&      Form  f4_p_fg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_DYNPROFLD  text
*----------------------------------------------------------------------*
FORM f4_p_fg USING iv_dynprofld TYPE help_info-dynprofld.

  TYPES: BEGIN OF f4list_s,
           id_code   TYPE /doc/c_om_fmg-form_group_code,
           description   TYPE char64,
        END OF f4list_s.

  DATA: lo_code_list_prov            TYPE REF TO if_esf_code_list_provider,
        ls_f4list TYPE f4list_s,
        lt_f4list TYPE TABLE OF f4list_s,
        lt_code_list  TYPE  if_esf_code_list_provider=>tt_code_values_w_descriptions,
        ls_code_list  TYPE  if_esf_code_list_provider=>ty_code_value_w_description.

  lo_code_list_prov = cl_esf_code_list_prov_factory=>get_code_list_provider( 'APC_S_OUT_REQ_FORM_TEMP_GRP_C' ).
  lt_code_list = lo_code_list_prov->retrieve_code_list( in_language_code = sy-langu ).

  LOOP AT lt_code_list INTO ls_code_list.
    ls_f4list-id_code = ls_code_list-content.
    ls_f4list-description = ls_code_list-description.
    APPEND ls_f4list TO lt_f4list.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ID_CODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = iv_dynprofld
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4list
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.                                                    "f4_p_fg

*&---------------------------------------------------------------------*
*&      Form  f4_p_ftpc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_DYNPROFLD  text
*----------------------------------------------------------------------*
FORM f4_p_ftpc USING iv_dynprofld TYPE help_info-dynprofld.

  TYPES: BEGIN OF f4list_s,
            id_code   TYPE om_form_tp_code,
            description   TYPE char64,
         END OF f4list_s.

  DATA: lo_code_list_prov            TYPE REF TO if_esf_code_list_provider,
        ls_f4list TYPE f4list_s,
        lt_f4list TYPE TABLE OF f4list_s,
        lt_code_list  TYPE  if_esf_code_list_provider=>tt_code_values_w_descriptions,
        ls_code_list  TYPE  if_esf_code_list_provider=>ty_code_value_w_description.

  lo_code_list_prov = cl_esf_code_list_prov_factory=>get_code_list_provider( 'APC_S_OUTPUT_REQ_FORM_TEMPL_C' ).
  lt_code_list = lo_code_list_prov->retrieve_code_list( in_language_code = sy-langu ).

  LOOP AT lt_code_list INTO ls_code_list.
    ls_f4list-id_code = ls_code_list-content.
    ls_f4list-description = ls_code_list-description.
    APPEND ls_f4list TO lt_f4list.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'ID_CODE'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = iv_dynprofld
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4list
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.                                                    "f4_p_ftpc