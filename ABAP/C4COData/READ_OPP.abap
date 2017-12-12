*&---------------------------------------------------------------------*
*& Report  ZJERRY_READ_OPP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zjerry_read_opp.

DATA(lo_lcp_facade) = cl_esf_lcp_factory=>get_lcp_facade( ).

DATA(lo_lcp) = lo_lcp_facade->get_lcp( 'OPPORTUNITY' ).
DATA: lt_data TYPE if_apcrm_opportunity=>tt_root,
      lt_parameter TYPE sesf_selection_parameters_tab.

DATA(ls_para) = VALUE sesf_selection_parameter( attribute_name = 'ID-CONTENT' sign = 'I' option = 'EQ' low = '15360' ).
APPEND ls_para TO lt_parameter.
lo_lcp->query(
  EXPORTING
    in_bo_node_name          = 'ROOT'
    in_query_name            = 'QUERY_BY_ELEMENTS'
    in_selection_parameters  = lt_parameter
     in_fill_data             = abap_true
  IMPORTING
     out_data                 = lt_data ).

DATA(line) = lines( lt_data ).

WRITE:/ line.