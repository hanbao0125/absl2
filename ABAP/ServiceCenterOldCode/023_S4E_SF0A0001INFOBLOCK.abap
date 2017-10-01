class name: SF0A0001INFOBLOCK
backup date: 2009-04-02

class /SF0A0001/INFOBLOCK definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/INFOBLOCK
*"* do not include other source files here!!!

  class-data LV_FOR_COPY type I .

  methods ASSIGN_TASK
    importing
      !IN_INFO_NODE type ref to IF_IXML_NODE .
  methods CHECK .

private section.
*"* private components of class /SF0A0001/INFOBLOCK
*"* do not include other source files here!!!

  data NODE type ref to IF_IXML_NODE .

method ASSIGN_TASK.
  node = in_info_node.
endmethod.

method CHECK.
  call method /SF0A0001/TOOL=>CHECK_SUBFORM_FLOW
    exporting
      in_node = node
      in_location = /SF0A0001/FORM_TEST_TOOL=>lv_info_location.

  call method /SF0A0001/TOOL=>CHECK_normal_binding
    exporting
      in_node = node
      in_location = /SF0A0001/FORM_TEST_TOOL=>lv_info_location.

endmethod.