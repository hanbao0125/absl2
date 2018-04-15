REPORT zjianshu.

PARAMETERS: subfold TYPE string OBLIGATORY LOWER CASE.

DATA: lv_content    TYPE string,
      lv_total      TYPE int4,
      lv_number     TYPE int4,
      lv_size       TYPE int4,
      lv_total_size TYPE int8,
      lv_folder     TYPE string,
      lv_index      TYPE int4 VALUE 1,
      lt_pic        TYPE string_table.
CONSTANTS: picture_name TYPE string VALUE 'clipboard'.
CONSTANTS: folder  TYPE string VALUE 'C:\Users\i042416\Pictures\pic\'.

START-OF-SELECTION.

  lt_pic = zcl_crm_cm_tool=>get_pic_from_clipboard( ).
  lv_total = lines( lt_pic ).
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
    ADD 1 TO lv_index.
  ENDLOOP.

  WRITE: / 'totally ', lv_total, ' pictures downloaded successfully!' COLOR COL_NEGATIVE.