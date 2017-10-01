class name: SF0A0001GENERATOR
backup date: 2009-04-02

class /SF0A0001/GENERATOR definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/GENERATOR
*"* do not include other source files here!!!

  types:
    BEGIN OF digit,
               index TYPE i,
               value TYPE string,
    END OF digit .
  types:
    tt_digit TYPE standard table of digit with key index .

  class-data LV_LENGTH type I value 6. "#EC NOTEXT .
  class-data LV_UP type STRING value 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'. "#EC NOTEXT .
  class-data LV_LOW type STRING value 'abcdefghijklmnopqrstuvwxyz'. "#EC NOTEXT .
  class-data LV_NUM type STRING value '0123456789'. "#EC NOTEXT .
  class-data LV_CHAR_NUM type I value 26. "#EC NOTEXT .
  class-data:
    mt_passwd type standard table of string .

  class-methods GENERATE
    importing
      !LV_INDEX type I
      !LV_CHAR type C .

private section.
*"* private components of class /SF0A0001/GENERATOR
*"* do not include other source files here!!!

  class-data LV_INTERNAL_TEMP type STRING value '????????'. " max length 8 just for test

method GENERATE.
  data: ls_entry type digit,
        lv_passwd type string,
        lv_whole type string,
        lv_option type c,
        lv_char_index type i value 0,
        lv_current_index type i,
        lv_offset type i,
        lv_current_char_internal type c.
  field-symbols <row> like ls_entry.

  lv_current_char_internal = lv_internal_temp+lv_index(1).
  replace section offset lv_index length 1 of: lv_internal_temp with lv_char.
*  READ TABLE mt_digit ASSIGNING <row> with table key index = lv_index.
*  IF sy-subrc = 4.
*    ls_entry-index = lv_index.
*    ls_entry-value = lv_char.
*    APPEND ls_entry to mt_digit.
*  ELSE.
*    <row>-value = lv_char.
*  ENDIF.

  IF lv_index <> lv_length - 1.
     lv_current_index = lv_index + 1.
     DO lv_char_num times.
        lv_option = lv_up+lv_char_index(1).
        call method /SF0A0001/GENERATOR=>GENERATE
          exporting
            lv_index = lv_current_index
            lv_char  = lv_option.
        lv_char_index = lv_char_index + 1.
     ENDDO.
     lv_char_index = 0.
     DO lv_char_num times.
        lv_option = lv_low+lv_char_index(1).
        call method /SF0A0001/GENERATOR=>GENERATE
          exporting
            lv_index = lv_current_index
            lv_char  = lv_option.
        lv_char_index = lv_char_index + 1.
     ENDDO.
     lv_char_index = 0.
     DO 10 times.
        lv_option = lv_num+lv_char_index(1).
        call method /SF0A0001/GENERATOR=>GENERATE
          exporting
            lv_index = lv_current_index
            lv_char  = lv_option.
        lv_char_index = lv_char_index + 1.
     ENDDO.
  ELSE.
*     LOOP AT mt_digit into ls_entry.
*        lv_passwd = lv_passwd && ls_entry-value.
*     ENDLOOP.
     find first occurrence of '?' in lv_internal_temp match offset lv_offset.
     lv_passwd = lv_internal_temp+0(lv_offset).
     lv_char_index = 0.
     DO lv_char_num times.
        lv_option = lv_up+lv_char_index(1).
        lv_whole = lv_passwd && lv_option.
        APPEND lv_whole to mt_passwd.
        lv_char_index = lv_char_index + 1.
        write:lv_whole.
        new-line.
     ENDDO.

     clear lv_whole.
     lv_char_index = 0.
     DO lv_char_num times.
        lv_option = lv_low+lv_char_index(1).
        lv_whole = lv_passwd && lv_option.
        APPEND lv_whole to mt_passwd.
        lv_char_index = lv_char_index + 1.
        write:lv_whole.
        new-line.
     ENDDO.

     clear lv_whole.
     lv_char_index = 0.
     DO 10 times.
        lv_option = lv_num+lv_char_index(1).
        lv_whole = lv_passwd && lv_option.
        APPEND lv_whole to mt_passwd.
        lv_char_index = lv_char_index + 1.
        write:lv_whole.
        new-line.
     ENDDO.

  ENDIF.


endmethod.