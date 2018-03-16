FIELD-SYMBOLS:
    <lt_node> TYPE ANY TABLE.

  DATA(lo_node) = cl_esf_bo_access=>get_node_table_container( iv_bo_name = iv_bo_name iv_node_name = iv_node_name ).
  ASSIGN lo_node->* TO <lt_node>.

  cl_esf_bo_access=>retrieve(
    EXPORTING
      iv_bo_name                 = iv_bo_name
      iv_node_name               = iv_node_name
      it_node_id                 = VALUE #( ( iv_node_id ) )
    IMPORTING
      et_data                    = <lt_node> ).
