class name: SF0A0001FORM_TOOL
backup date: 2009-04-02

class /SF0A0001/FORM_TOOL definition
  public
  create public .

public section.
*"* public components of class /SFA00031/FORM_TOOL
*"* do not include other source files here!!!

  class-data LV_ERROR type ABAP_BOOL value ABAP_FALSE. "#EC NOTEXT .

  class-methods SET_PREVIEW_MODE .
  class-methods GET_PREVIEW_PDF_DATA
    importing
      !LV_ITEM_NODE_ID type SESF_BO_NODE_ID
      !LV_BO_NAME type STRING
      !LV_FILE_PATH type STRING .
  class-methods PREVIEW
    importing
      !IN_BO_PROXY_NAME type STRING
      !IN_ITEM_NODE_ID type SESF_BO_NODE_ID
      !IN_FORM_TEMPLATE_CODE type OM_FORM_GROUP_CODE .
  class-methods GET_OUTPUT_DATA
    importing
      !IN_NODE_ID type CHAR32
    exporting
      !OUT_DATA type OM_OUTPUT_DATA .
  class-methods GET_RUNTIME_TYPE_TAB_BY_TP_ID
    importing
      !IN_FP_ID type OM_FORM_TP_CODE
    exporting
      !OUT_DATA_TYPE type STRING .
  class-methods GET_TEMPLATE_NAME_BY_ID
    importing
      !IN_FP_ID type OM_FORM_TP_CODE
    exporting
      !OUT_FORM_NAME type FPNAME .
  class-methods INIT
    importing
      !LV_FLAG type I .
  class-methods GET_BO_NAME_BY_TP_ID
    importing
      !IN_FP_GROUP_ID type OM_FORM_GROUP_CODE
      !IN_FP_ID type OM_FORM_TP_CODE
    exporting
      !OUT_BO_NAME type STRING .
  class-methods GET_RUNTIME_TYPE_LINE_BY_TP_ID
    importing
      !IN_FP_ID type OM_FORM_TP_CODE
    exporting
      !OUT_DATA_TYPE type STRING .
  class-methods DISPLAY_NODE_LIST
    importing
      !IN_FP_GROUP_ID type OM_FORM_GROUP_CODE
      !IN_FP_ID type OM_FORM_TP_CODE
      !IV_DYNPROFLD type HELP_INFO-DYNPROFLD .
  class-methods GET_BO_ID
    importing
      !IN_BO_NODE_ID type SESF_BO_NODE_ID
      !IN_BO_PROXY_NAME type STRING
      !IN_LCP type ref to IF_ESF_LCP
      !IN_FP_ID type OM_FORM_TP_CODE
      !IN_FACADE type ref to IF_ESF_LCP_FACADE
    exporting
      !OUT_ID type APC_C_BTD_ID .
  class-methods GET_PRINTER_LIST
    importing
      !IV_DYNPROFLD type HELP_INFO-DYNPROFLD .
  class-methods DISPLAY_TEMPLATE_LIST
    importing
      !IV_DYNPROFLD type HELP_INFO-DYNPROFLD .
  class-methods DISPLAY_GROUP_LIST
    importing
      !IV_DYNPROFLD type HELP_INFO-DYNPROFLD .
  class-methods DOWNLOAD_PDF
    importing
      !IN_FP_ID type OM_FORM_TP_CODE
      !IN_XML_FILE type STRING
      !IN_PDF_FILE type STRING .
  interface /DOC/IF_OM_CTRL_OUTPUT_REQUEST load .
  interface IF_ESF_TYPES load .
  class-methods CHANGE_OM_SETTING
    importing
      !IN_BO_PROXY_NAME type STRING
      !IN_PRINTER_CODE type RSPOLNAME
      !IN_FORM_TP_CODE type OM_FORM_TP_CODE
      !IN_PRINT_ITEM_NODE type /DOC/IF_OM_CTRL_OUTPUT_REQUEST=>TY_ITEM
    exporting
      !OUT_MESSAGE type IF_ESF_TYPES=>TY_MESSAGES .
  class-methods GET_OUTPUT_PRINT_ITEM
    importing
      !IN_COR_ROOT_ID type SESF_BO_NODE_ID
      !IN_FORM_GROUP_CODE type OM_FORM_GROUP_CODE
      !IN_BO_PROXY_NAME type STRING
    exporting
      !OUT_PRINT_ITEM type /DOC/IF_OM_CTRL_OUTPUT_REQUEST=>TY_ITEM .
  class-methods PRINT
    importing
      !IN_BO_PROXY_NAME type STRING
      !IN_COR_ROOT_ID type SESF_BO_NODE_ID
      !IN_FORM_TEMPLATE_CODE type OM_FORM_GROUP_CODE .
  class-methods DOWNLOAD_BINARY_DATA
    importing
      !IV_FILE_NAME type STRING
      !IV_BINARY_CONTENT type OM_OUTPUT_DATA .
  class-methods GET_LCP
    importing
      !IN_BO_PROXY_NAME type STRING
    exporting
      !OUT_LCP type ref to IF_ESF_LCP .
  class-methods GET_OUTPUT_CONTROL_REQUEST
    importing
      !IN_BO_ROOT_ID type SESF_BO_NODE_ID_TAB
      !IN_ROOT_BO_NAME type STRING
    exporting
      !OUT_RESULT_DATA type /DOC/IF_OM_CTRL_OUTPUT_REQUEST=>TY_ROOT .
  class-methods GET_PREVIEW_XML_DATA
    importing
      !IN_BO_NODE_ID type CHAR32
      !IN_FILE_PATH type STRING
      !IN_ROOT_BO_NAME type STRING .

