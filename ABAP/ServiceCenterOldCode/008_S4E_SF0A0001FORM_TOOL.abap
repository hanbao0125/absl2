*&---------------------------------------------------------------------*
*& Report  /SF0A0001/FORM_TOOL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/FORM_TOOL.

DATA: container1 TYPE REF TO cl_gui_custom_container,
      pict1 TYPE REF TO cl_gui_picture.

SELECTION-SCREEN COMMENT /1(83) comm1.
    PARAMETER:
         p_bs RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm2.
    PARAMETER:
         p_ba RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm3.
    PARAMETER:
         p_bo RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm4.
    PARAMETER:
         p_lz RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm5.
    PARAMETER:
         p_ui RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm6.
    PARAMETER:
         p_pr RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm7.
    PARAMETER:
         p_uu RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN COMMENT /1(83) comm8.
    PARAMETER:
         p_bc RADIOBUTTON GROUP grp1.
SELECTION-SCREEN SKIP 1.

AT SELECTION-SCREEN OUTPUT.
   comm1 = '@45@' && '[1] Tool to Extract All BO Proxy Name and Association Name Used in the Badi'.
   comm2 = '@12@' && '[2] Tool to Active/Deactive all Badi within Specific Service Interface'.
   comm3 = '@1X@' && '[3] Tool to DownLoad a Given BO Instance Into XML File'.
   comm4 = '@3H@' && '[4] Tool to Find all BO Nodes Which have Potential Leading Zero Issue'.
   comm5 = '@3V@' && '[5] Tool to Display All Bo Nodes UI texts in Portal'.
   comm6 = '@4A@' && '[6] Tool to Automatical Print & Preview Form Template'.
   comm7 = '@4X@' && '[7] Tool to detect On-Demand Form UUID Issue'.
   comm8 = '@56@' && '[8] Tool to detect programming issue of Badi Source Code'.

AT SELECTION-SCREEN.
   IF p_bs = 'X'.
     CALL TRANSACTION '/SF0A0001/BS'.
   ENDIF.
   IF p_ba = 'X'.
     CALL TRANSACTION '/SF0A0001/AC'.
   ENDIF.
   IF p_bo = 'X'.
     CALL TRANSACTION '/SF0A0001/BO'.
   ENDIF.
   IF p_lz = 'X'.
     CALL TRANSACTION '/SF0A0001/LZ'.
   ENDIF.
   IF p_ui = 'X'.
     CALL TRANSACTION '/SF0A0001/UI'.
   ENDIF.
   IF p_pr = 'X'.
     CALL TRANSACTION '/SF0A0001/PR'.
   ENDIF.
   IF p_uu = 'X'.
     CALL TRANSACTION '/SF0A0001/UU'.
   ENDIF.
   IF p_bc = 'X'.
     CALL TRANSACTION '/SF0A0001/BC'.
   ENDIF.

INCLUDE /SF0A0001/FORM_TOOL_STATUS_O01.

MODULE STATUS_0100 OUTPUT.
  CALL METHOD /SF0A0001/PICTURE_UTILITY=>INIT
     EXPORTING
       in_container = container1
       in_pic = pict1.

  CALL METHOD /SF0A0001/PICTURE_UTILITY=>DISPLAY( ).

ENDMODULE.   

