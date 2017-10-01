*&---------------------------------------------------------------------*
*& Report  /SF0A0001/ZLEAD_ZERO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/ZLEAD_ZERO.
PARAMETERS:bo_name TYPE scoolbusinessobject DEFAULT 'APDL_OUTBOUND_DELIVERY' OBLIGATORY.

DATA: bo_id TYPE char32.
CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_DUMMY_BO_ID
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
      in_working_mode = /SF0A0001/BO_VIEWER=>LV_LEAD_ZERO.

CALL METHOD /SF0A0001/BO_VIEWER=>HANDLE_ROOT( ).

CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>DISPLAY( ).