private section.
*"* private components of class /SF0A0001/FORM_TOOL
*"* do not include other source files here!!!

  types:
    BEGIN OF   form_obj,
               fp_id         TYPE OM_FORM_TP_CODE,
               bo_proxy_name TYPE string,
               do_assoc_name TYPE string,
               bo_node_data_t_type TYPE string,
               bo_node_data_s_type TYPE string,
       END OF  form_obj .
  types:
    tt_form_obj TYPE STANDARD TABLE OF form_obj
            WITH KEY fp_id .
  types:
    BEGIN OF bo_instance,
        id      TYPE apc_c_btd_id,
        node_id TYPE sesf_bo_node_id,
    END OF bo_instance .
  types:
    tt_bo_table TYPE STANDARD TABLE OF bo_instance
           WITH KEY node_id .

  class-data LV_BACKUP_FP_ID type OM_FORM_TP_CODE .
  class-data LV_PRINT_MODE type ABAP_BOOL value ABAP_TRUE. "#EC NOTEXT .
  class-data LV_INITED_OK type ABAP_BOOL .
  class-data MT_FORM_COL type TT_FORM_OBJ .
  class-data LV_MESSAGE type STRING .
  class-data MT_BO_TABLE type TT_BO_TABLE .
  class-data LV_CURRENT_BO type SESF_BO_NODE_ID .
  class-data LV_INDEX type I value 1. "#EC NOTEXT .
  class-data LV_MAX_RETRIEVE_NUM type I value 200. "#EC NOTEXT .
  class-data LV_DO_ASSOC type STRING .
  class-data LV_ROOT_NODE_NAME type STRING value 'ROOT'. "#EC NOTEXT .

  class-methods INIT_SRM_FORM .
  class-methods GET_DEFAULT_TEMPLATE_ID
    importing
      !IN_FP_GROUP_ID type OM_FORM_GROUP_CODE
    exporting
      !OUT_FP_ID type OM_FORM_TP_CODE .
  class-methods INIT_FIN_FORM .
  class-methods INIT_CRM_FORM .
  class-methods INIT_SCM_FORM .
  class-methods LOG .

method CHANGE_OM_SETTING.
   DATA lo_lcp TYPE REF TO IF_ESF_LCP.
   DATA lo_facade TYPE REF TO if_esf_lcp_facade.
   DATA ls_item_container TYPE REF TO data.
   DATA lv_bo_node_name_item TYPE STRING.
   DATA lt_modifications TYPE  sesf_access_modify_tab.
   DATA ls_modifications TYPE sesf_access_modify.
   DATA lt_out_change_notifications TYPE  if_esf_types=>ty_change_notifications.
   FIELD-SYMBOLS:  <item_ref>       TYPE /doc/if_om_ctrl_output_request=>ty_item.
   CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.'
   /doc/if_om_ctrl_output_request=>co_bo_node-item INTO lv_bo_node_name_item.

   CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
          RECEIVING
            out_lcp_facade = lo_facade.
   TRY.
       lo_lcp = lo_facade->get_lcp( in_bo_proxy_name ).
       ls_item_container = lo_facade->get_bo_node_struct_container(
                                         in_bo_name      = in_bo_proxy_name
                                         in_bo_node_name = lv_bo_node_name_item ).
       CATCH cx_esf_core_service..
         lv_error = abap_true.
   ENDTRY.
   ASSIGN ls_item_container->* TO <item_ref>.
   <item_ref> = in_print_item_node.
   <item_ref>-electronic_msg_subject_text = 'Form Team Print Test Tool'. "#EC NOTEXT
   <item_ref>-communication_medium_type_code-content = 'PRT'.
   <item_ref>-printer_code-content = in_printer_code.
   <item_ref>-FORM_TEMPLATE_CODE-CONTENT = in_form_tp_code.
    CLEAR: ls_modifications, lt_modifications.
    ls_modifications-bo_node_name =  lv_bo_node_name_item.
    ls_modifications-node_id = in_print_item_node-node_id.
    ls_modifications-change_mode = 'U'.
    ls_modifications-data = ls_item_container.

    APPEND /doc/if_om_ctrl_output_request=>co_attr-item-printer_code-content TO ls_modifications-changed_attributes.
    APPEND /doc/if_om_ctrl_output_request=>co_attr-item-electronic_msg_subject_text TO ls_modifications-changed_attributes.
    APPEND /doc/if_om_ctrl_output_request=>co_attr-item-communication_medium_type_code-content TO ls_modifications-changed_attributes.
    APPEND /doc/if_om_ctrl_output_request=>co_attr-item-FORM_TEMPLATE_CODE-content TO ls_modifications-changed_attributes.
    ls_modifications-association_name = ''.
    ls_modifications-source_bo_node_name = ''.
    ls_modifications-source_node_id = ''.
    ls_modifications-source_node_id_is_handle = ''.
    APPEND ls_modifications TO lt_modifications.
    TRY.
    CALL METHOD lo_lcp->modify
       EXPORTING
           in_modifications         = lt_modifications
       IMPORTING
           out_messages             = out_message
           out_change_notifications = lt_out_change_notifications.
    CATCH cx_esf_core_service.
       lv_error = abap_true.
    ENDTRY.
endmethod.

method DISPLAY_GROUP_LIST.
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
endmethod.

