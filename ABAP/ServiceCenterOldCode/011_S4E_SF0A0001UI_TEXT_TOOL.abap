*&---------------------------------------------------------------------*
*& Report  /SF0A0001/UI_TEXT_TOOL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/UI_TEXT_TOOL.
PARAMETERS:bo_name TYPE scoolbusinessobject DEFAULT 'SITE_LOGISTICS_TASK' OBLIGATORY.

DATA: bo_id TYPE char32.
CALL METHOD /SF0A0001/UI_TEXT_TOOL=>GET_DUMMY_BO_ID
   EXPORTING
     in_bo_name = bo_name
   IMPORTING
     out_bo_id = bo_id.
IF bo_id IS INITIAL.
   WRITE:/ 'No BO instance: ' , bo_name , ' exists in ' , sy-sysid.
   EXIT.
ENDIF.

CALL METHOD /SF0A0001/BO_VIEWER=>init
    EXPORTING
      IN_BO_NAME = bo_name
      IN_NODE_ID = bo_id
      in_working_mode = /SF0A0001/BO_VIEWER=>LV_UI_TEXT.

CALL METHOD /SF0A0001/BO_VIEWER=>HANDLE_ROOT( ).

CALL METHOD /SF0A0001/UI_TEXT_TOOL=>DISPLAY( ).