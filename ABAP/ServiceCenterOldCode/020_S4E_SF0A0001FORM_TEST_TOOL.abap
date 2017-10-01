class name: SF0A0001FORM_TEST_TOOL
backup date: 2009-04-02

class /SF0A0001/FORM_TEST_TOOL definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/FORM_TEST_TOOL
*"* do not include other source files here!!!

  class-data LV_DEFAULT_SUBFORM type I value 0. "#EC NOTEXT .
  class-data LV_INFO_LOCATION type I value 1. "#EC NOTEXT .
  class-data LV_FREE_LOCATION type I value 2. "#EC NOTEXT .
  class-data LV_SUMM_LOCATION type I value 3. "#EC NOTEXT .
  class-data LV_TABLE_LOCATION type I value 4. "#EC NOTEXT .
  class-data LV_FOOTER_LOCATION type I value 5. "#EC NOTEXT .
  class-data LV_TABLE_HEADER_LOCATION type I value 6. "#EC NOTEXT .
  class-data LV_TABLE_CONTENT_LOCATION type I value 7. "#EC NOTEXT .
  class-data LV_BODY_PAGE_LOCATION type I value 8. "#EC NOTEXT .

  class-methods GET_ATTR_VALUE
    importing
      !IN_XML_NODE type ref to IF_IXML_NODE
      !IN_ATTR_NAME type STRING
    exporting
      !OUT_VALUE type STRING .
  class-methods GET_NODE_BY_NAME
    importing
      !IN_NODE_NAME type STRING
      !IN_PARENT type ref to IF_IXML_NODE
    exporting
      !OUT_CHILD type ref to IF_IXML_NODE .
  class-methods GET_SUBFORM_LOCATION
    importing
      !IN_SUBFORM_NAME type STRING
    returning
      value(OUT_SUBFORM_TYPE) type I .
  class-methods TRAVERSE
    importing
      !IN_ROOT_NODE type ref to IF_IXML_NODE .
  class-methods GET_XML_NODE_NAME
    importing
      !IN_XML_NODE type ref to IF_IXML_NODE
    returning
      value(RET) type STRING .

private section.
*"* private components of class /SF0A0001/FORM_TEST_TOOL
*"* do not include other source files here!!!

  class-data LV_SUBFORM_NAMING type STRING value 'frm'. "#EC NOTEXT .
  class-data LV_INFO_NAMING type STRING value 'frminfo'. "#EC NOTEXT .
  class-data LV_FREE_NAMING type STRING value 'frmfree'. "#EC NOTEXT .
  class-data LV_SUMM_NAMING type STRING value 'frmsumm'. "#EC NOTEXT .
  class-data LV_TABLE_WRAPPER_NAMING type STRING value 'tbl'. "#EC NOTEXT .
  class-data LV_TABLE_HEADER_FORM_NAMING type STRING value 'hdr'. "#EC NOTEXT .
  class-data LV_TABLE_CONTENT_FORM_NAMING type STRING value 'row'. "#EC NOTEXT .
  class-data LV_TABLE_HEADER_CELL_NAMING type STRING value 'hdr'. "#EC NOTEXT .
  class-data LV_TABLE_COLUMN_NAMING type STRING value 'col'. "#EC NOTEXT .
  class-data LV_BODY_PAGE_NAMING type STRING value 'bdy'. "#EC NOTEXT .
  class-data LV_FOOTER_NAME type STRING value 'A1SFC_FooterBlock'. "#EC NOTEXT .
  class-data LV_TEMPLATE_NODE_NAME type STRING value 'template'. "#EC NOTEXT .
  class-data LV_SUBFORM_NODE_NAME type STRING value 'subform'. "#EC NOTEXT .
  class-data LV_PAGESET_NODE_NAME type STRING value 'pageSet'. "#EC NOTEXT .

  class-methods GET_SUBFORM_TYPE
    importing
      !IN_SUBFORM_NAME type STRING
    returning
      value(OUT_TYPE) type I .
  class-methods GET_SUBSTRING
    importing
      !IN_STRING type STRING
      !IN_START_POS type I
      !IN_END_POS type I
    exporting
      !OUT_VALUE type STRING .

method GET_ATTR_VALUE.
  DATA attr type ref to IF_IXML_NAMED_NODE_MAP.
  DATA name_node type ref to if_ixml_node.
  CHECK in_xml_node is not initial.

  attr = in_xml_node->GET_ATTRIBUTES( ).
  check attr is not initial.
  name_node = attr->GET_NAMED_ITEM( in_attr_name ).
  check name_node is not initial.
  out_value = name_node->GET_VALUE( ).
endmethod.

