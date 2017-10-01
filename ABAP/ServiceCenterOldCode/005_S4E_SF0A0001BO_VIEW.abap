*&---------------------------------------------------------------------*
*& Report  /SF0A0001/BO_VIEW
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/BO_VIEW.

PARAMETERS:bo_name TYPE scoolbusinessobject default 'SITE_LOGISTICS_TASK' OBLIGATORY.
PARAMETERS:node_id TYPE char32 default '00300571C7F602DC94B722AD2CDB4057' OBLIGATORY.
PARAMETERS XML TYPE STRING DEFAULT 'C:\Documents and Settings\I042416\Desktop\TEST.XML' OBLIGATORY.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR NODE_ID.
  PERFORM f4_p_node USING 'NODE_ID' bo_name.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR XML.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Select location for XML:'
    CHANGING
      selected_folder      = XML.
AT SELECTION-SCREEN OUTPUT.

START-OF-SELECTION.
  CALL METHOD /SF0A0001/BO_VIEWER=>init
    EXPORTING
      IN_BO_NAME = bo_name
      IN_NODE_ID = node_id
      in_working_mode = /SF0A0001/BO_VIEWER=>LV_BO_VIEW.

WRITE :/ 'BO DATA Extracted to XML File: ' , XML, ' Successfully!'.
SKIP 1.
WRITE :/ '******************************************************************************'.

CALL METHOD /SF0A0001/BO_VIEWER=>HANDLE_ROOT( ).
CALL METHOD /SF0A0001/BO_VIEWER=>DOWNLOAD_XML( in_file_path = XML ).

FORM f4_p_node USING iv_dynprofld TYPE help_info-dynprofld bo_name TYPE scoolbusinessobject.
   CALL METHOD /SF0A0001/BO_VIEWER=>display_node_list
     EXPORTING
       iv_bo_name   = bo_name
       iv_dynprofld = iv_dynprofld.
ENDFORM.