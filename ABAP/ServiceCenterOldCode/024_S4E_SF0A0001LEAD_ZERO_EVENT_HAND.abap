class name: SF0A0001LEAD_ZERO_EVENT_HAND
backup date: 2009-04-02

class /SF0A0001/LEAD_ZERO_EVENT_HAND definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/LEAD_ZERO_EVENT_HAND
*"* do not include other source files here!!!

  class-data LV_TEST type I .

  methods ON_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .

private section.
*"* private components of class /SF0A0001/LEAD_ZERO_EVENT_HAND
*"* do not include other source files here!!!

  class-data LV_FOR_COPY type I .

  methods DISPLAY
    importing
      !IN_TITLE type STRING
      !IN_MSG1 type STRING
      !IN_MSG2 type STRING .

method ON_DOUBLE_CLICK.
  DATA: lv_path TYPE STRING,
        lv_node_name TYPE string,
        lv_parent_name TYPE string,
        lv_msgv1 TYPE string,
        lv_msgv2 TYPE string,
        lv_title TYPE string,
        lv_length TYPE i.
  CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_PATH_BY_ROW
    EXPORTING
      in_row = row
    IMPORTING
      out_path = lv_path
      out_node_name = lv_node_name
      out_parent_name = lv_parent_name.

  lv_title = /SF0A0001/LEAD_ZERO_TOOL=>lv_bo_name.
  lv_msgv1 = 'BO Node Name: ' && lv_node_name.
  lv_msgv2 = 'Full Path: ' && lv_path && '.' && lv_parent_name && '.' && lv_node_name.
  lv_length = strlen( lv_msgv2 ).
  IF lv_length <= 80.
    CALL FUNCTION 'POPUP_TO_INFORM'
       EXPORTING
         TITEL = lv_title
         TXT1 = lv_msgv1
         TXT2 = lv_msgv2.
  ELSE.
    CALL METHOD me->display
       EXPORTING
         in_title = lv_title
         in_msg1  = lv_msgv1
         in_msg2  = lv_msgv2.
  ENDIF.


endmethod.

method DISPLAY.
 DATA: total_length TYPE i,
       ls_table TYPE string_table,
       line1_total_length TYPE i,
       item_length TYPE i,
       item TYPE string,
       lv_index TYPE i VALUE 1,
       line1 TYPE string VALUE '',
       line2 TYPE string VALUE '',
       string_table_line_num TYPE i,
       left TYPE i.

 SPLIT in_msg2 AT '.' INTO TABLE ls_table.

 total_length = strlen( in_msg2 ).
 WHILE line1_total_length < 80.
   READ TABLE ls_table INTO item INDEX lv_index.
   item_length = strlen( item ).
   line1_total_length = line1_total_length + item_length.
   IF line1_total_length >= 80.
      EXIT.
   ENDIF.
   IF line1 <> ''.
      line1 = line1 && item && '.'.
   ELSE.
      line1 = line1 && item.
   ENDIF.
   lv_index = lv_index + 1.
 ENDWHILE.
 DESCRIBE TABLE ls_table LINES string_table_line_num.

 left = string_table_line_num - lv_index + 1.
 DO ( left - 1 ) TIMES.
    READ TABLE ls_table INTO item INDEX lv_index.
    line2 = line2 && item && '.'.
    lv_index = lv_index + 1.
 ENDDO.
 READ TABLE ls_table INTO item INDEX lv_index.
 line2 = line2 && item.

 CALL FUNCTION 'POPUP_TO_INFORM'
    EXPORTING
         TITEL = in_title
         TXT1 = in_msg1
         TXT2 = line1
         TXT3 = line2.

endmethod.