class name:SF0A0001LEAD_ZERO_TOOL
backup date: 2009-04-02

class /SF0A0001/LEAD_ZERO_TOOL definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/LEAD_ZERO_TOOL
*"* do not include other source files here!!!

  class-data LV_BO_NAME type STRING .

  class-methods GET_PATH_BY_ROW
    importing
      !IN_ROW type SALV_DE_ROW
    exporting
      !OUT_PATH type STRING
      !OUT_NODE_NAME type STRING
      !OUT_PARENT_NAME type STRING .
  class-methods DISPLAY .
  class-methods GET_DUMMY_BO_ID
    importing
      !IN_BO_NAME type SCOOLBUSINESSOBJECT
    exporting
      !OUT_BO_ID type CHAR32 .
  interface IF_ESF_FLAT_ATTRIBUTE_DESC load .
  class-methods GET_LEAD_ZERO_SETTING
    importing
      !IM_BO_NODE_DESC type ref to IF_ESF_BO_NODE_DESC
      !IM_ATTR type IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR_TABLE .

private section.
*"* private components of class /SF0A0001/LEAD_ZERO_TOOL
*"* do not include other source files here!!!

  types:
    BEGIN OF ty_bo_info,
           bo_node_name TYPE string,
           bo_parent_name TYPE string,
         END OF ty_bo_info .
  types:
    BEGIN OF ty_bo_desc,
          bo_node_name TYPE string,
          bo_node_desc TYPE REF TO IF_ESF_BO_NODE_DESC,
         END OF ty_bo_desc .

  class-data GS_BO_INFO type TY_BO_INFO .
  class-data:
    gt_bo_info TYPE STANDARD TABLE OF ty_bo_info .
  class-data:
    gt_bo_desc TYPE STANDARD TABLE OF ty_bo_desc WITH KEY bo_node_name .
  class-data GS_BO_DESC type TY_BO_DESC .

  class-methods GET_FORMAT_PATH
    importing
      !IN_RAW_PATH type STRING
    exporting
      !OUT_FULL_PATH type STRING .
  class-methods GET_FULL_PATH
    importing
      !IN_BO_NAME type STRING
      !IN_BO_PARENT_NAME type STRING
    exporting
      !OUT_FULL_PATH type STRING .

method DISPLAY.
  TYPE-POOLS slis.
  DATA:
        ls_table_size TYPE i,
        gr_alv TYPE REF TO cl_salv_table,
        column_table TYPE REF TO CL_SALV_COLUMNS_TABLE,
        column TYPE REF TO CL_SALV_COLUMN,
        gr_events TYPE REF TO cl_salv_events_table,
        gr_selections TYPE REF TO cl_salv_selections,
        lo_event_handler TYPE REF TO /SF0A0001/LEAD_ZERO_EVENT_HAND.

  IF gt_bo_info IS INITIAL.
     EXIT.
  ENDIF.



  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table   = gr_alv
    CHANGING
      t_table        = gt_bo_info.

  CREATE OBJECT lo_event_handler.
  gr_events = gr_alv->get_event( ).
  SET HANDLER lo_event_handler->on_double_click FOR gr_events.

  column_table = gr_alv->GET_COLUMNS( ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'BO_NODE_NAME' ).
  column->SET_MEDIUM_TEXT( 'CHILD NODE' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 60 ).
  column = column_table->GET_COLUMN( COLUMNNAME = 'BO_PARENT_NAME' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 60 ).
  column->SET_MEDIUM_TEXT( 'PARENT NODE' ).

  CALL METHOD gr_alv->display.

endmethod.

