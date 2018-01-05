class CL_HOME_SCHEMA_TOOL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_hierarchy,
        id          TYPE char18,
        level       TYPE int4,
        description TYPE bezei40,
      END OF ty_hierarchy .
  types:
    tt_hierarchy TYPE STANDARD TABLE OF ty_hierarchy WITH KEY id .
  types:
    BEGIN OF ty_displayed_node,
        id   TYPE char18,
        text TYPE char40,
      END OF ty_displayed_node .

  methods DRAW_TREE .
  methods GET_FIELDCAT_BY_DATA
    importing
      !IS_DATA type ANY
    returning
      value(RT_FIELDCAT) type LVC_T_FCAT .
  methods GET_TREE
    returning
      value(RO_TREE) type ref to CL_GUI_ALV_TREE .
  methods GET_HIERARCHY_DATA
    importing
      !IV_SCHEMA_ID type STRING
    returning
      value(RT_DATA) type TT_HIERARCHY .
  methods EXPAND .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_node_relation,
        node_id    TYPE char18,
        node_level TYPE int4, " current level of node_id
        parent     TYPE char18,
      END OF ty_node_relation .
  types:
    tt_node_relation TYPE STANDARD TABLE OF ty_node_relation WITH KEY node_id .
  types:
    BEGIN OF ty_tree_key,
        node_id  TYPE char18,
        tree_key TYPE lvc_nkey,
      END OF ty_tree_key .
  types:
    tt_tree_key TYPE STANDARD TABLE OF ty_tree_key WITH KEY node_id .

  data MV_ROOT_KEY type LVC_NKEY .
  data MT_NODE_RELATION type TT_NODE_RELATION .
  data MO_TREE type ref to CL_GUI_ALV_TREE .
  data MT_HIERARCHY type TT_HIERARCHY .
  constants CV_ROOT_ID type STRING value 'ROOT' ##NO_TEXT.

  methods GET_CONTAINER
    importing
      !IV_CONTAINER_NAME type CHAR30
    returning
      value(RO_CONTAINER) type ref to CL_GUI_CUSTOM_CONTAINER .
  methods RENDER_TREE .
  methods GET_DISPLAYED_TEXT
    importing
      !IV_NODE_ID type CHAR18
    returning
      value(RV_TEXT) type CHAR40 .
  methods HANDLE_CATEGORY
    importing
      !IO_CATEGORY type ref to CL_CRM_BOL_ENTITY
      !IV_PARENT_ID type STRING .
ENDCLASS.



