class name: SF0A0001UI_TEXT_TOOL
backup date: 2009-04-02

class /SF0A0001/UI_TEXT_TOOL definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/UI_TEXT_TOOL
*"* do not include other source files here!!!

  class-data LV_TEST type I .

  class-methods DISPLAY .
  class-methods GET_DUMMY_BO_ID
    importing
      !IN_BO_NAME type SCOOLBUSINESSOBJECT
    exporting
      !OUT_BO_ID type CHAR32 .
  interface IF_ESF_FLAT_ATTRIBUTE_DESC load .
  class-methods GET_NAME_BY_ATTR
    importing
      !IM_BO_NODE_DESCRIPTOR type ref to IF_ESF_BO_NODE_DESC
      !IM_ATTR type IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR_TABLE .
  class-methods INIT .

private section.
*"* private components of class /SF0A0001/UI_TEXT_TOOL
*"* do not include other source files here!!!

  types:
    BEGIN OF ty_ui_text,
           bo_proxy_name TYPE string,
           ui_text TYPE string,
         END OF ty_ui_text .
  types:
    tt_ui_text TYPE standard TABLE OF ty_ui_text .

  class-data TT_TEXT type TT_UI_TEXT .

method DISPLAY.
  type-pools slis.
  DATA: ls_entry type ty_ui_text,
        ls_table_size type i,
        gr_alv type ref to cl_salv_table,
        column_table type ref to CL_SALV_COLUMNS_TABLE,
        column type ref to CL_SALV_COLUMN.

  IF tt_text IS INITIAL.
     EXIT.
  ENDIF.

  call method cl_salv_table=>factory
    importing
      r_salv_table   = gr_alv
    changing
      t_table        = tt_text.

  column_table = gr_alv->GET_COLUMNS( ).

  column = column_table->GET_COLUMN( COLUMNNAME = 'BO_PROXY_NAME' ).
  column->SET_MEDIUM_TEXT( text-001 ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 60 ).
  column = column_table->GET_COLUMN( COLUMNNAME = 'UI_TEXT' ).
  column->SET_OPTIMIZED( exporting value = 'X' ).
  column->SET_OUTPUT_LENGTH( exporting value = 60 ).
  column->SET_MEDIUM_TEXT( text-002 ).

  call method gr_alv->display.

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

method GET_NAME_BY_ATTR.
  DATA: ls_attributes type IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR,
        lo_ui_text_desc TYPE REF TO if_esf_ui_text_desc,
        lv_name type string,
        lv_text type string,
        lv_error type string,
        lv_node_name type string,
        ex TYPE REF TO cx_root,
        ls_entry type ty_ui_text,
        lv_has_ui_text type abap_bool.

  LOOP AT im_attr INTO ls_attributes.
      lv_has_ui_text = abap_true.
      lv_name = ls_attributes->IF_ESF_DESC~GET_PROXY_NAME( ).
      lv_node_name = im_bo_node_descriptor->IF_ESF_DESC~GET_PROXY_NAME( ).
      TRY.
         CALL METHOD im_bo_node_descriptor->if_esf_att_prop_container_desc~get_attrib_ui_text_desc
            EXPORTING
              attribute_proxy_name = lv_name
            RECEIVING
              ui_text_descriptor   = lo_ui_text_desc.
         CATCH cx_esf_metadata_error INTO ex.
            lv_error = ex->get_text( ).
            lv_has_ui_text = abap_false.
      ENDTRY.
      CHECK lv_has_ui_text = abap_true.
      TRY.
          CALL METHOD lo_ui_text_desc->get_text
            EXPORTING
               text_type = if_esf_ui_text_desc=>co_type_column_label
            RECEIVING
               text      = lv_text.
          CATCH cx_esf_metadata_error INTO ex.

      ENDTRY.
      CLEAR ls_entry.
      ls_entry-bo_proxy_name = lv_name.
      ls_entry-ui_text = lv_text.
      APPEND ls_entry to tt_text.

  ENDLOOP.
endmethod.

method INIT.
  DATA ls_header type ty_ui_text.
  ls_header-bo_proxy_name = text-001.
  ls_header-ui_text = text-002.
  APPEND ls_header to tt_text.
endmethod.