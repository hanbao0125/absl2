*&---------------------------------------------------------------------*
*& Report  /SF0A0001/BADI_ACTIVE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/BADI_ACTIVE.

TYPE-POOLS abap.

PARAMETERS: p_check TYPE abap_bool RADIOBUTTON GROUP grp1 DEFAULT 'X'.
  SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
    PARAMETER:
         b_name TYPE BADIIMPL_ENH-ENHNAME DEFAULT '/SFA01017/ZIPPEL_CI' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk1.

PARAMETERS: p_list TYPE abap_bool RADIOBUTTON GROUP grp1.
  SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE text-002.
    PARAMETER:
         s_name TYPE ENHSTRING DEFAULT 'CO_APDL_ODE_PROC_DEL_NOTE_OUT' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK blk2.

IF p_check = 'X'.
  CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>CHECK_MULTIPLE_EXIST
     EXPORTING
       im_badi_name = b_name.
ELSEIF p_list = 'X'.
  CALL METHOD /SF0A0001/BADI_CHECK_TOOL=>LIST_BADI
     EXPORTING
       im_interface = s_name.
ENDIF.