method DISPLAY_NODE_LIST.
  TYPES: BEGIN OF f4list_s,
            id TYPE apc_c_btd_id,
            name type string,
            node_id TYPE sesf_bo_node_id,
         END OF f4list_s.

  DATA: lt_node_id TYPE sesf_bo_node_id_tab,
        ls_node_id TYPE sesf_bo_node_id,
        ls_f4list TYPE f4list_s,
        lr_f4list TYPE REF TO f4list_s,
        lt_f4list TYPE TABLE OF f4list_s,
        ls_bo_instance TYPE bo_instance,
        ls_query_options  TYPE  sesf_query_options,
        lt_requested_attributes	TYPE sesf_string_tab,
        in_bo_proxy_name TYPE STRING,
        in_lcp_facade TYPE REF TO IF_ESF_LCP_FACADE,
        lx_esf_core TYPE REF TO cx_esf_core_service,
        lo_lcp    TYPE REF TO if_esf_lcp.

  /SF0A0001/FORM_TOOL=>init( 1 ).
  TRY.

  CALL METHOD /SF0A0001/FORM_TOOL=>GET_BO_NAME_BY_TP_ID
     EXPORTING
       IN_FP_ID = in_fp_id
       IN_FP_GROUP_ID = in_fp_group_id
     IMPORTING
       OUT_BO_NAME = in_bo_proxy_name.
  IF lv_error = abap_true.
     EXIT.
  ENDIF.
  CALL METHOD /SF0A0001/FORM_TOOL=>get_lcp
     EXPORTING
       in_bo_proxy_name = in_bo_proxy_name
     IMPORTING
       out_lcp = lo_lcp.
  IF lv_error = abap_true.
     RETURN.
  ENDIF.
  APPEND 'NODE_ID' TO  lt_requested_attributes.
  ls_query_options-maximum_rows = lv_max_retrieve_num.
  CALL METHOD lo_lcp->query
        EXPORTING
          in_bo_node_name         = lv_root_node_name
          in_query_name           = 'SELECT_ALL'
          in_query_options        = ls_query_options
        IMPORTING
          out_node_ids            = lt_node_id.
   IF lt_node_id is INITIAL.
      DATA lv_messages TYPE string.
      lv_messages = 'No BO Instance for ' && in_bo_proxy_name && 'Exsited in system: ' && sy-host. "#EC NOTEXT
      message lv_messages TYPE 'I'.
      EXIT.
   ENDIF.
   DATA lo_facade TYPE REF TO IF_ESF_LCP_FACADE.
   DATA bo_id TYPE APC_C_BTD_ID.
   CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
      RECEIVING out_lcp_facade = lo_facade.
   LOOP AT lt_node_id INTO ls_node_id.
       ls_f4list-node_id = ls_node_id.
       ls_f4list-name = in_bo_proxy_name.
       CALL METHOD /SF0A0001/FORM_TOOL=>GET_BO_ID
          EXPORTING
            in_bo_proxy_name = in_bo_proxy_name
            in_lcp = lo_lcp
            in_facade = lo_facade
            in_bo_node_id = ls_node_id
            in_fp_id = in_fp_id
          IMPORTING
            out_id = bo_id.
       ls_f4list-id = bo_id.
       ls_bo_instance-id = bo_id.
       ls_bo_instance-node_id = ls_node_id.
       APPEND ls_bo_instance TO mt_bo_table.
       APPEND ls_f4list to lt_f4list.
    ENDLOOP.
    CATCH cx_esf_core_service INTO lx_esf_core.
       WRITE : 'ok'.
       EXIT.
    ENDTRY.

    SORT lt_f4list BY ID.
    LOOP AT lt_f4list REFERENCE INTO lr_f4list.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
             input         = lr_f4list->id
          IMPORTING
             OUTPUT        = lr_f4list->id.
    ENDLOOP.
    DATA title(20) TYPE c.
    title = in_bo_proxy_name.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'NODE_ID'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = iv_dynprofld
      value_org       = 'S'
      WINDOW_TITLE    = title
    TABLES
      value_tab       = lt_f4list
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
endmethod.

method DISPLAY_TEMPLATE_LIST.
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
endmethod.

METHOD DOWNLOAD_BINARY_DATA.
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


ENDMETHOD.

method DOWNLOAD_PDF.
  DATA lv_form_fm_name            TYPE funcname.
  DATA lt_fp_input_data_string    TYPE TABLE OF string.
  DATA wa_string LIKE LINE OF lt_fp_input_data_string.
  DATA lv_fp_input_data_string    TYPE string.
  DATA lv_fp_input_data_xml       TYPE xstring.
  DATA IN_FORM_NAME               TYPE FPNAME.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = in_xml_file
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
      WRITE: ' file ', in_xml_file, ' not found'. EXIT.
    ENDIF.

   CALL METHOD /SF0A0001/FORM_TOOL=>GET_TEMPLATE_NAME_BY_ID
      EXPORTING
         in_fp_id = in_fp_id
      IMPORTING
         out_form_name = in_form_name.
   CONCATENATE 'Form TP ID: ' in_fp_id INTO lv_message. "#EC NOTEXT
   log( ).
   CONCATENATE 'Form Template: ' in_form_name INTO lv_message. "#EC NOTEXT
   log( ).

TRY.
   CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
          i_name     = in_form_name
      IMPORTING
          e_funcname = lv_form_fm_name.
   CATCH cx_fp_api_repository                          "#EC NO_HANDLER
         cx_fp_api_usage
         cx_fp_api_internal.
      lv_message = 'Form not found / Error with form: ' && in_fp_id. "#EC NOTEXT
      message lv_message TYPE 'E'.
      EXIT.
ENDTRY.

  DATA ls_fp_output_params        TYPE sfpoutputparams.
  DATA ls_fp_doc_params           TYPE sfpdocparams.
  DATA ls_fp_result               TYPE fpformoutput.
  DATA ls_job_output              TYPE sfpjoboutput.
  DATA lv_doc_filesize            TYPE i.
  DATA l_length                   TYPE i.
  DATA lv_pdf                     TYPE xstring.
  DATA lt_doc_download            TYPE STANDARD TABLE OF sdok_sdatx.
  DATA l_table_wa                 TYPE REF TO data.
  DATA lv_filename                TYPE string.
  FIELD-SYMBOLS:
                <l_table_wa_flat>  TYPE any,
                <l_table_wa_struc> TYPE any.
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
    WRITE: / 'Form error ',sy-subrc, ' usage_error = 1, system_error = 2, internal_error = 3 '. "#EC NOTEXT
    EXIT.
  ENDIF.

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
  lv_pdf = ls_fp_result-pdf.
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

  lv_filename = in_PDF_file.
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
    WRITE / 'PDF Generate successfully!'. "#EC NOTEXT
  ENDIF.

