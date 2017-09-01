*,---------------------------------------------------------------------*
*& Report  ZBOTEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbotest.

PARAMETERS: p_boname TYPE string DEFAULT 'SBTM_TASK'.

DATA:
      lv_name TYPE string,
  lr_bo_desc TYPE REF TO if_esf_bo_desc,
  lr_node_desc TYPE REF TO if_esf_bo_node_desc,
  lr_acl_dest TYPE REF TO if_esf_association_desc,
  mr_lcp_facade TYPE REF TO if_esf_lcp_facade.

mr_lcp_facade = cl_esf_lcp_factory=>get_lcp_facade( ).


lr_bo_desc = mr_lcp_facade->get_bo_descriptor( in_bo_proxy_name = p_boname ).
IF lr_bo_desc->has_rbam_acl_destin_assoc( ) NE space.
  lr_acl_dest = lr_bo_desc->get_rbam_acl_destin_assoc_desc( ).
  IF lr_acl_dest IS BOUND.
    lv_name = lr_acl_dest->get_proxy_name( ).
    WRITE: / lv_name.
    lr_node_desc = lr_acl_dest->get_target_bo_node_desc( ).
    lr_bo_desc   = lr_node_desc->get_bo_descriptor( ).
    lv_name = lr_bo_desc->get_proxy_name( ).
    WRITE: / lv_name.
    lv_name = lr_node_desc->get_proxy_name( ).
    WRITE: lv_name.
  ENDIF.
ENDIF.