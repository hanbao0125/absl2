REPORT zactivate.

PARAMETERS: purl TYPE char32 OBLIGATORY LOWER CASE,
            subfold TYPE string OBLIGATORY LOWER CASE.

DATA: lv_content TYPE string,
      lt_node    TYPE zcl_jerry_tool=>tt_sorted_node,
      lv_number  TYPE int4,
      lv_size    TYPE int4,
      lv_total_size TYPE int8,
      lv_folder  TYPE string,
      lv_from    TYPE char32,
      lv_offset  TYPE int4,
      lv_index   TYPE int4 VALUE 1,
      lt_pic     TYPE string_table.
CONSTANTS: picture_name TYPE string value 'clipboard'.
CONSTANTS: folder  TYPE string VALUE 'C:\Users\i042416\Pictures\pic\',
           postfix TYPE string VALUE '></div><di'.

INITIALIZATION.
  GET PARAMETER ID 'ZNOTE_ID' FIELD lv_from.
  IF lv_from IS NOT INITIAL.
    purl = lv_from.
  ENDIF.

START-OF-SELECTION.
  DATA: lv_url TYPE string.
  lv_url = 'http://note.youdao.com/yws/public/note/' && purl && '?keyfrom=public'.
  SET PARAMETER ID 'ZNOTE_ID' FIELD purl.
  DATA(lv_post_len) = strlen( postfix ).

  lv_content = zcl_crm_cm_tool=>get_text_by_url( lv_url ).

  CALL METHOD zcl_jerry_tool=>parse_json_to_internal_table
    EXPORTING
      iv_json        = lv_content
    IMPORTING
      et_node        = lt_node
      ev_node_number = lv_number.

  ASSERT lv_number = 1.

  READ TABLE lt_node ASSIGNING FIELD-SYMBOL(<title>) WITH KEY attribute = 'tl'.
  ASSERT sy-subrc = 0.

  READ TABLE lt_node ASSIGNING FIELD-SYMBOL(<node>) WITH KEY attribute = 'content'.

  ASSERT sy-subrc = 0.

  SPLIT <node>-value AT space INTO TABLE DATA(lt_result).

  LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<entry>) WHERE table_line CS 'src='.
    lv_number = strlen( <entry> ) - 5. "src="
    DATA(url) = <entry>+5(lv_number).
    FIND FIRST OCCURRENCE OF `"` IN url match OFFSET lv_offset.
    IF sy-subrc = 0.
       url = url+0(lv_offset).
       APPEND url TO lt_pic.
    ENDIF.
  ENDLOOP.

  WRITE: / 'ok'.

  DATA(lv_total) = lines( lt_pic ).
  LOOP AT lt_pic ASSIGNING FIELD-SYMBOL(<pic>).
    lv_folder = folder && subfold && '\'.
    DATA(lv_name) = lv_folder && picture_name && lv_index && '.png'.
    DATA(lv_text) = 'Downloading file: ' && lv_name.
    DATA(lv_process) = lv_index * 100.
    DATA(lv_percent) = lv_process / lv_total.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_index * 100 / lv_total
        text       = lv_text.

    DATA(binary) = zcl_crm_cm_tool=>get_data_by_url( <pic> ).

    zcl_crm_cm_tool=>download_locally( iv_local_path = lv_name iv_binary = binary ).
    lv_total_size = lv_total_size + xstrlen( binary ).
    ADD 1 TO lv_index.
  ENDLOOP.

  WRITE: / 'totally ', lv_total, ' pictures downloaded successfully!' COLOR COL_NEGATIVE.

  DATA: ls_note TYPE crmd_prod_note.

  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_16 = ls_note-note_guid.
  ls_note-note_title = <title>-value.
  ls_note-pic_size = lv_total.
  ls_note-download_date = sy-datum.
  ls_note-download_time = sy-timlo.
  ls_note-total_size = lv_total_size / 1024.

  INSERT crmd_prod_note FROM ls_note.