endmethod.

method GET_BO_ID.
  DATA lt_root_node TYPE sesf_bo_node_id_tab.
  DATA lt_node TYPE IF_APDL_DELIVERY_TEMPLATE=>TT_ROOT.
  DATA ls_node TYPE IF_APDL_DELIVERY_TEMPLATE=>TY_ROOT.
  " Data Declaration:add 2008-10-31 to support generic access
  DATA lr_data TYPE REF TO data.
  DATA y TYPE REF TO DATA.
  DATA x TYPE REF TO DATA.
  DATA lv_table_type TYPE string.
  DATA lv_line_type TYPE string.
  FIELD-SYMBOLS : <fs_data> TYPE any table,
                  <fs_item> TYPE any,
                  <comp> TYPE any.
  TRY.
  CALL METHOD in_facade->get_bo_node_table_container
  EXPORTING
    in_bo_name                  = in_bo_proxy_name
    in_bo_node_name             = lv_root_node_name
  RECEIVING
    out_bo_node_table_container = lr_data.
  CATCH cx_esf_core_service.
     lv_error = abap_true.
  ENDTRY.
  ASSIGN lr_data->* TO <fs_data>.
  CALL METHOD /SF0A0001/FORM_TOOL=>GET_RUNTIME_TYPE_LINE_BY_TP_ID
    EXPORTING
      in_fp_id = in_fp_id
    IMPORTING
      out_data_type = lv_line_type.
  IF lv_error = abap_true.
     EXIT.
  ENDIF.
  CALL METHOD /SF0A0001/FORM_TOOL=>GET_RUNTIME_TYPE_TAB_BY_TP_ID
    EXPORTING
      in_fp_id = in_fp_id
    IMPORTING
      out_data_type = lv_table_type.
  IF lv_error = abap_true.
     EXIT.
  ENDIF.
  CREATE DATA y TYPE (lv_table_type).
  CREATE DATA x TYPE (lv_line_type).
  ASSIGN y->* to <fs_data>.
  " Implementation: ****************************************
  APPEND in_bo_node_id TO lt_root_node.
  TRY.
    CALL METHOD in_lcp->retrieve
       EXPORTING
          IN_BO_NODE_NAME = lv_root_node_name
          IN_NODE_IDS = lt_root_node
       IMPORTING
          OUT_DATA = <fs_data>.
    CATCH cx_esf_core_service.
       lv_error = abap_true.
  ENDTRY.
  LOOP AT <fs_data> REFERENCE INTO x.
    ASSIGN x->* TO <fs_item> CASTING TYPE (lv_line_type).
    ASSIGN COMPONENT 'ID-CONTENT' OF STRUCTURE <fs_item> TO <comp>.
  ENDLOOP.

  out_id = <comp>.
endmethod.

method GET_BO_NAME_BY_TP_ID.
  DATA ls_entry TYPE FORM_OBJ.
  DATA lv_default_fp_id TYPE OM_FORM_TP_CODE.
  READ TABLE mt_form_col INTO ls_entry WITH KEY fp_id = in_fp_id.
  IF sy-subrc = 4.
     " for on-demand form, it is impossible to add on-demand form template
     " into _form_col.
     CALL METHOD /SF0A0001/FORM_TOOL=>get_default_template_id
        EXPORTING
          IN_FP_GROUP_ID = in_fp_group_id
        IMPORTING
          out_fp_id = lv_default_fp_id.
     READ TABLE mt_form_col INTO ls_entry WITH KEY fp_id = lv_default_fp_id.
     IF sy-subrc = 4.
        write : 'Can not find information about form: ',in_fp_id. "#EC NOTEXT
        lv_error = abap_true.
        EXIT.
     ENDIF.
  ENDIF.
  OUT_BO_NAME = ls_entry-bo_proxy_name.
  lv_do_assoc = ls_entry-do_assoc_name.
  " Special Case for Customer Invoice
  IF in_fp_id = 'C4102' OR in_fp_id = 'C4104'.
     lv_root_node_name = 'CUSTOMER_INVOICE'.
  ENDIF.
endmethod.

method GET_LCP.

DATA in_lcp_facade TYPE REF TO if_esf_lcp_facade.
TRY.

  CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
    RECEIVING out_lcp_facade = in_lcp_facade.

  out_lcp = in_lcp_facade->get_lcp( IN_BO_PROXY_NAME ).

CATCH cx_esf_core_service.
      WRITE : 'Can not Get LCP for BO:',IN_BO_PROXY_NAME. "#EC NOTEXT
      EXIT.
ENDTRY.
endmethod.