method GET_DUMMY_BO_ID.
  DATA : in_lcp_facade TYPE REF TO if_esf_lcp_facade,
         lr_lcp TYPE REF TO if_esf_lcp,
         in_bo_proxy_name TYPE string,
         lo_bo_desc TYPE REF TO if_esf_bo_desc,
         lo_bo_rootnode_desc TYPE REF TO if_esf_bo_node_desc,
         lx_metadata_error TYPE REF TO cx_esf_metadata_error,
         get_bodesc_ex_text TYPE string,
         lv_root_node_name TYPE string,
         ls_query_options  TYPE  sesf_query_options,
         lt_requested_attributes  TYPE sesf_string_tab,
         lt_node_id TYPE sesf_bo_node_id_tab,
         ls_node_id TYPE sesf_bo_node_id,
         lx_consumer TYPE REF TO CX_ESF_LCP_CONSUMER_FAULT.


  in_bo_proxy_name = in_bo_name.
  lv_bo_name = in_bo_name.
  TRY.
    CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
       RECEIVING out_lcp_facade = in_lcp_facade.
    lr_lcp = in_lcp_facade->get_lcp( in_bo_proxy_name ).
    CATCH cx_esf_core_service.
      MESSAGE 'BO PROXY NAME INVALID,PLEASE CHECK!' TYPE 'E'.
  ENDTRY.

  TRY.
    CALL METHOD cl_esf_descriptor_factory=>get_bo_descriptor
          EXPORTING
            in_bo_proxy_name  = in_bo_proxy_name
          RECEIVING
            out_bo_descriptor = lo_bo_desc.
      CATCH cx_esf_metadata_error INTO lx_metadata_error.
        get_bodesc_ex_text = lx_metadata_error->get_text( ).
        get_bodesc_ex_text = 'Get BO Descriptor Error: ' && get_bodesc_ex_text.
        MESSAGE get_bodesc_ex_text TYPE 'E'.
   ENDTRY.

   CALL METHOD lo_bo_desc->get_root_bo_node_descriptor
      RECEIVING
        bo_node_descriptor = lo_bo_rootnode_desc.
   lv_root_node_name = lo_bo_rootnode_desc->get_proxy_name( ).
   APPEND 'NODE_ID' TO  lt_requested_attributes.
   ls_query_options-maximum_rows = 1.
   TRY.
     CALL METHOD lr_lcp->query
        EXPORTING
          in_bo_node_name         = lv_root_node_name
          in_query_name           = 'SELECT_ALL'
          in_query_options        = ls_query_options
        IMPORTING
          out_node_ids            = lt_node_id.
     CATCH CX_ESF_LCP_CONSUMER_FAULT INTO lx_consumer.
        RETURN.
   ENDTRY.
   IF lt_node_id IS INITIAL.
      RETURN.
   ENDIF.
   READ TABLE lt_node_id INTO ls_node_id INDEX 1.
   out_bo_id = ls_node_id.
endmethod.

method GET_LEAD_ZERO_SETTING.
  DATA: ls_attributes TYPE IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR,
        lr_ccts_type_desc TYPE REF TO IF_ESF_CCTS_TYPE_DESC,
        lr_type_desc TYPE REF TO IF_ESF_DESC,
        lx_move TYPE REF TO cx_sy_move_cast_error,
        lt_setting_table TYPE SESF_STRING_TAB,
        lm TYPE REF TO CX_ESF_METADATA_ERROR,
        lv_setting TYPE string,
        lv_name TYPE string,
        lv_node_name TYPE string,
        lr_parent_desc TYPE REF TO IF_ESF_BO_NODE_DESC.



  LOOP AT im_attr INTO ls_attributes.
      lr_type_desc = ls_attributes->GET_TYPE_DESC( ).
      lv_name = ls_attributes->IF_ESF_DESC~GET_PROXY_NAME( ).
      lv_node_name = im_bo_node_desc->IF_ESF_DESC~GET_PROXY_NAME( ).
      TRY.
        lr_ccts_type_desc ?= lr_type_desc.
      CATCH cx_sy_move_cast_error INTO lx_move.
         "should continue!
         CONTINUE.
      ENDTRY.
      CHECK lr_ccts_type_desc IS NOT INITIAL.
      TRY.
         CLEAR lt_setting_table.
         lt_setting_table = lr_ccts_type_desc->GET_TRANSFORMATION_DIRECTIVES( ).
         CHECK lt_setting_table IS NOT INITIAL.
         LOOP AT lt_setting_table INTO lv_setting.
            CHECK NOT ( lv_setting CA 't' ).
            "WRITE:/ lv_setting, lv_name,lv_node_name.
            CLEAR gs_bo_info.
            CLEAR lr_parent_desc.
            CLEAR gs_bo_desc.
            gs_bo_desc-bo_node_name = lv_name && lv_node_name.
            gs_bo_desc-bo_node_desc = im_bo_node_desc.
            APPEND gs_bo_desc TO gt_bo_desc.

            gs_bo_info-bo_node_name = lv_name.
            gs_bo_info-bo_parent_name = lv_node_name.
            APPEND gs_bo_info TO gt_bo_info.

         ENDLOOP.
        CATCH CX_ESF_METADATA_ERROR INTO lm.
      ENDTRY.
  ENDLOOP.
