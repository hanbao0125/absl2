*&---------------------------------------------------------------------*
*& Report  /SF0A0001/BADI_CODE_INSPECTOR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/BADI_CODE_INSPECTOR.

SELECTION-SCREEN COMMENT /1(83) comm1.
    PARAMETER:
         p_sing RADIOBUTTON GROUP grp1 DEFAULT 'X',
         p_badi TYPE string DEFAULT '/SFA0000K/PREH_DELI',
         p_mass RADIOBUTTON GROUP grp1.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN COMMENT /1(83) comm2.
PARAMETERS: OM_REQ AS CHECKBOX USER-COMMAND flag DEFAULT 'X',
            FS AS CHECKBOX USER-COMMAND flag DEFAULT 'X',
            REFER AS CHECKBOX USER-COMMAND flag DEFAULT 'X',
            DATATYPE AS CHECKBOX USER-COMMAND flag DEFAULT 'X',
            DATACOM AS CHECKBOX USER-COMMAND flag.

DATA: lt_badi_table TYPE TABLE OF BADIIMPL_ENH,
      ls_badi_item TYPE BADIIMPL_ENH,
      lv_name TYPE string,
      lv_first TYPE i VALUE 1.

CALL METHOD /SF0A0001/BADI_CODE_INSPECTOR=>FILL_TASK
   EXPORTING
      IN_OUTPUT_REQUEST = OM_REQ
      IN_FS_CHECK = FS
      IN_REF_CHECK = REFER
      IN_READ_CHECK = DATATYPE.

IF p_mass = 'X'.
  SELECT ENHNAME ACTIVE FROM BADIIMPL_ENH INTO CORRESPONDING FIELDS OF TABLE lt_badi_table WHERE ENHNAME LIKE '/SFA%'.
ELSE.
  SELECT ENHNAME ACTIVE FROM BADIIMPL_ENH INTO CORRESPONDING FIELDS OF TABLE lt_badi_table WHERE ENHNAME = p_badi.
ENDIF.

LOOP AT lt_badi_table INTO ls_badi_item.

  CALL METHOD /SF0A0001/BADI_CODE_INSPECTOR=>RUN
     EXPORTING
       in_badi_impl_name = ls_badi_item-ENHNAME.
ENDLOOP.

CALL METHOD /SF0A0001/BADI_CODE_INSPECTOR=>DISPLAY( ).

AT SELECTION-SCREEN OUTPUT."ON RADIOBUTTON GROUP grp1.
   IF lv_first = 1.
      lv_first = 0.
      LOOP AT SCREEN.
         IF screen-name = 'DATACOM'.
            screen-input = '0'.
            screen-REQUIRED = '0'.
            screen-output = '0'.
            MODIFY SCREEN.
         ENDIF.
      ENDLOOP.
      RETURN.
   ENDIF.

   LOOP AT SCREEN.
     IF screen-name = 'P_BADI'.
        IF p_mass = 'X'.
          screen-input = '0'.
          screen-REQUIRED = '0'.
          screen-output = '0'.
          MODIFY SCREEN.
        ELSE.
           screen-input = '1'.
           MODIFY SCREEN.
        ENDIF.
     ENDIF.
     IF screen-name = 'P_MASS'.
        IF p_sing = 'X'.
          screen-REQUIRED = '0'.
          screen-output = '0'.
          MODIFY SCREEN.
        ENDIF.
     ENDIF.
     IF screen-name = 'P_SING'.
        IF p_mass = 'X'.
          screen-REQUIRED = '0'.
          screen-output = '0'.
          MODIFY SCREEN.
        ENDIF.
     ENDIF.
     IF screen-name = 'DATACOM'.
          screen-input = '0'.
          screen-REQUIRED = '0'.
          screen-output = '0'.
          MODIFY SCREEN.
     ENDIF.
   ENDLOOP.

INITIALIZATION.
    comm1 = 'Please Choose Check Mode: Single or Mass Check'.
    comm2 = 'Please Choose Check Option Below:'.