method GET_OUTPUT_CONTROL_REQUEST.
  DATA lt_DO_root TYPE /doc/if_om_ctrl_output_request=>tt_root.
  DATA ls_DO_root TYPE /doc/if_om_ctrl_output_request=>ty_root.
  DATA lo_lcp TYPE REF TO IF_ESF_LCP.
  DATA lv_current_bo_id TYPE apc_c_btd_id.
  DATA lv_bo_instance TYPE bo_instance.
  READ TABLE in_bo_root_id INTO lv_current_bo INDEX 1.
  READ TABLE mt_bo_table INTO lv_bo_instance WITH KEY node_id = lv_current_bo.
  lv_current_bo_id = lv_bo_instance-id.
  CONCATENATE 'Output Request For BO: ' in_root_bo_name ' ID: ' lv_current_bo_id INTO lv_message. "#EC NOTEXT
  log( ).
  CALL METHOD /SF0A0001/FORM_TOOL=>GET_LCP
    EXPORTING
       in_bo_proxy_name = in_root_bo_name
    IMPORTING
       out_lcp = lo_lcp.
  IF lv_error = abap_true.
     EXIT.
  ENDIF.
  TRY.
  CALL METHOD lo_lcp->retrieve_by_association
      EXPORTING
        in_bo_node_name = lv_root_node_name
        in_association_name = lv_do_assoc
        in_node_ids = in_bo_root_id
        in_fill_data = abap_true
      IMPORTING
        out_data = lt_DO_root.
  CATCH cx_esf_core_service.
      LV_ERROR = ABAP_TRUE.
  ENDTRY.
  READ TABLE lt_DO_root INTO ls_DO_root index 1.
  IF sy-subrc = 4.
      lv_message = 'Can Not Generate ControlledOutputRequest.Root,Output Aborted.'. "#EC NOTEXT
      lv_error = abap_true.
      log( ).
      EXIT.
  ENDIF.
  out_result_data = ls_DO_root.
  lv_message = 'ControlledOutputRequest.Root Created Successfully.'. "#EC NOTEXT
  log( ).
  CONCATENATE 'NODE_ID: ' ls_DO_root-node_id INTO lv_message. "#EC NOTEXT
  log( ).

endmethod.

method GET_OUTPUT_DATA.
  DATA lt_doc_d_om_his TYPE TABLE OF /doc/d_om_his.
  DATA ls_doc_d_om_his TYPE /doc/d_om_his.
  DATA lv_node_id TYPE char32.
  SELECT * FROM /doc/d_om_his INTO TABLE lt_doc_d_om_his WHERE bo_id = in_NODE_ID.
  SORT lt_doc_d_om_his by output_dt_u DESCENDING.
  lv_node_id = in_node_id.
  READ TABLE lt_doc_d_om_his INTO ls_doc_d_om_his INDEX 1.
  IF sy-subrc = 4.
     lv_error = abap_true.
     CONCATENATE 'Can not Read Output Data for BO: ' lv_node_id INTO lv_message. "#EC NOTEXT
     CONCATENATE lv_message ' Because Current Output Still in Spool Queue.' INTO lv_message. "#EC NOTEXT
     log( ).
     EXIT.
  ENDIF.
  lv_message = 'Read Output Data Successfully.'. "#EC NOTEXT
  log( ).
  out_data = ls_doc_d_om_his-OUTPUT_DATA.
  CONCATENATE 'Read Output Data for BO: ' lv_node_id ' Successfully.' INTO lv_message. "#EC NOTEXT
  log( ).
endmethod.

method GET_OUTPUT_PRINT_ITEM.
   DATA ls_refresh_def_or  TYPE /doc/om_s_refdefitem_ac.
   DATA lt_cor_root_node_id TYPE SESF_BO_NODE_ID_TAB.
   APPEND in_cor_root_id TO lt_cor_root_node_id.
   DATA lv_bo_node_name_root TYPE string.
   DATA lo_lcp TYPE REF TO IF_ESF_LCP.
   DATA lt_item_table TYPE /DOC/IF_OM_CTRL_OUTPUT_REQUEST=>TT_ITEM.
   CALL METHOD /SF0A0001/FORM_TOOL=>GET_LCP
       EXPORTING
          IN_BO_PROXY_NAME = in_bo_proxy_name
       IMPORTING
         out_lcp = lo_lcp.
   ls_refresh_def_or-form_template_group_code-content = in_form_group_code.
   CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.'
   /doc/if_om_ctrl_output_request=>co_bo_node-root INTO lv_bo_node_name_root.
   TRY.
   CALL METHOD lo_lcp->execute_action
      EXPORTING
            in_bo_node_name      = lv_bo_node_name_root
            in_action_name       = /doc/if_om_ctrl_output_request=>co_action-root-refresh_def_or
            in_node_ids          = lt_cor_root_node_id
            in_action_parameters = ls_refresh_def_or.
   " THEN ASSOCIATE TO ITEM NODE
   CALL METHOD lo_lcp->retrieve_by_association
          EXPORTING
            in_bo_node_name     = lv_bo_node_name_root
            in_association_name = /doc/if_om_ctrl_output_request=>co_assoc-root-item
            in_node_ids         = lt_cor_root_node_id
            in_fill_data        = abap_true
          IMPORTING
            out_data            = lt_item_table.
   CATCH cx_esf_core_service.
      lv_message = 'Can not Generate ControlledOutputRequest.Item, Output Adorted.'. "#EC NOTEXT
      lv_error = abap_true.
      log( ).
      EXIT.
   ENDTRY.
   READ TABLE lt_item_table INDEX 1 INTO out_print_item.
   IF sy-subrc = 4.
      lv_message = 'Can not Generate ControlledOutputRequest.Item, Output Adorted.'. "#EC NOTEXT
      lv_error = abap_true.
      log( ).
      EXIT.
   ENDIF.
   lv_message = 'ControlledOutputRequest.Item Generated Successfully.'. "#EC NOTEXT
   log( ).
endmethod.

method GET_PREVIEW_PDF_DATA.
DATA lo_lcp TYPE REF TO if_esf_lcp.
DATA lt_output_preview TYPE /DOC/IF_OM_CTRL_OUTPUT_REQUEST=>TT_ITEM_OUTPUT_PREVIEW.
DATA ls_output_preview TYPE /DOC/IF_OM_CTRL_OUTPUT_REQUEST=>TY_ITEM_OUTPUT_PREVIEW.
DATA lt_action_node_id TYPE sesf_bo_node_id_tab.
DATA lv_bo_node_name_item TYPE string.
APPEND lv_item_node_id TO lt_action_node_id.
CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.'
   /doc/if_om_ctrl_output_request=>co_bo_node-item INTO lv_bo_node_name_item.