endmethod.

method GET_PATH_BY_ROW.
   CLEAR gs_bo_info.
   READ TABLE gt_bo_info INTO gs_bo_info INDEX in_row.
   CHECK sy-subrc = 0.

   CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_FULL_PATH
      EXPORTING
         IN_BO_NAME = gs_bo_info-bo_node_name
         IN_BO_PARENT_NAME = gs_bo_info-bo_parent_name
      IMPORTING
         OUT_FULL_PATH = out_path.
   out_node_name = gs_bo_info-bo_node_name.
   out_parent_name = gs_bo_info-bo_parent_name.

endmethod.

method GET_FORMAT_PATH.
  DATA: lt_path TYPE string_table,
        line_num TYPE i,
        item TYPE string,
        temp TYPE i,
        lv_full_path TYPE string VALUE ''.

  SPLIT in_raw_path AT '$' INTO TABLE lt_path.
  DESCRIBE TABLE lt_path LINES line_num.

  temp = line_num.
  DO ( line_num - 1 ) TIMES.
    READ TABLE lt_path INTO item INDEX temp.
    lv_full_path = lv_full_path && item && '.'.
    temp = temp - 1.
  ENDDO.
  READ TABLE lt_path INTO item INDEX 1.
  out_full_path = lv_full_path && item.
endmethod.

method GET_FULL_PATH.
  DATA: lv_key TYPE string,
        lv_error TYPE string,
        lr_parent_desc TYPE REF TO IF_ESF_BO_NODE_DESC,
        lv_parent_name TYPE string,
        lv_full_path TYPE string,
        lm TYPE REF TO CX_ESF_METADATA_ERROR.

  CLEAR gs_bo_desc.
  lv_key = in_bo_name && in_bo_parent_name.
  READ TABLE gt_bo_desc INTO gs_bo_desc WITH TABLE KEY BO_NODE_NAME = lv_key.
  IF sy-subrc <> 0.
     lv_error = 'CANNOT Find Descriptor for BO Node: ' && in_bo_name.
     MESSAGE lv_error TYPE 'E'.
  ENDIF.

  TRY.
    lr_parent_desc = gs_bo_desc-bo_node_desc->GET_PARENT_BO_NODE_DESCRIPTOR( ).
     WHILE lr_parent_desc IS NOT INITIAL.
        lv_parent_name = lr_parent_desc->IF_ESF_DESC~GET_PROXY_NAME( ).
        lv_full_path = lv_full_path && lv_parent_name && '$'.
        lr_parent_desc = lr_parent_desc->GET_PARENT_BO_NODE_DESCRIPTOR( ).
     ENDWHILE.
  CATCH CX_ESF_METADATA_ERROR INTO lm.
     CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_FORMAT_PATH
      EXPORTING
        in_raw_path = lv_full_path
      IMPORTING
        out_full_path = out_full_path.
  ENDTRY.
  CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_FORMAT_PATH
    EXPORTING
       in_raw_path = lv_full_path
    IMPORTING
       out_full_path = out_full_path.
endmethod.