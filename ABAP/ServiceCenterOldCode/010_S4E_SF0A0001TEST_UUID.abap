*&---------------------------------------------------------------------*
*& Report  /SF0A0001/TEST_UUID
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/TEST_UUID.


  DATA: l_language      TYPE langu,
        l_wb_form       TYPE REF TO if_fp_wb_form,
        l_form          TYPE REF TO if_fp_form,
        lv_ft_chg_UTC   TYPE string,
        lv_dummy1       TYPE string,
        lv_dummy2       TYPE string,
        lv_version      TYPE string,
        l_layout        TYPE REF TO if_fp_layout,
        l_CACHE_INFO    TYPE string,
        total           TYPE i,
        lv_name         TYPE FPNAME,
        lt_name         TYPE table of  FPNAME,
        lv_dummy        TYPE string,
        lv_guid         TYPE string,
        lv_out          TYPE i,
        lv_inner        TYPE i,
        flag            TYPE c.

  DATA : begin of ls_guid_tab,
            guid type string,
            fname type string,
         end of ls_guid_tab.

  DATA item like ls_guid_tab.
  DATA lt_guid_tab like table of ls_guid_tab with key fname.

  flag = abap_false.
  SELECT name into table lt_name from FPCONTEXT where STATE = 'A'.
  l_language = 'E'.
  LOOP AT lt_name INTO lv_name.
     CHECK lv_name(1) = '/'.
     l_wb_form = cl_fp_wb_helper=>form_load_for_runtime( i_name = lv_name i_language = l_language ).
     l_form ?= l_wb_form->get_object( ).
     l_layout = l_form->get_layout( ).
     lv_guid = l_layout->GET_CACHE_INFO( ).
     SPLIT lv_guid AT '$' INTO lv_ft_chg_UTC lv_guid lv_dummy1 lv_dummy2 lv_version.
     item-fname = lv_name.
     item-guid = lv_guid.
     APPEND item TO lt_guid_tab.
  ENDLOOP.

DATA match like item.
DATA inner_match like item.
DESCRIBE TABLE lt_guid_tab lines total.
lv_out = 1.
DO total times.

  READ TABLE lt_guid_tab into match index lv_out.
  lv_inner = lv_out + 1.
  DO ( total - lv_out ) times.
    READ TABLE lt_guid_tab into inner_match index lv_inner.
    if match-guid = inner_match-guid.
      write / 'SAME UUID FOUND!'.
      write / match-fname.
      write / inner_match-fname.
      write / match-guid.
      write / inner_match-guid.
      write / .
      flag = abap_true.
      NEW-LINE.
    endif.
    lv_inner = lv_inner + 1.
  ENDDO.
  lv_out = lv_out + 1.
ENDDO.
IF flag = abap_false.
   WRITE / 'NO DUPLICATE UUID FOUND'.
ENDIF.