CALL METHOD /SF0A0001/FORM_TOOL=>GET_LCP
    EXPORTING
       in_bo_proxy_name = lv_bo_name
    IMPORTING
       out_lcp = lo_lcp.
TRY.
   CALL METHOD lo_lcp->retrieve_by_association
       EXPORTING
          in_bo_node_name = lv_bo_node_name_item
          IN_ASSOCIATION_NAME = 'ITEM_OUTPUT_PREVIEW'
          in_node_ids = lt_action_node_id
          in_fill_data = 'X'
       IMPORTING
          out_data = lt_output_preview.
   CATCH cx_esf_core_service.
      lv_error = abap_true.
ENDTRY.
READ TABLE lt_output_preview INTO ls_output_preview INDEX 1.
IF sy-subrc = 4.
   lv_error = abap_true.
   lv_message = 'Can not Get Previewed PDF.'. "#EC NOTEXT
   log( ).
   EXIT.
ENDIF.
CALL METHOD /SF0A0001/FORM_TOOL=>DOWNLOAD_BINARY_DATA
   EXPORTING
     IV_FILE_NAME = lv_file_path
     IV_BINARY_CONTENT = ls_output_preview-BINARY_OBJECT-CONTENT.
CONCATENATE 'PDF Data File Downloaded Successfully in: ' lv_file_path INTO lv_message. "#EC NOTEXT
log( ).
endmethod.

method GET_PREVIEW_XML_DATA.
  DATA lo_parameter_service      TYPE REF TO if_om_parameter_service.
  DATA lr_output_request         TYPE REF TO IF_OM_OUTPUT_REQUESTS.
  DATA ls_dummy_output_request TYPE OMST_OUTPUT_REQUESTS.
  DATA lt_uuid TYPE OM_TT_BP_UUID.
  DATA ls_parameterset TYPE OMST_OUTPUT_REQUESTS.
  DATA lv_node_id TYPE sesf_bo_node_id.
  lv_node_id = in_bo_node_id.
  CALL METHOD /DOC/CL_OM_PARA_SERVICE_FACT=>GET_INSTANCE
      EXPORTING
        IV_BO_NAME = in_root_bo_name
        IV_BO_ID = lv_node_id
      IMPORTING
        EC_PARAMETER_SERVICE = lo_parameter_service.
  ls_dummy_output_request-bo_id = in_bo_node_id.
  CALL METHOD lo_parameter_service->ADD_REPEAT_OUTPUT_REQUEST
      EXPORTING
        IS_OUTPUT_REQUEST = ls_dummy_output_request
      IMPORTING
        EC_OUTPUT_REQUESTS = lr_output_request.

  CALL METHOD lr_output_request->GET_PARAMETERSET
       EXPORTING
           iv_index = 1
       IMPORTING
           ES_PARAMETERSET = ls_parameterset.
  FIELD-SYMBOLS: <ls_data> TYPE any.
  ASSIGN ls_parameterset-form_message_ref->* TO <ls_data>.
  IF <ls_data> IS NOT ASSIGNED.
     lv_error = abap_true.
     CONCATENATE 'Can not Read Data From Message Type: ' ls_parameterset-form_message_type "#EC NOTEXT
       INTO lv_message.
     log( ).
     EXIT.
   ENDIF.
   IF ls_parameterset-form_message_type IS NOT INITIAL.
      TRY.
         CALL METHOD cl_proxy_xml_transform=>abap_to_xml_xstring
            EXPORTING
              abap_data  = <ls_data>
              ddic_type  = ls_parameterset-form_message_type
            RECEIVING
              xml        = ls_parameterset-output_data.
         CATCH cx_proxy_fault.
           lv_error = abap_true.
           lv_message = 'Can not Transform Form Message Type Instance into XML Data.'. "#EC NOTEXT
           EXIT.
      ENDTRY.
   ENDIF.
   CALL METHOD /SF0A0001/FORM_TOOL=>DOWNLOAD_BINARY_DATA
      EXPORTING
         IV_FILE_NAME = in_file_path
         IV_BINARY_CONTENT = ls_parameterset-output_data.
   CONCATENATE 'XML Data File Downloaded Successfully in: ' in_file_path INTO lv_message. "#EC NOTEXT
   log( ).

endmethod.

method GET_PRINTER_LIST.
  TYPES : BEGIN OF f4list_s,
            name TYPE RSPOLNAME,
          END OF f4list_s.
  DATA lt_printer TYPE TABLE OF /DOC/C_OM_PRT.
  DATA ls_printer TYPE /DOC/C_OM_PRT.
  DATA ls_f4list TYPE f4list_s.
  DATA lt_f4list TYPE TABLE OF f4list_s.
  SELECT * FROM /DOC/C_OM_PRT INTO TABLE lt_printer.
  LOOP AT lt_printer INTO ls_printer.
     ls_f4list-name = ls_printer-SAP_name.
     APPEND ls_f4list to lt_f4list.
  ENDLOOP.
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'NAME'
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
endmethod.

method GET_RUNTIME_TYPE_LINE_BY_TP_ID.
  DATA ls_entry TYPE FORM_OBJ.
  READ TABLE mt_form_col INTO ls_entry WITH KEY fp_id = in_fp_id.
  IF sy-subrc = 4.
     READ TABLE mt_form_col INTO ls_entry WITH KEY fp_id = lv_backup_fp_id.
     IF sy-subrc = 4.
        write : 'Can not find information about form: ',in_fp_id. "#EC NOTEXT
        lv_error = abap_true.
        EXIT.
     ENDIF.
  ENDIF.
  out_data_type = ls_entry-bo_node_data_s_type.