method GET_NODE_BY_NAME.
  DATA lt_child type ref to IF_IXML_NODE_LIST.
  DATA lv_length type i.
  DATA lv_index type i value 0.
  DATA lv_item type ref to IF_IXML_NODE.
  DATA lv_name type string.
  CHECK in_parent is not initial.
  lt_child = in_parent->GET_CHILDREN( ).
  lv_length = lt_child->GET_LENGTH( ).
  if lv_length <= 0.
     EXIT.
  else.
     do lv_length times.
        lv_item = lt_child->GET_ITEM( lv_index ).
     lv_name = lv_item->GET_NAME( ).
     write : / 'name:', lv_name.
     IF lv_name = in_node_name.
        out_child = lv_item.
        EXIT.
     ENDIF.
     lv_index = lv_index + 1.
     enddo.
  endif.
endmethod.

method GET_SUBFORM_LOCATION.
   data lv_first3_prefix type string.
   data lv_subform_type type i.
   IF in_subform_name IS initial.
      message 'Subform Name Empty!' type 'E'. "#EC NOTEXT
      EXIT.
   ENDIF.
   call method get_substring
     exporting
        in_string = in_subform_name
        in_start_pos = 0
        in_end_pos = 3
     importing
        out_value = lv_first3_prefix.
   IF lv_first3_prefix = lv_subform_naming.
      out_subform_type = get_subform_type( in_subform_name ).
      exit.
   elseif lv_first3_prefix = lv_table_wrapper_naming.
      IF in_subform_name CA lv_footer_name.
         out_subform_type = lv_footer_location.
      ELSE.
         out_subform_type = lv_table_location.
      ENDIF.
   elseif lv_first3_prefix = lv_table_header_form_naming.
      out_subform_type = lv_table_header_location.
   elseif lv_first3_prefix = lv_table_content_form_naming.
      out_subform_type = lv_table_content_location.
   elseif lv_first3_prefix = lv_body_page_naming.
      out_subform_type = lv_body_page_location.
   else.
      out_subform_type = lv_default_subform.
   endif.
endmethod.

method GET_XML_NODE_NAME.
   data name type string.
   IF in_xml_node is initial.
      ret = name.
      exit.
   else.
      ret = in_xml_node->GET_NAME( ).
   endif.
endmethod.

method TRAVERSE.
   " in_root_node: template!
  DATA lt_child type ref to IF_IXML_NODE_LIST.
  DATA lv_length type i.
  DATA lv_item type ref to IF_IXML_NODE.
  DATA lv_name type string.
  DATA lv_name_attr type string.
  DATA lv_subform_type type i.
  DATA lv_index type i value 0.
  DATA lo_info_checker type ref to /SF0A0001/INFOBLOCK.

  lt_child = in_root_node->GET_CHILDREN( ).
  lv_length = lt_child->GET_LENGTH( ).
  if lv_length <= 0.
     write : 'no child exists!'.
     exit.
  endif.

  do lv_length times.
     lv_item = lt_child->GET_ITEM( lv_index ).
     lv_name = lv_item->GET_NAME( ).
     if lv_name = lv_subform_node_name.
        call method get_attr_value
           exporting
             in_xml_node = lv_item
             in_attr_name = 'name'
           importing
             out_value = lv_name_attr.
        write : / 'name: ', lv_name_attr.
        lv_subform_type = get_subform_location( lv_name_attr ).
        case lv_subform_type.
           when lv_body_page_location.
              traverse( lv_item ).
           when lv_table_location.
              "handle table check
           when lv_info_location.
              create object lo_info_checker.
              lo_info_checker->assign_task( lv_item ).
              lo_info_checker->check( ).
              "handle info check
           when lv_free_location.
              "handle free check
           when lv_summ_location.
              "handle summary block
           when others.
              traverse( lv_item ).
        endcase.
     elseif lv_name = lv_pageset_node_name.
        "handle master page.
     endif.
     lv_index = lv_index + 1.
  enddo.
endmethod.

method GET_SUBFORM_TYPE.
  data lv_len type i.
  data lv_first7_prefix type string.
  lv_len = strlen( in_subform_name ).
  IF lv_len < 7.
     out_type = lv_default_subform.
     exit.
  endif.
  call method get_substring
    exporting
      in_string = in_subform_name
      in_start_pos = 0
      in_end_pos = 7
    importing
      out_value = lv_first7_prefix.
  if lv_first7_prefix = lv_info_naming.
      out_type = lv_info_location.
  elseif lv_first7_prefix = lv_free_naming.
      out_type = lv_free_location.
  elseif lv_first7_prefix = lv_summ_naming.
      out_type = lv_summ_location.
  else.
      out_type = lv_default_subform.
  endif.

endmethod.

method GET_SUBSTRING.
  check in_string is not initial.
  data len type i.
  data lv_sublen type i.
  len = strlen( in_string ).
  IF len <= 0.
     EXIT.
  ENDIF.
  IF in_end_pos > len.
     EXIT.
  ENDIF.
  lv_sublen = in_end_pos - in_start_pos.
  out_value = in_string+in_start_pos(lv_sublen).
  TRANSLATE out_value TO LOWER CASE.
endmethod.