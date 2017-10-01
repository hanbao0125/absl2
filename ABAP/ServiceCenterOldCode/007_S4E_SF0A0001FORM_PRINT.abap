*&---------------------------------------------------------------------*
*& Report  /SF0A0001/FORM_PRINT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/FORM_PRINT.

parameters: PRINT radiobutton group 1 ,
            PREVIEW radiobutton group 1 default 'X'.
PARAMETERS NODE_ID TYPE char32 DEFAULT '00145EF53A8C1DDCB9D19BA766FC1E92' OBLIGATORY.
PARAMETERS FP_ID TYPE OM_FORM_TP_CODE DEFAULT 'S1001' OBLIGATORY.
PARAMETERS FP_GID TYPE OM_FORM_GROUP_CODE DEFAULT 'S01' OBLIGATORY.
PARAMETERS PRINTER TYPE RSPOLNAME DEFAULT 'SCKP' OBLIGATORY.
PARAMETERS PDF TYPE STRING DEFAULT 'C:\Documents and Settings\I042416\Desktop\TEST.pdf' OBLIGATORY.
PARAMETERS XML TYPE STRING DEFAULT 'C:\Documents and Settings\I042416\Desktop\TEST.XML' OBLIGATORY.

DATA root_bo_name TYPE STRING.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR PDF.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Select location for PDF:'
    CHANGING
      selected_folder      = PDF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR XML.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Select location for XML:'
    CHANGING
      selected_folder      = XML.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FP_GID.
  PERFORM f4_p_fg USING 'FP_GID'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PRINTER.
  PERFORM f4_p_pr USING 'PRINTER'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR FP_ID.
  PERFORM f4_p_ft USING 'FP_ID'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR NODE_ID.
  PERFORM f4_p_node USING 'NODE_ID' FP_ID.
AT SELECTION-SCREEN OUTPUT.
START-OF-SELECTION.

DATA l TYPE /DOC/C_OM_FMT.
DATA ROOT_ID TYPE SESF_BO_NODE_ID_TAB.
DATA ls_DO_root TYPE /doc/if_om_ctrl_output_request=>ty_root.
DATA ls_DO_item TYPE /doc/if_om_ctrl_output_request=>ty_item.
DATA lt_out_messages TYPE  if_esf_types=>ty_messages.

IF PREVIEW = 'X'.
   CALL METHOD /SF0A0001/FORM_TOOL=>SET_PREVIEW_MODE( ).
ENDIF.
CALL METHOD /SF0A0001/FORM_TOOL=>init
   EXPORTING
     lv_flag = 1.

CALL METHOD /SF0A0001/FORM_TOOL=>GET_BO_NAME_BY_TP_ID
   EXPORTING
     IN_FP_ID = FP_ID
     IN_fp_group_id = fp_gid
   IMPORTING
     OUT_BO_NAME = root_bo_name.

APPEND NODE_ID to ROOT_ID.

CALL METHOD /SF0A0001/FORM_TOOL=>GET_OUTPUT_CONTROL_REQUEST
   EXPORTING
     in_bo_root_id = root_id
     in_root_bo_name = root_bo_name
   IMPORTING
     out_result_data = ls_DO_root.
IF /SF0A0001/FORM_TOOL=>lv_error = abap_true.
   EXIT.
ENDIF.
CALL METHOD /SF0A0001/FORM_TOOL=>GET_OUTPUT_PRINT_ITEM
   EXPORTING
     in_cor_root_id = ls_DO_root-node_id
     in_form_group_code = FP_GID
     in_Bo_proxy_name = root_bo_name
   IMPORTING
     out_print_item = ls_DO_item.
IF /SF0A0001/FORM_TOOL=>lv_error = abap_true.
   EXIT.
ENDIF.
CALL METHOD /SF0A0001/FORM_TOOL=>CHANGE_OM_SETTING
   EXPORTING
     in_bo_proxy_name = root_bo_name
     in_printer_code = PRINTER
     in_print_item_node = ls_do_item
     in_form_tp_code = fp_id
   IMPORTING
     out_message = lt_out_messages.
IF PREVIEW = 'X'.
  CALL METHOD /SF0A0001/FORM_TOOL=>PREVIEW
    EXPORTING
     IN_BO_PROXY_NAME = root_bo_name
     IN_ITEM_NODE_ID = ls_do_item-node_id
     IN_FORM_TEMPLATE_CODE = fp_gid.

  CALL METHOD /SF0A0001/FORM_TOOL=>GET_PREVIEW_XML_DATA
    EXPORTING
     IN_BO_NODE_ID = node_id
     IN_FILE_PATH = XML
     IN_ROOT_BO_NAME = root_bo_name.
  CALL METHOD /SF0A0001/FORM_TOOL=>GET_PREVIEW_PDF_DATA
    EXPORTING
     LV_ITEM_NODE_ID = ls_do_item-node_id
     LV_BO_NAME = root_bo_name
     LV_FILE_PATH = PDF.
  EXIT.
 ENDIF.
CALL METHOD /SF0A0001/FORM_TOOL=>PRINT
   EXPORTING
     in_bo_proxy_name = root_bo_name
     in_cor_root_id = ls_DO_root-node_id
     in_form_template_code = FP_GID.

DATA lv_output_data TYPE OM_OUTPUT_DATA.
CALL METHOD /SF0A0001/FORM_TOOL=>GET_OUTPUT_DATA
   EXPORTING
     in_node_id = NODE_ID
   IMPORTING
     out_data = lv_output_data.
IF lv_output_data IS INITIAL.
   EXIT.
ENDIF.
DATA lv TYPE i.
CALL METHOD /SF0A0001/FORM_TOOL=>DOWNLOAD_BINARY_DATA
   EXPORTING
     IV_FILE_NAME = XML
     IV_BINARY_CONTENT = lv_output_data.

CALL METHOD /SF0A0001/FORM_TOOL=>DOWNLOAD_PDF
   exporting
     IN_FP_ID = FP_ID
     IN_XML_FILE = XML
     IN_PDF_FILE = PDF.

FORM f4_p_fg USING iv_dynprofld TYPE help_info-dynprofld.
  CALL METHOD /SF0A0001/FORM_TOOL=>DISPLAY_GROUP_LIST
     EXPORTING
       iv_dynprofld = iv_dynprofld.
ENDFORM.

FORM f4_p_ft USING iv_dynprofld TYPE help_info-dynprofld.
  CALL METHOD /SF0A0001/FORM_TOOL=>DISPLAY_TEMPLATE_LIST
     EXPORTING
       iv_dynprofld = iv_dynprofld.
ENDFORM.

FORM f4_p_node USING iv_dynprofld TYPE help_info-dynprofld fp_id TYPE OM_FORM_TP_CODE.
  CALL METHOD /SF0A0001/FORM_TOOL=>DISPLAY_NODE_LIST
     EXPORTING
       in_fp_id = fp_id
       in_fp_group_id = fp_gid
       iv_dynprofld = iv_dynprofld.
ENDFORM.

FORM f4_p_pr USING iv_dynprofld TYPE help_info-dynprofld.
  CALL METHOD /SF0A0001/FORM_TOOL=>GET_PRINTER_LIST
     EXPORTING
       iv_dynprofld = iv_dynprofld.
ENDFORM.