endmethod.

method GET_RUNTIME_TYPE_TAB_BY_TP_ID.
  DATA ls_entry TYPE FORM_OBJ.
  READ TABLE mt_form_col INTO ls_entry WITH KEY fp_id = in_fp_id.
  IF sy-subrc = 4.
     READ TABLE mt_form_col INTO ls_entry WITH KEY fp_id = lv_backup_fp_id.
     IF sy-subrc = 4.
         write : 'Can not find information about form: ',in_fp_id. "#EC NOTEXT
         lv_error = abap_true.
         EXIT.
     ENDIF.
  ENDIF.
  out_data_type = ls_entry-bo_node_data_t_type.
endmethod.

method GET_TEMPLATE_NAME_BY_ID.
  DATA ls_entry TYPE /doc/c_om_fmt.
  SELECT * from /doc/c_om_fmt INTO ls_entry where FORM_TP_CODE = in_fp_id.
  ENDSELECT.
  IF sy-subrc = 4.
     lv_error = abap_true.
     write : 'Can not find template name for: ', in_fp_id. "#EC NOTEXT
     EXIT.
  ENDIF.
  out_form_name = ls_entry-FORM_TP_ID.
endmethod.

method INIT.
  IF lv_inited_ok = abap_true.
     RETURN.
  ENDIF.
  INIT_SCM_FORM( ).
  INIT_CRM_FORM( ).
  INIT_FIN_FORM( ).
  INIT_SRM_FORM( ).
  lv_inited_ok = abap_true.
  EXIT.
endmethod.

method PREVIEW.
  DATA lo_lcp TYPE REF TO IF_ESF_LCP.
  DATA ls_send_output_item  TYPE  /doc/om_s_sendoutputitem_ac.
  DATA lv_bo_node_name_item TYPE STRING.
  DATA lr_tr_handler TYPE REF TO if_esf_lcp_transaction.
  DATA lt_action_node_id TYPE SESF_BO_NODE_ID_TAB.
  DATA lt_messages TYPE  if_esf_types=>ty_messages.

  APPEND in_item_node_id TO lt_action_node_id.
  CALL METHOD /SF0A0001/FORM_TOOL=>get_lcp
     EXPORTING
        in_bo_proxy_name = in_bo_proxy_name
     IMPORTING
        out_lcp = lo_lcp.
  CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.'
   /doc/if_om_ctrl_output_request=>co_bo_node-item INTO lv_bo_node_name_item.
  ls_send_output_item-form_template_group_code-content = in_form_template_code.
  TRY.
        CALL METHOD lo_lcp->execute_action
          EXPORTING
            in_bo_node_name      = lv_bo_node_name_item
            in_action_name       = 'PREVIEW'
            in_node_ids          = lt_action_node_id
            in_action_parameters = ls_send_output_item.
        " save the transaction to trigger the output request
        lr_tr_handler = cl_esf_lcp_factory=>get_lcp_transaction_handler( ).
        lr_tr_handler->save_transaction( IMPORTING out_messages = lt_messages ).
        COMMIT WORK AND WAIT.
        CATCH cx_esf_core_service.
           lv_error = abap_true.
  ENDTRY.
endmethod.

method PRINT.
  DATA lo_lcp TYPE REF TO IF_ESF_LCP.
  DATA ls_send_output_item  TYPE  /doc/om_s_sendoutputitem_ac.
  DATA lv_bo_node_name_root TYPE STRING.
  DATA lr_tr_handler TYPE REF TO if_esf_lcp_transaction.
  DATA lt_action_node_id TYPE SESF_BO_NODE_ID_TAB.
  DATA lt_messages TYPE  if_esf_types=>ty_messages.

  APPEND in_cor_root_id TO lt_action_node_id.
  CALL METHOD /SF0A0001/FORM_TOOL=>get_lcp
     EXPORTING
        in_bo_proxy_name = in_bo_proxy_name
     IMPORTING
        out_lcp = lo_lcp.
  CONCATENATE if_apleo_bo_service_provider=>co_do_prefix-root-controlled_output_reques '.'
   /doc/if_om_ctrl_output_request=>co_bo_node-root INTO lv_bo_node_name_root.
  ls_send_output_item-form_template_group_code-content = in_form_template_code.
  TRY.
        CALL METHOD lo_lcp->execute_action
          EXPORTING
            in_bo_node_name      = lv_bo_node_name_root
            in_action_name       = /doc/if_om_ctrl_output_request=>co_action-root-send_output_request_item
            in_node_ids          = lt_action_node_id
            in_action_parameters = ls_send_output_item.
  CATCH cx_esf_core_service.
      lv_error = abap_true.
      lv_message = 'Error Happend when Executing Action : SEND_OUTPUT_REQUEST_ITEM.'. "#EC NOTEXT
      log( ).
      EXIT.
  ENDTRY.
  " save the transaction to trigger the output request
   TRY.
     lr_tr_handler = cl_esf_lcp_factory=>get_lcp_transaction_handler( ).
     lr_tr_handler->save_transaction( IMPORTING out_messages = lt_messages ).
     COMMIT WORK AND WAIT.
   CATCH cx_esf_core_service.
     lv_error = abap_true.
   ENDTRY.
endmethod.

method SET_PREVIEW_MODE.
   lv_print_mode = abap_false.
endmethod.

method GET_DEFAULT_TEMPLATE_ID.
  DATA ls_entry TYPE /DOC/C_OM_FMGT.
  SELECT * FROM /DOC/C_OM_FMGT INTO ls_entry where DEFAULT_FLAG = 'X' AND FORM_GROUP_CODE = in_fp_group_id.
  ENDSELECT.
  out_fp_id = ls_entry-FORM_TP_CODE.
  lv_backup_fp_id = out_fp_id.
