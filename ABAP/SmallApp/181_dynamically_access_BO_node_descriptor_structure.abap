*&---------------------------------------------------------------------*
*& Report  Z_ACCESS_BO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_ACCESS_BO.

DATA in_lcp_facade TYPE REF TO if_esf_lcp_facade.
DATA lr_r TYPE REF TO if_esf_bo_desc.
DATA lr_node_descriptor TYPE REF TO if_esf_bo_node_desc.
DATA lr_structure TYPE REF TO if_esf_structure_desc.
DATA lr_type TYPE REF TO cl_abap_structdescr.
DATA lr_data TYPE REF TO data.
DATA lr_lcp TYPE REF TO if_esf_lcp.
DATA lt_node TYPE sesf_bo_node_id_tab.
APPEND '00145EF537661DDD819013977F51427C' TO lt_node.
CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
  RECEIVING
    out_lcp_facade = in_lcp_facade.

CALL METHOD in_lcp_facade->get_bo_node_table_container
  EXPORTING
    in_bo_name                  = 'APDL_OUTBOUND_DELIVERY'
    in_bo_node_name             = 'ROOT'
  RECEIVING
    out_bo_node_table_container = lr_data.

lr_lcp = in_lcp_facade->get_lcp( 'APDL_OUTBOUND_DELIVERY' ).

FIELD-SYMBOLS : <fs_data> TYPE any table,
                <fs_item> TYPE any.
ASSIGN lr_data->* TO <fs_data>.

DATA ls_meta TYPE IF_ESA_BUSINESS_OBJECT_MODEL=>TY_BUSINESS_OBJECT_METADATA.
DATA ls_node TYPE IF_ESA_BUSINESS_OBJECT_MODEL=>TY_NODE.
CALL METHOD CL_ESA_BUSINESS_OBJECT_API=>GET_BUSINESS_OBJECT_METADATA
   EXPORTING
     NAME = 'APDL_DELIVERY_TEMPLATE'
   RECEIVING
     METADATA = ls_meta.
READ TABLE ls_meta-NODES INTO ls_node WITH KEY HEADER-NODE_NAME = 'ROOT'.
DATA lt_root_node TYPE string.
DATA place1 TYPE string.
DATA place2 TYPE string.
DATA ls_root_node TYPE string.
ls_root_node = ls_node-HEADER-RUNTIME_TYPE.
SPLIT ls_root_node AT '=>' INTO place1 place2.
ls_root_node = ls_node-header-RUNTIME_TYPE.
CONCATENATE place1 '=>' 'TT_ROOT' INTO lt_root_node.
DATA y TYPE REF TO DATA.
DATA x TYPE REF TO DATA.
CREATE DATA y TYPE (lt_root_node).
CREATE DATA x TYPE (ls_root_node).

FIELD-SYMBOLS: <comp> TYPE any.
ASSIGN y->* to <fs_data>.
CALL METHOD lr_lcp->retrieve
  EXPORTING
    in_bo_node_name = 'ROOT'
    in_node_ids     = lt_node
  IMPORTING
    out_data        = <fs_data>.

LOOP AT <fs_data> REFERENCE INTO x.
   ASSIGN x->* TO <fs_item> CASTING TYPE (ls_root_node).
   ASSIGN COMPONENT 'ID-CONTENT' OF STRUCTURE <fs_item> TO <comp>.
   WRITE : 'ID:', <comp>.
ENDLOOP.