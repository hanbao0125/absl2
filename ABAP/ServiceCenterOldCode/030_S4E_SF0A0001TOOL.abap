class name: SF0A0001TOOL
backup date: 2009-04-02

class /SF0A0001/TOOL definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/TOOL
*"* do not include other source files here!!!

  class-data LV_TEST type I .

  class-methods CHECK_NORMAL_BINDING
    importing
      !IN_NODE type ref to IF_IXML_NODE
      !IN_LOCATION type I .
  class-methods CHECK_SUBFORM_FLOW
    importing
      !IN_NODE type ref to IF_IXML_NODE
      !IN_LOCATION type I .
  class-methods GET_ESR_NAME
    importing
      !I_BO_NAME type STRING
      !I_BO_NODE_NAME type STRING
    exporting
      !E_ESR_BO_NAMESPACE type STRING
      !E_ESR_BO_NAME type STRING
      !E_ESR_BO_NODE_NAME type STRING .

method CHECK_NORMAL_BINDING.
  data lv_subform_name type string.
  data lv_bind_node type ref to if_ixml_node.
  data lv_map_path type string.

  call method /SF0A0001/FORM_TEST_TOOL=>GET_ATTR_VALUE
     exporting
       IN_XML_NODE = in_node
       in_attr_name = 'name'
     importing
       out_value = lv_subform_name.

  call method /SF0A0001/FORM_TEST_TOOL=>GET_NODE_BY_NAME
    exporting
      in_node_name = 'bind'
      in_parent = in_node
    importing
      out_child = lv_bind_node.

  if lv_bind_node is initial.
     write :/ 'Subform: ' , lv_subform_name , ' has normal mapping!'.
  endif.

endmethod.

method CHECK_SUBFORM_FLOW.
  data lv_presence type string.
  data lv_subform_name type string.
  data lv_layout_style type string.
  CONSTANTS: lv_top2bottom type string value 'tb',
             lv_western type string value 'lr-tb',
             lv_row type string value 'row'.
  call method /SF0A0001/FORM_TEST_TOOL=>GET_ATTR_VALUE
     exporting
       IN_XML_NODE = in_node
       in_attr_name = 'presence'
     importing
       out_value = lv_presence.

  if lv_presence is not initial.
     if lv_presence = 'hidden'.
        exit.
     endif.
  endif.

  call method /SF0A0001/FORM_TEST_TOOL=>GET_ATTR_VALUE
     exporting
       IN_XML_NODE = in_node
       in_attr_name = 'name'
     importing
       out_value = lv_subform_name.

  call method /SF0A0001/FORM_TEST_TOOL=>GET_ATTR_VALUE
     exporting
       IN_XML_NODE = in_node
       in_attr_name = 'layout'
     importing
       out_value = lv_layout_style.

  if lv_layout_style is initial.
     write :/ 'Subform: ' , lv_subform_name , ' does not set layout to FLOW!'.
     exit.
  endif.
  if lv_layout_style = lv_top2bottom OR lv_layout_style = lv_western
     OR lv_layout_style = lv_row.
     EXIT.
  else.
     write :/ 'Subform: ' , lv_subform_name , ' does not set layout to FLOW!'.
     exit.
  endif.

endmethod.

method GET_ESR_NAME.


  DATA: lp_lcp           TYPE REF TO if_esf_lcp,
        lp_lcp_facade    TYPE REF TO if_esf_lcp_facade,
        lp_bo_node_descr TYPE REF TO if_esf_bo_node_desc.

  DATA: ls_esr_name TYPE sesf_md_esr_name.

  DATA: lf_bo_name      TYPE string,
        lf_bo_node_name TYPE string,
        GP_BO_DESCR type ref to IF_ESF_BO_DESC.
* ---------------------------------------------------------------------

  CLEAR: e_esr_bo_namespace,
         e_esr_bo_name,
         e_esr_bo_node_name.

  TRY.
* ---------------------------------------------------------------------
* check current instance
* ---------------------------------------------------------------------
      IF gp_bo_descr IS BOUND.
        lf_bo_name = gp_bo_descr->get_proxy_name( ).
        IF lf_bo_name <> i_bo_name.
          CLEAR gp_bo_descr.
        ENDIF.
      ENDIF.

* ---------------------------------------------------------------------
* Get BO-Descriptior using lcp-facade
* ---------------------------------------------------------------------
      IF NOT gp_bo_descr IS BOUND.
        lp_lcp_facade = cl_esf_lcp_factory=>get_lcp_facade( ).
        gp_bo_descr = lp_lcp_facade->get_bo_descriptor( in_bo_proxy_name = i_bo_name ).
      ENDIF.

      ls_esr_name = gp_bo_descr->get_esr_name( ).
      e_esr_bo_namespace = ls_esr_name-esr_namespace.
      e_esr_bo_name = ls_esr_name-esr_name.

* ---------------------------------------------------------------------
* Get Node
* ---------------------------------------------------------------------
      IF NOT i_bo_node_name IS INITIAL.
        CLEAR ls_esr_name.
        lp_bo_node_descr = gp_bo_descr->get_bo_node_descriptor( BO_NODE_PROXY_NAME = i_bo_node_name ).
        CHECK lp_bo_node_descr IS BOUND.
        ls_esr_name = lp_bo_node_descr->get_esr_name( ).
        e_esr_bo_node_name = ls_esr_name-esr_name.
      ENDIF.

    CATCH cx_esf_metadata_error.
    CATCH cx_esf_core_service.
  ENDTRY.
ENDMETHOD.