endmethod.

method INIT_CRM_FORM.
  DATA ls_entry TYPE form_obj.
  ls_entry-fp_id = 'C0001'.
  ls_entry-bo_proxy_name = 'SALES_ORDER'.
  ls_entry-bo_node_data_t_type = 'IF_APCRM_CTD_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_APCRM_CTD_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CTRL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C4102'.
  ls_entry-bo_proxy_name = 'APCI_CUSTOMER_INVOICE'.
  ls_entry-bo_node_data_t_type = 'IF_APCI_CUSTOMER_INVOICE_CSP=>TT_CUSTOMER_INVOICE'.
  ls_entry-bo_node_data_s_type = 'IF_APCI_CUSTOMER_INVOICE_CSP=>TY_CUSTOMER_INVOICE'.
  ls_entry-do_assoc_name = 'CONTR_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C4104'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C0002'.
  ls_entry-bo_proxy_name = 'CUSTOMER_QUOTE'.
  ls_entry-bo_node_data_t_type = 'IF_APCRM_CTD_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_APCRM_CTD_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CTRL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C1000'.
  ls_entry-bo_proxy_name = 'PRC_SALES_PRICE_LIST'.
  ls_entry-bo_node_data_t_type = 'IF_PRC_SALES_PRICE_LIST=>TY_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_PRC_SALES_PRICE_LIST=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CTRL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C3101'.
  ls_entry-bo_proxy_name = 'SERVICE_REQUEST'.
  ls_entry-bo_node_data_t_type = 'IF_APCRM_CTD_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_APCRM_CTD_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CTRL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C0033'.
  ls_entry-bo_proxy_name = 'SERVICE_CONFIRMATION'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'C3201'.
  ls_entry-bo_proxy_name = 'SERVICE_ORDER'.
  APPEND ls_entry TO mt_form_col.

endmethod.

method INIT_FIN_FORM.
  DATA ls_entry TYPE form_obj.
  ls_entry-fp_id = 'F0010'.
  ls_entry-bo_proxy_name = 'FOPXD_TRPAS'.
  ls_entry-bo_node_data_t_type = 'IF_FOPXD_TRPAS=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_FOPXD_TRPAS=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CTRL_OUTPUT_REQ'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'F0002'.
  ls_entry-bo_proxy_name = 'FOPXD_DUNNING'.
  ls_entry-bo_node_data_t_type = 'IF_FOPXD_DUNNING=>TT_FOPXD_DUNHEAD'.
  ls_entry-bo_node_data_s_type = 'IF_FOPXD_DUNNING=>TY_FOPXD_DUNHEAD'.
  ls_entry-do_assoc_name = 'CTRL_OUTPUT_REQ'.
  APPEND ls_entry TO mt_form_col.
endmethod.

method INIT_SCM_FORM.
  DATA ls_entry TYPE form_obj.
  ls_entry-fp_id = 'ME_07'.
  ls_entry-bo_proxy_name = 'APDL_OUTBOUND_DELIVERY'.
  ls_entry-bo_node_data_t_type = 'IF_APDL_DELIVERY_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_APDL_DELIVERY_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CNTRD_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'ME_08'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'ME_01'. "move list
  ls_entry-bo_proxy_name = 'SITE_LOGISTICS_TASK'.
  ls_entry-bo_node_data_t_type = 'IF_LOGISTICS_TASK_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_LOGISTICS_TASK_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CNTL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'ME_03'. "putaway
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'ME_06'. "unload
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'ME_04'. " Pick List
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'ME_05'. " Load List
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id ='ME_02'.
  ls_entry-bo_proxy_name = 'PHYSICAL_INVENTORY_TASK'.
  ls_entry-bo_node_data_t_type = 'IF_LOGISTICS_TASK_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_LOGISTICS_TASK_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CNTL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id ='MM_01'.
  ls_entry-bo_proxy_name = 'PRODUCTION_TASK'.
  ls_entry-do_assoc_name = 'CNTL_OUTPUT_REQUEST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id ='MM_02'.
  ls_entry-bo_proxy_name = 'PRODUCTION_ORDER'.
  ls_entry-bo_node_data_t_type = 'IF_APLEO_BO_SERVICE_PROVIDER=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = 'IF_APLEO_BO_SERVICE_PROVIDER=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CONTROLLED_OUTPUT_REQUES'.
  APPEND ls_entry TO mt_form_col.
endmethod.

method INIT_SRM_FORM.
  DATA ls_entry TYPE form_obj.
  ls_entry-fp_id = 'S1001'.
  ls_entry-bo_proxy_name = '/SRMAP/LPURX_PO'.
  ls_entry-bo_node_data_t_type = '/SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = '/SRMAP/IF_FNDX_PD_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CONTROLLED_OUTPUT_RQST'.
  APPEND ls_entry TO mt_form_col.

  ls_entry-fp_id = 'S1006'.
  ls_entry-bo_proxy_name = '/SRMAP/LRFQX_RFQ'.
  ls_entry-bo_node_data_t_type = '/SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ROOT'.
  ls_entry-bo_node_data_s_type = '/SRMAP/IF_FNDX_PD_TEMPLATE=>TY_ROOT'.
  ls_entry-do_assoc_name = 'CONTROLLED_OUTPUT_RQST'.
  APPEND ls_entry TO mt_form_col.
endmethod.

method LOG.
   DATA t(3) type c.
   t = lv_index.
   CONCATENATE t ': ' lv_message INTO lv_message.
   write : lv_message.
   NEW-LINE.
   write : '-------------------------------------------------------------------------------------------------------------------------------------'.
   NEW-LINE.
   lv_message = ''.
   lv_index = lv_index + 1.

endmethod.

