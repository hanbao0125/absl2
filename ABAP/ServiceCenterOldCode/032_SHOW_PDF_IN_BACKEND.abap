FUNCTION MODULE: /SF0A0006/PDF_WINDOW

FUNCTION /SF0A0006/PDF_WINDOW.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IN_PDF) TYPE  FPCONTENT
*"----------------------------------------------------------------------

DATA: lv_pdf TYPE FPCONTENT.
lv_pdf = in_pdf.

EXPORT lv_pdf TO MEMORY ID 'PDF_ID'.

CALL SCREEN 0302 STARTING AT 1 1.

ENDFUNCTION.

IMPORT: 
IN_PDF TYPE FPCONTENT

FLOW LOGIC:

PROCESS BEFORE OUTPUT.

  MODULE pbo_html_control.
*
PROCESS AFTER INPUT.
  MODULE pai_html_control.

SCREEN: IN SCREEN THERE IS A CUSTOM-CONTROL NAMED HTML.

*----------------------------------------------------------------------*
***INCLUDE /SF0A0006/LTAX_GROUPO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_HTML_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO_HTML_CONTROL OUTPUT.
DATA: pdf_html_control TYPE REF TO cl_gui_html_viewer,
      pdf_my_container TYPE REF TO cl_gui_custom_container,
      pdf_alignment    TYPE i,
      lv_pdf TYPE FPCONTENT.


  IMPORT lv_pdf FROM MEMORY ID 'PDF_ID'.
  CHECK lv_PDF IS NOT INITIAL.
  IF pdf_my_container IS INITIAL.
    CREATE OBJECT pdf_my_container
      EXPORTING
        container_name = 'HTML'
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'CONTROL ERROR' TYPE 'E'.
    ENDIF.
  ENDIF.

  CREATE OBJECT pdf_html_control
      EXPORTING
        parent = pdf_my_container
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'CONTROL ERROR' TYPE 'E'.
    ENDIF.

    pdf_alignment = pdf_html_control->align_at_left  +
                    pdf_html_control->align_at_right +
                    pdf_html_control->align_at_top   +
                    pdf_html_control->align_at_bottom.

    CALL METHOD pdf_html_control->set_alignment
      EXPORTING
        alignment = pdf_alignment
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'CONTROL ERROR' TYPE 'E'.
    ENDIF.

  DATA: l_url      TYPE char80,
        l_pdf_data TYPE tsfixml,
        l_len      TYPE i.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER                = lv_pdf
    TABLES
      BINARY_TAB            = l_pdf_data.

 l_len = xstrlen( lv_pdf ).
 IF l_len = 0.
    RETURN.
 ENDIF.

 CALL METHOD pdf_html_control->load_data
    EXPORTING
      url          = 'smart.pdf'                            "#EC NOTEXT
      size         = L_LEN
      type         = 'application'                          "#EC NOTEXT
      subtype      = 'pdf'
    IMPORTING
      assigned_url = l_url
    CHANGING
      data_table   = l_pdf_data
    EXCEPTIONS
      OTHERS       = 1.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'ERROR: CONTROL->LOAD_DATA' TYPE 'E'.
  ENDIF.

* Show data.
  CALL METHOD pdf_html_control->show_data
    EXPORTING
      url    = l_url
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE 'ERROR: CONTROL->SHOW_DATA' TYPE 'E'.
  ENDIF.
ENDMODULE.                 " PBO_HTML_CONTROL  OUTPUT

*----------------------------------------------------------------------*
***INCLUDE /SF0A0006/LTAX_GROUPI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAI_HTML_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI_HTML_CONTROL INPUT.
   "LEAVE TO SCREEN 0.
  DATA:  fcode            TYPE syucomm.
  CASE fcode.
    WHEN 'EXIT'.
      IF NOT pdf_html_control IS INITIAL.
        pdf_html_control->free( ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE 'CONTROL ERROR' TYPE 'E'.
        ENDIF.
        FREE pdf_html_control.
      ENDIF.
      IF NOT pdf_my_container IS INITIAL.
        pdf_my_container->free( ).
        IF sy-subrc IS NOT INITIAL.
          MESSAGE 'CONTROL ERROR' TYPE 'E'.
        ENDIF.
        FREE pdf_my_container.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      cl_gui_cfw=>dispatch( ).
      IF sy-subrc IS NOT INITIAL.
        MESSAGE 'CONTROL ERROR' TYPE 'E'.
      ENDIF.
  ENDCASE.

  CLEAR fcode.
ENDMODULE.                 " PAI_HTML_CONTROL  INPUT