CLASS CL_HOME_SCHEMA_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method CL_HOME_SCHEMA_TOOL->DRAW_TREE
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD DRAW_TREE.
    render_tree( ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method CL_HOME_SCHEMA_TOOL->EXPAND
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD EXPAND.
    mo_tree->expand_node( i_node_key = mv_root_key i_expand_subtree = abap_true ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method CL_HOME_SCHEMA_TOOL->GET_CONTAINER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CONTAINER_NAME              TYPE        CHAR30
* | [<-()] RO_CONTAINER                   TYPE REF TO CL_GUI_CUSTOM_CONTAINER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_CONTAINER.
    CREATE OBJECT ro_container
      EXPORTING
        container_name              = iv_container_name
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc <> 0.
      MESSAGE x208(00) WITH 'ERROR'(100).
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method CL_HOME_SCHEMA_TOOL->GET_DISPLAYED_TEXT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_NODE_ID                     TYPE        CHAR18
* | [<-()] RV_TEXT                        TYPE        CHAR40
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_DISPLAYED_TEXT.
    READ TABLE mt_hierarchy ASSIGNING FIELD-SYMBOL(<data>) WITH KEY id = iv_node_id.
    CHECK sy-subrc = 0.
    rv_text = <data>-description.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method CL_HOME_SCHEMA_TOOL->GET_FIELDCAT_BY_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_DATA                        TYPE        ANY
* | [<-()] RT_FIELDCAT                    TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_FIELDCAT_BY_DATA.
    DATA: lobj_stdesc TYPE REF TO cl_abap_structdescr,
          lv_stname   TYPE dd02l-tabname,
          lw_fields   TYPE LINE OF cl_abap_structdescr=>included_view,
          lw_fldcat   TYPE LINE OF lvc_t_fcat,
          lw_desc     TYPE x030l,
          lt_fields   TYPE cl_abap_structdescr=>included_view.
    lobj_stdesc ?= cl_abap_structdescr=>describe_by_data( is_data ).

    IF lobj_stdesc->is_ddic_type( ) IS NOT INITIAL.
      lv_stname = lobj_stdesc->get_relative_name( ).
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_buffer_active        = space
          i_structure_name       = lv_stname
          i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = rt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      RETURN.
    ENDIF.

    lt_fields = lobj_stdesc->get_included_view( ).

    LOOP AT lt_fields INTO lw_fields.
      CLEAR: lw_fldcat,
             lw_desc.
      lw_fldcat-col_pos   = sy-tabix.
      lw_fldcat-fieldname = lw_fields-name.
      IF lw_fields-type->is_ddic_type( ) IS NOT INITIAL.
        lw_desc            = lw_fields-type->get_ddic_header( ).
        lw_fldcat-rollname = lw_desc-tabname.
      ELSE.
        lw_fldcat-inttype  = lw_fields-type->type_kind.
        lw_fldcat-intlen   = lw_fields-type->length.
        lw_fldcat-decimals = lw_fields-type->decimals.
      ENDIF.
      APPEND lw_fldcat TO rt_fieldcat.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method CL_HOME_SCHEMA_TOOL->GET_HIERARCHY_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_SCHEMA_ID                   TYPE        STRING
* | [<-()] RT_DATA                        TYPE        TT_HIERARCHY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_HIERARCHY_DATA.

    CLEAR: mt_node_relation, mt_hierarchy.

    DATA(lo_bol_core) = cl_crm_bol_core=>get_instance( ).
    DATA: lt_query_parameter TYPE crmt_name_value_pair_tab,
          ls_query_parameter LIKE LINE OF lt_query_parameter,
          lv_view_name       TYPE crmt_view_name.

    lo_bol_core->load_component_set( 'GS_MCAT' ).

    lo_bol_core->start_up( ).

    ls_query_parameter-name = 'ASP_ID'.
    ls_query_parameter-value = iv_schema_id.
    APPEND ls_query_parameter TO lt_query_parameter.

    ls_query_parameter-name = 'ASP_STATE'.
    ls_query_parameter-value = 'V'.
    APPEND ls_query_parameter TO lt_query_parameter.

    TRY.
        DATA(lo_collection) = lo_bol_core->query(
            iv_query_name               = 'MC_QuerySchemaByAttributes'
            it_query_params             = lt_query_parameter
            iv_view_name                = lv_view_name ).
      CATCH cx_root INTO DATA(cx_root).
        WRITE:/ 'Error:', cx_root->get_text( ).
        RETURN.
    ENDTRY.

    DATA(lo_entity) = lo_collection->get_current( ).

    WHILE lo_entity IS NOT INITIAL.
      DATA(lo_1st_category) = lo_entity->get_related_entities( iv_relation_name = 'MC_CategoryRel' ).

      DATA(lo_1st_iter) = lo_1st_category->get_iterator( ).

      DATA(lo_1st_leaf) = lo_1st_iter->get_first( ).

      WHILE lo_1st_leaf IS NOT INITIAL.
        DATA(lv_id) = lo_1st_leaf->get_property_as_string( 'CAT_ID' ).
        DATA(lv_label) = lo_1st_leaf->get_property_as_string( 'CAT_LABL' ).
        APPEND INITIAL LINE TO mt_node_relation ASSIGNING FIELD-SYMBOL(<relation>).
        APPEND INITIAL LINE TO mt_hierarchy ASSIGNING FIELD-SYMBOL(<hierarchy>).
        <relation> = VALUE #( node_id = lv_id node_level = 1 parent = cv_root_id ).
        <hierarchy> = VALUE #( id = lv_id level = 1 description = lv_label ).
        handle_category( io_category = lo_1st_leaf iv_parent_id = lv_id ).

        lo_1st_leaf = lo_1st_iter->get_next( ).
      ENDWHILE.

      lo_entity = lo_collection->get_next( ).
    ENDWHILE.

   rt_data = MT_HIERARCHY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method CL_HOME_SCHEMA_TOOL->GET_TREE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_TREE                        TYPE REF TO CL_GUI_ALV_TREE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_TREE.
    CREATE OBJECT ro_tree
      EXPORTING
        parent                      = get_container( 'CCONTAINER1' )
        node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
        item_selection              = 'X'
        no_html_header              = 'X'
        no_toolbar                  = ''
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        illegal_node_selection_mode = 5
        failed                      = 6
        illegal_column_name         = 7.
    IF sy-subrc <> 0.
      MESSAGE x208(00) WITH 'ERROR'.                        "#EC NOTEXT
    ENDIF.

    mo_tree = ro_tree.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method CL_HOME_SCHEMA_TOOL->HANDLE_CATEGORY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_CATEGORY                    TYPE REF TO CL_CRM_BOL_ENTITY
* | [--->] IV_PARENT_ID                   TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD HANDLE_CATEGORY.

    CHECK io_category IS NOT INITIAL.
    DATA(lo_children) = io_category->get_related_entities( iv_relation_name = 'MC_TreeChildRel' ).
    CHECK lo_children->size( ) > 0.

    DATA(lo_child) = lo_children->get_first( ).

    WHILE lo_child IS NOT INITIAL.
      DATA(lv_cat_id) = lo_child->get_property_as_string( 'CAT_ID' ).
      DATA(lv_cat_level) = lo_child->get_property_as_string( 'CAT_LEVEL' ).
      DATA(lv_cat_label) = lo_child->get_property_as_string( 'CAT_LABL' ).
      APPEND INITIAL LINE TO mt_node_relation ASSIGNING FIELD-SYMBOL(<relation>).
      <relation> = VALUE #( node_id = lv_cat_id node_level = lv_cat_level parent = iv_parent_id ).
      APPEND INITIAL LINE TO mt_hierarchy ASSIGNING FIELD-SYMBOL(<hierarchy>).
      <hierarchy> = VALUE #( id = lv_cat_id level = lv_cat_level description = lv_cat_label ).

      handle_category( io_category = lo_child iv_parent_id = lv_cat_id ).
      lo_child = lo_children->get_next( ).
    ENDWHILE.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method CL_HOME_SCHEMA_TOOL->RENDER_TREE
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD RENDER_TREE.
    DATA: p_relat_key  TYPE lvc_nkey,
          lt_tree_key  TYPE tt_tree_key,
          ls_displayed TYPE ty_displayed_node.
    CALL METHOD mo_tree->add_node
      EXPORTING
        i_relat_node_key = p_relat_key
        i_relationship   = cl_gui_column_tree=>relat_last_child
        i_node_text      = 'Hierarchy'
      IMPORTING
        e_new_node_key   = mv_root_key.

    DATA(ls_tree_key) = VALUE ty_tree_key( node_id = 'ROOT' tree_key = mv_root_key ).
    APPEND ls_tree_key TO lt_tree_key.

    SORT mt_node_relation BY node_level ASCENDING.

    LOOP AT mt_node_relation ASSIGNING FIELD-SYMBOL(<node1>).
      ls_displayed-id = <node1>-node_id.
      ls_displayed-text = get_displayed_text( <node1>-node_id ).
      READ TABLE lt_tree_key ASSIGNING FIELD-SYMBOL(<parent>) WITH KEY node_id = <node1>-parent.
      CALL METHOD mo_tree->add_node
        EXPORTING
          i_relat_node_key = <parent>-tree_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = CONV #( <node1>-node_id )
          is_outtab_line   = ls_displayed
        IMPORTING
          e_new_node_key   = p_relat_key.

      ls_tree_key = VALUE #( node_id = <node1>-node_id tree_key = p_relat_key ).
      APPEND ls_tree_key TO lt_tree_key.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.