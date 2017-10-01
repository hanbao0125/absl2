*&---------------------------------------------------------------------*
*& Report  Z_EXTRACT_BYD_OBJ_METADATA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_EXTRACT_BYD_OBJ_METADATA.

TYPE-POOLS: abap, ixml.

CONSTANTS: gc_utf8 TYPE abap_encod VALUE '4110',
           gc_pgmid_r3tr TYPE pgmid VALUE 'R3TR',
           gc_tabl TYPE string VALUE 'TABL',
           gc_cobo TYPE string VALUE 'COBO',
           gc_eew0 TYPE string VALUE 'EEW0',
           gc_eew2 TYPE string VALUE 'EEW2',
           gc_eew4 TYPE string VALUE 'EEW4',
           gc_gfsv TYPE string VALUE 'GFSV',
           gc_gfsq TYPE string VALUE 'GFSQ',
           gc_diob TYPE string VALUE 'DIOB',
           gc_dods TYPE string VALUE 'DODS',
           gc_dise TYPE string VALUE 'DISE',
           gc_dcub TYPE string VALUE 'DCUB',
           gc_dhyb TYPE string VALUE 'DHYB',
           gc_dalv TYPE string VALUE 'DALV',
           gc_dmpr TYPE string VALUE 'DMPR'.

PARAMETER p_input TYPE string.
PARAMETER p_output TYPE string.

DATA: gv_sys_timezone TYPE ttzcu-tzonesys.

************************************************************************************
************************************************************************************
* Type Definition
************************************************************************************
************************************************************************************
TYPES: BEGIN OF byd_object,
    name TYPE sobj_name,
    type TYPE trobjtype,
  END OF byd_object.

TYPES: byd_object_tab TYPE TABLE OF byd_object WITH KEY name type.

************Types for TABL******************************************************
TYPES: BEGIN OF structure_field,
          fieldname TYPE fieldname,
          leng      TYPE ddleng,
          decimals  TYPE decimals,
          datatype  TYPE dynptype,
          rollname  TYPE rollname,
          lfieldname  TYPE fnam_____4,
  END OF structure_field.

TYPES: structure_field_tab TYPE TABLE OF structure_field WITH KEY lfieldname.

TYPES: BEGIN OF structure_desc,
    name TYPE string,
    fields TYPE structure_field_tab,
  END OF structure_desc.
*********************************************************************************

************Types for COBO******************************************************
TYPES: BEGIN OF business_object_node,
    name TYPE string,
    checksum TYPE string,
    structure_desc TYPE structure_desc,
  END OF business_object_node.

TYPES: business_object_node_tab TYPE TABLE OF business_object_node WITH KEY name.

TYPES: BEGIN OF business_object_desc,
    name TYPE string,
    business_object_nodes TYPE business_object_node_tab,
  END OF business_object_desc.
*********************************************************************************

"Added by William, type used to collect nodes for InfoProvider
************Types for IP******************************************************
TYPES: BEGIN OF ip_node,
    name TYPE string,
    iskey TYPE string,
    isnavatr TYPE string,
  END OF ip_node.

TYPES: ip_node_tab TYPE TABLE OF ip_node WITH KEY name.

TYPES: BEGIN OF ip_desc,
    name TYPE string,
    ip_nodes TYPE ip_node_tab,
  END OF ip_desc.
*********************************************************************************

TYPES: BEGIN OF byd_obj_metadata,
    name TYPE string,
    type TYPE string,
    changed_by TYPE string,
    changed_at TYPE timestamp,
    checksum TYPE string,
    structure_desc TYPE structure_desc,
    business_object_desc TYPE business_object_desc,
"Added by William, InfoProvider subnodes
    ip_desc TYPE ip_desc,
  END OF byd_obj_metadata.

TYPES: byd_obj_metadata_tab TYPE TABLE OF byd_obj_metadata WITH KEY name type.

TYPES: BEGIN OF byd_component,
    name TYPE string,
    release TYPE string,
    extrelease TYPE string,
    byd_objs TYPE byd_obj_metadata_tab,
  END OF byd_component.

TYPES: byd_component_tab TYPE TABLE OF byd_component WITH KEY name.

TYPES: BEGIN OF cpms_byd_objects,
      created_by TYPE string,
      created_at TYPE timestamp,
      system TYPE string,
      components TYPE byd_component_tab,
    END OF cpms_byd_objects.


TYPES: x_line(80) TYPE x.
TYPES: x_line_tab TYPE TABLE OF x_line.

************************************************************************************
************************************************************************************
* Interface/Class Definition
************************************************************************************
************************************************************************************

*----------------------------------------------------------------------*
*       INTERFACE if_byd_obj_metadata
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
INTERFACE if_byd_obj_metadata.
  METHODS get_metadata
    IMPORTING
      iv_name TYPE string
      iv_type TYPE string
    RETURNING value(es_metadata) TYPE byd_obj_metadata.

ENDINTERFACE.                    "if_byd_obj_metadata

*----------------------------------------------------------------------*
*       CLASS cl_metadata_serializer DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_metadata_serializer DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS serialize_to_xml
      IMPORTING
        io_document TYPE REF TO if_ixml_document
        is_metadata TYPE byd_obj_metadata
      RETURNING value(io_element) TYPE REF TO if_ixml_element.
ENDCLASS.                    "cl_metadata_serializer DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_metadata_serializer IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_metadata_serializer IMPLEMENTATION.
  METHOD serialize_to_xml.
    DATA: lv_timestamp_str TYPE string.
    PERFORM convert_timestamp_to_str
      USING is_metadata-changed_at
      CHANGING lv_timestamp_str.

    io_element = io_document->create_element(
                    name = 'OBJECT '
                  ).
    io_element->set_attribute(
      name = 'NAME'
      value = is_metadata-name
    ).
    io_element->set_attribute(
      name = 'TYPE'
      value = is_metadata-type
    ).
    io_element->set_attribute(
      name = 'CHANGED_BY'
      value = is_metadata-changed_by
    ).
    io_element->set_attribute(
      name = 'CHANGED_AT'
      value = lv_timestamp_str
    ).

    IF is_metadata-checksum IS NOT INITIAL.
      io_element->set_attribute(
        name = 'CHECKSUM'
        value = is_metadata-checksum
      ).
    ENDIF.

    "Serialize message type (TABL)
    IF is_metadata-structure_desc IS NOT INITIAL.
      DATA: lo_structure_element TYPE REF TO if_ixml_element.

      PERFORM populate_structure_element
        USING io_document
              is_metadata-structure_desc
        CHANGING
          lo_structure_element.

      io_element->append_child(
        new_child = lo_structure_element
      ).
    ENDIF.

    "Serialize business object (COBO)
    IF is_metadata-business_object_desc IS NOT INITIAL.
      DATA: lo_bo_element TYPE REF TO if_ixml_element.

      PERFORM populate_bo_element
        USING io_document
              is_metadata-business_object_desc
        CHANGING
          lo_bo_element.

      io_element->append_child(
        new_child = lo_bo_element
      ).
    ENDIF.

    "Added by William, Serialize BI InfoProvider object
    IF is_metadata-ip_desc IS NOT INITIAL.
      DATA: lo_ip_element TYPE REF TO if_ixml_element.

      PERFORM populate_bi_element
        USING io_document
              is_metadata-ip_desc
        CHANGING
          lo_ip_element.

      io_element->append_child(
        new_child = lo_ip_element
      ).
    ENDIF.

  ENDMETHOD.                    "serialize_to_xml
ENDCLASS.                    "cl_metadata_serializer IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_tabl_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_tabl_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_tabl_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_tabl_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_tabl_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: ls_dd02l TYPE dd02l,
          lv_timestamp TYPE timestamp,
          lv_data TYPE string,
          lv_hash TYPE char32.

    SELECT SINGLE * FROM dd02l INTO ls_dd02l
      WHERE tabname = iv_name.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.
    es_metadata-changed_by = ls_dd02l-as4user.
    CONVERT DATE ls_dd02l-as4date TIME ls_dd02l-as4time INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
    es_metadata-changed_at = lv_timestamp.

    es_metadata-structure_desc-name = iv_name.

    PERFORM flatten_structure
      USING iv_name
            ''
      CHANGING es_metadata-structure_desc-fields.

    "Generate md5
    CALL TRANSFORMATION id SOURCE fields = es_metadata-structure_desc-fields
                         RESULT XML lv_data OPTIONS xml_header = 'full'.

    CALL FUNCTION 'MD5_CALCULATE_HASH_FOR_CHAR'
      EXPORTING
        data           = lv_data
      IMPORTING
        hash           = lv_hash
      EXCEPTIONS
        internal_error = 1.

    IF sy-subrc EQ 0.
      es_metadata-checksum = lv_hash.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata

ENDCLASS.                    "cl_tabl_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_cobo_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_cobo_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_cobo_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_cobo_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_cobo_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: lv_bo_name TYPE scoolbusinessobject,
          lv_timestamp TYPE timestamp,
          ls_metadata TYPE if_esa_business_object_model=>ty_business_object_metadata,
          lt_node TYPE sesf_api_bo_node_table,
          lr_node TYPE REF TO sesf_api_bo_node,
          lt_bo_node_checksum TYPE TABLE OF char32,
          lv_bo_checksum TYPE char32.

    lv_bo_name = iv_name.
    ls_metadata = cl_esa_business_object_api=>get_business_object_metadata(
                name = lv_bo_name
              ).
    lt_node = ls_metadata-nodes.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.
    IF ls_metadata-header-changedby IS NOT INITIAL.
      es_metadata-changed_by = ls_metadata-header-changedby.
    ELSE.
      es_metadata-changed_by = ls_metadata-header-author.
    ENDIF.
    IF ls_metadata-header-changedon IS NOT INITIAL.
      CONVERT DATE ls_metadata-header-changedon TIME ls_metadata-header-changedon_time INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
    ELSE.
      CONVERT DATE ls_metadata-header-createdon TIME ls_metadata-header-createdon_time INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
    ENDIF.
    es_metadata-changed_at = lv_timestamp.

    es_metadata-business_object_desc-name = iv_name.

    "Get metadata for each bo node
    LOOP AT lt_node REFERENCE INTO lr_node.
      DATA: ls_business_node TYPE business_object_node,
            ls_node_header TYPE scol_bo_node_header,
            lv_data TYPE string,
            lv_hash TYPE char32.

      CLEAR: ls_business_node, ls_node_header.

      ls_node_header = lr_node->header.
      ls_business_node-name = ls_node_header-node_name.
      ls_business_node-structure_desc-name = ls_node_header-data_structure.

      PERFORM flatten_structure
        USING ls_business_node-structure_desc-name
              ''
        CHANGING ls_business_node-structure_desc-fields.

      CALL TRANSFORMATION id SOURCE fields = ls_business_node-structure_desc-fields
                               RESULT XML lv_data OPTIONS xml_header = 'full'.

      CALL FUNCTION 'MD5_CALCULATE_HASH_FOR_CHAR'
        EXPORTING
          data           = lv_data
        IMPORTING
          hash           = lv_hash
        EXCEPTIONS
          internal_error = 1.

      IF sy-subrc EQ 0.
        ls_business_node-checksum = lv_hash.
        APPEND lv_hash TO lt_bo_node_checksum.
      ENDIF.

      APPEND ls_business_node TO es_metadata-business_object_desc-business_object_nodes.
    ENDLOOP.

    CALL FUNCTION 'MD5_CALCULATE_HASH_FOR_CHAR'
      IMPORTING
        hash           = lv_bo_checksum
      TABLES
        data_tab       = lt_bo_node_checksum
      EXCEPTIONS
        internal_error = 1.

    IF sy-subrc EQ 0.
      es_metadata-checksum = lv_bo_checksum.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata

ENDCLASS.                    "cl_cobo_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_eew0_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_eew0_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_eew0_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_eew0_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_eew0_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: lv_timestamp TYPE timestamp.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.

    DATA: ls_data TYPE eewdb_rgincl,
          lv_name TYPE eewdb_rgincl-prx_dtype_name.

    lv_name = iv_name.
    SELECT SINGLE * FROM eewdb_rgincl INTO ls_data
      WHERE prx_dtype_name = lv_name.

    IF ls_data IS NOT INITIAL.
      es_metadata-changed_by = ls_data-ch_user.
      CONVERT DATE ls_data-ch_date INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
      es_metadata-changed_at = lv_timestamp.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata
ENDCLASS.                    "cl_eew0_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_eew2_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_eew2_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_eew2_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_eew2_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_eew2_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: lv_timestamp TYPE timestamp.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.

    DATA: ls_data TYPE eewdb_rgdflow,
          lv_name TYPE eewdb_rgdflow-data_flow.

    lv_name = iv_name.
    SELECT SINGLE * FROM eewdb_rgdflow INTO ls_data
             WHERE data_flow = lv_name.

    IF ls_data IS NOT INITIAL.
      es_metadata-changed_by = ls_data-chguser.
      CONVERT DATE ls_data-chgdat TIME ls_data-chgtim INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
      es_metadata-changed_at = lv_timestamp.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata
ENDCLASS.                    "cl_eew2_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_eew4_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_eew4_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_eew4_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_eew4_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_eew4_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: lv_timestamp TYPE timestamp.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.

    DATA: ls_data TYPE eewdb_rgrelation,
          lv_name TYPE eewdb_rgrelation-group_name.

    lv_name = iv_name.
    SELECT SINGLE * FROM eewdb_rgrelation INTO ls_data
             WHERE group_name = lv_name.

    IF ls_data IS NOT INITIAL.
      es_metadata-changed_by = ls_data-chguser.
      CONVERT DATE ls_data-chgdat TIME ls_data-chgtim INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
      es_metadata-changed_at = lv_timestamp.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata
ENDCLASS.                    "cl_eew4_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_GFSV_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_gfsv_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_GFSV_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_GFSV_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_gfsv_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: lv_timestamp TYPE timestamp,
          lo_fsi_services TYPE REF TO cl_fsi_services.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.

    DATA: ls_data TYPE sfsg_def_d.
    CREATE OBJECT lo_fsi_services.
    ls_data = lo_fsi_services->get_sfs_view(
                iv_view = iv_name
              ).

    IF ls_data IS NOT INITIAL.
      es_metadata-changed_by = ls_data-changedby.
      CONVERT DATE ls_data-changeddate TIME ls_data-changedtime INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
      es_metadata-changed_at = lv_timestamp.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata
ENDCLASS.                    "cl_GFSV_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_GFSQ_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_gfsq_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_GFSQ_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_GFSQ_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_gfsq_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA: lv_timestamp TYPE timestamp,
          lo_fsi_services TYPE REF TO cl_fsi_services.

    es_metadata-name = iv_name.
    es_metadata-type = iv_type.

    DATA: ls_data TYPE sfsg_qr_def.
    CREATE OBJECT lo_fsi_services.
    ls_data = lo_fsi_services->get_sfs_query(
                iv_query_id = iv_name
              ).

    IF ls_data IS NOT INITIAL.
      es_metadata-changed_by = ls_data-changedby.
      CONVERT DATE ls_data-changeddate TIME ls_data-changedtime INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
      es_metadata-changed_at = lv_timestamp.
    ENDIF.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata
ENDCLASS.                    "cl_GFSQ_metadata IMPLEMENTATION

"Added by William, Class used to handle BI objects
*----------------------------------------------------------------------*
*       CLASS cl_bi_metadata DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_bi_metadata DEFINITION.
  PUBLIC SECTION.
    INTERFACES if_byd_obj_metadata.
ENDCLASS.                    "cl_bi_metadata DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_bi_metadata IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_bi_metadata IMPLEMENTATION.
  METHOD if_byd_obj_metadata~get_metadata.
    DATA:
          ls_object TYPE rso_s_tlogo,
          owner TYPE rsowner,
          lo_r_repository TYPE REF TO cl_rso_repository,
          ls_objlogsys TYPE logsys,
          lt_tlogoprop TYPE rso_t_tlogoprop,
          ls_tlogoprop LIKE LINE OF lt_tlogoprop.

    lo_r_repository = cl_rso_repository=>get_repository( ).
    ls_objlogsys = cl_rso_repository=>get_logical_system_self( ).
    lt_tlogoprop = cl_rso_repository=>get_tlogo_bi( i_with_d_version_only = rs_c_true ).

    CLEAR es_metadata.
    es_metadata-name = iv_name.
    es_metadata-type = iv_type.

    READ TABLE lt_tlogoprop INTO ls_tlogoprop WITH KEY tlogo_d = iv_type.
    IF sy-subrc <> 0.
      CLEAR es_metadata.
      RETURN.
    ENDIF.

    ls_object-tlogo = ls_tlogoprop-tlogo.
    ls_object-objnm = iv_name.
    CALL METHOD lo_r_repository->get_properties_of_object
      EXPORTING
        i_s_object       = ls_object
        i_objvers        = rs_c_objvers-delivery
        i_objlogsys      = ls_objlogsys
      IMPORTING
        e_conttimestmp   = es_metadata-changed_at
        e_owner          = owner
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      CLEAR es_metadata.
      RETURN.
    ENDIF.
    es_metadata-changed_by = owner.
    IF iv_type <> gc_diob AND iv_type <> gc_dods AND iv_type <> gc_dise AND iv_type <> gc_dcub AND iv_type <> gc_dhyb AND iv_type <> gc_dalv AND iv_type <> gc_dmpr.
      RETURN.
    ENDIF.

    "InfoProvider
    DATA:
          lo_rsd_dta TYPE REF TO cl_rsd_dta,
          ls_dta TYPE rsd_s_dta,
          ls_tlogo TYPE rstlogo,
          ls_io_type TYPE rsrequtype,
          lt_dta_iobj TYPE rsd_t_dta_iobj,
          lt_dta_pro TYPE rsd_t_dta_pro,
          ls_dta_pro LIKE LINE OF lt_dta_pro,
          lt_iobj_cmp TYPE rsd_t_iobj_cmp,
          lt_dta_dime TYPE rsd_t_dta_dime,
          lt_dta_dime_iobj TYPE rsd_t_dta_dime_iobj,
          ls_ip_node TYPE ip_node,
          lv_data TYPE string,
          lv_hash TYPE char32.

    CALL METHOD cl_rsd_dta=>factory
      EXPORTING
        i_infoprov = ls_object-objnm(30)
      RECEIVING
        r_r_dta    = lo_rsd_dta
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      CLEAR es_metadata.
      RETURN.
    ENDIF.
    es_metadata-ip_desc-name = iv_name.
    CALL METHOD lo_rsd_dta->if_rsd_dta~dta_get_info
      EXPORTING
        i_objvers         = rs_c_objvers-delivery
        i_with_atr_nav    = rs_c_true
        i_with_meta_iobj  = rs_c_false
        i_dta_view        = if_rsd_dta=>view_infoprovider
      IMPORTING
        e_s_dta           = ls_dta
        e_tlogo           = ls_tlogo
        e_io_type         = ls_io_type
        e_t_dta_iobj      = lt_dta_iobj
        e_t_dta_pro       = lt_dta_pro
        e_t_iobj_cmp      = lt_iobj_cmp
        e_t_dta_dime      = lt_dta_dime
        e_t_dta_dime_iobj = lt_dta_dime_iobj
      EXCEPTIONS
        dta_not_found     = 1
        iobj_not_found    = 2
        objvers_invalid   = 3
        OTHERS            = 4.
    IF sy-subrc <> 0.
      CLEAR es_metadata.
      RETURN.
    ENDIF.
    LOOP AT lt_dta_pro INTO ls_dta_pro WHERE iobjtp <> 'DPA'.
      ls_ip_node-name = ls_dta_pro-iobjnm.
      ls_ip_node-iskey = ls_dta_pro-keyflag.
      ls_ip_node-isnavatr = ls_dta_pro-atrnavfl.
      APPEND ls_ip_node TO es_metadata-ip_desc-ip_nodes.
    ENDLOOP.
    CALL TRANSFORMATION id SOURCE fields = es_metadata-ip_desc RESULT XML lv_data OPTIONS xml_header = 'full'.
    CALL FUNCTION 'MD5_CALCULATE_HASH_FOR_CHAR'
      EXPORTING
        data           = lv_data
      IMPORTING
        hash           = lv_hash
      EXCEPTIONS
        no_data        = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    es_metadata-checksum = lv_hash.
  ENDMETHOD.                    "if_byd_obj_metadata~get_metadata
ENDCLASS.                    "cl_bi_metadata IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS cl_metadata_object_factory DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_metadata_object_factory DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS class_constructor.

    CLASS-METHODS get_metadata_object
      IMPORTING
        iv_type TYPE string
      RETURNING value(eo_object) TYPE REF TO if_byd_obj_metadata.

  PRIVATE SECTION.
    TYPES: BEGIN OF type_tab_entry,
        type TYPE string,
        instance TYPE REF TO if_byd_obj_metadata,
      END OF type_tab_entry.
    TYPES: type_tab TYPE HASHED TABLE OF type_tab_entry WITH UNIQUE KEY type.

    CLASS-DATA: ct_type TYPE type_tab.
ENDCLASS.                    "cl_metadata_object_factory DEFINITION

*----------------------------------------------------------------------*
*       CLASS cl_metadata_object_factory IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_metadata_object_factory IMPLEMENTATION.
  METHOD class_constructor.
    DATA: ls_type_tab_entry TYPE type_tab_entry,
          lo_instance TYPE REF TO if_byd_obj_metadata.

    ls_type_tab_entry-type = gc_tabl.
    CREATE OBJECT lo_instance TYPE cl_tabl_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    ls_type_tab_entry-type = gc_cobo.
    CREATE OBJECT lo_instance TYPE cl_cobo_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    ls_type_tab_entry-type = gc_eew0.
    CREATE OBJECT lo_instance TYPE cl_eew0_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    ls_type_tab_entry-type = gc_eew2.
    CREATE OBJECT lo_instance TYPE cl_eew2_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    ls_type_tab_entry-type = gc_eew4.
    CREATE OBJECT lo_instance TYPE cl_eew4_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    ls_type_tab_entry-type = gc_gfsv.
    CREATE OBJECT lo_instance TYPE cl_gfsv_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    ls_type_tab_entry-type = gc_gfsq.
    CREATE OBJECT lo_instance TYPE cl_gfsq_metadata.
    ls_type_tab_entry-instance = lo_instance.
    INSERT ls_type_tab_entry INTO TABLE ct_type.
    CLEAR: ls_type_tab_entry, lo_instance.

    "Added by William, add BI object types, D version object types is used
    DATA:
          lt_tlogoprop TYPE rso_t_tlogoprop,
          ls_tlogoprop LIKE LINE OF lt_tlogoprop.
    lt_tlogoprop = cl_rso_repository=>get_tlogo_bi( i_with_d_version_only = rs_c_true ).
    LOOP AT lt_tlogoprop INTO ls_tlogoprop.
      ls_type_tab_entry-type = ls_tlogoprop-tlogo_d.
      CREATE OBJECT lo_instance TYPE cl_bi_metadata.
      ls_type_tab_entry-instance = lo_instance.
      INSERT ls_type_tab_entry INTO TABLE ct_type.
      CLEAR: ls_type_tab_entry, lo_instance.
    ENDLOOP.
  ENDMETHOD.                    "class_constructor

  METHOD get_metadata_object.
    DATA: ls_type_tab_entry TYPE type_tab_entry,
          lo_instance TYPE REF TO if_byd_obj_metadata.

    READ TABLE ct_type INTO ls_type_tab_entry WITH TABLE KEY type = iv_type.
    IF sy-subrc EQ 0.
      eo_object = ls_type_tab_entry-instance.
    ENDIF.
  ENDMETHOD.                    "get_metadata_object
ENDCLASS.                    "cl_metadata_object_factory IMPLEMENTATION


************************************************************************************
************************************************************************************
* Subroutine Definition
************************************************************************************
************************************************************************************
*&---------------------------------------------------------------------*
*&      Form  byd_objects_upload
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_FILE        text
*      -->CT_BYD_OBJECT  text
*----------------------------------------------------------------------*
FORM byd_objects_upload
  USING iv_file TYPE string
  CHANGING
    cv_parsing_error TYPE abap_bool
    ct_byd_object TYPE byd_object_tab.

  DATA:
    lt_data        TYPE TABLE OF string.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = iv_file
      codepage = gc_utf8
    TABLES
      data_tab = lt_data
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc <> 0.
    cv_parsing_error = abap_true.
    RETURN.
  ENDIF.

  IF sy-subrc = 0.
    PERFORM deserialize_byd_objects
      USING lt_data
      CHANGING
        cv_parsing_error
        ct_byd_object.
  ENDIF.
ENDFORM.                    "byd_objects_upload

*&---------------------------------------------------------------------*
*&      Form  deserialize_byd_objects
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->CV_BYD_OBJECTS  text
*----------------------------------------------------------------------*
FORM deserialize_byd_objects
  USING it_data TYPE string_table
  CHANGING
    cv_parsing_error TYPE abap_bool
    ct_byd_object TYPE byd_object_tab.

  DATA: lv_data TYPE string,
        lo_ixml TYPE REF TO if_ixml,
        lo_document  TYPE REF TO if_ixml_document,
        lo_encoding TYPE REF TO if_ixml_encoding,
        lo_stream_factory TYPE REF TO if_ixml_stream_factory,
        lo_istream TYPE REF TO if_ixml_istream,
        lo_parser TYPE REF TO if_ixml_parser,
        lo_objects_element TYPE REF TO if_ixml_element,
        lo_obj_collection TYPE REF TO if_ixml_node_collection,
        lo_obj_node TYPE REF TO if_ixml_node,
        lo_obj_attrs TYPE REF TO if_ixml_named_node_map,
        lo_obj_name_attr TYPE REF TO if_ixml_node,
        lo_obj_type_attr TYPE REF TO if_ixml_node,
        ls_byd_object TYPE byd_object.

  FIELD-SYMBOLS: <fs_data> TYPE string.

  LOOP AT it_data ASSIGNING <fs_data>.
    lv_data = lv_data && <fs_data>.
  ENDLOOP.

  lo_ixml = cl_ixml=>create( ).
  lo_document = lo_ixml->create_document( ).

  lo_stream_factory = lo_ixml->create_stream_factory( ).
  lo_istream = lo_stream_factory->create_istream_string(
                  string = lv_data
               ).

  lo_parser = lo_ixml->create_parser(
                stream_factory = lo_stream_factory
                istream = lo_istream
                document = lo_document
              ).

  IF lo_parser->parse( ) NE 0.
    cv_parsing_error = abap_true.
    RETURN.
  ELSE.
    cv_parsing_error = abap_false.
  ENDIF.

  lo_istream->close( ).

  "Find OBJECTS element.
  lo_objects_element = lo_document->find_from_name(
                  name = 'OBJECTS'
               ).

  IF lo_objects_element IS NOT INITIAL.
    DATA: lv_index TYPE i VALUE 0,
          lv_length TYPE i.

    "Get all BYD_OBJECT element.
    lo_obj_collection = lo_objects_element->get_elements_by_tag_name(
                          name = 'BYD_OBJECT'
                        ).
    lv_length = lo_obj_collection->get_length( ).

    WHILE lv_index LT lv_length.
      lo_obj_node = lo_obj_collection->get_item(
                      index = lv_index
                    ).

      lo_obj_attrs = lo_obj_node->get_attributes( ).

      "Get value of NAME
      lo_obj_name_attr = lo_obj_attrs->get_named_item(
                            name = 'NAME'
                          ).
      ls_byd_object-name = lo_obj_name_attr->get_value( ).

      "Get value of TYPE
      lo_obj_type_attr = lo_obj_attrs->get_named_item(
                            name = 'TYPE'
                          ).
      ls_byd_object-type = lo_obj_type_attr->get_value( ).

      APPEND ls_byd_object TO ct_byd_object.

      lv_index = lv_index + 1.
    ENDWHILE.
  ELSE.
    "Added by William, handle if lable "OBJECTS" is not found
    cv_parsing_error = abap_true.
    RETURN.
  ENDIF.
ENDFORM.                    "deserialize_byd_objects

*&---------------------------------------------------------------------*
*&      Form  cpms_byd_objects_download
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_FILE              text
*      -->IS_CPMS_BYD_OBJECTS  text
*----------------------------------------------------------------------*
FORM byd_objects_metadata_download
  USING iv_file TYPE string
        is_byd_objects_metadata TYPE cpms_byd_objects
  CHANGING cv_serialize_error TYPE abap_bool.

  DATA: lt_data TYPE x_line_tab.

  PERFORM serialize_byd_objects_metadata
    USING is_byd_objects_metadata
    CHANGING lt_data.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename          = iv_file
      filetype          = 'BIN'
      codepage          = gc_utf8
      confirm_overwrite = abap_true
    TABLES
      data_tab          = lt_data
    EXCEPTIONS
      OTHERS            = 1.

  IF sy-subrc <> 0.
    cv_serialize_error = abap_true.
  ELSE.
    cv_serialize_error = abap_false.
  ENDIF.
ENDFORM.                    "cpms_byd_objects_download

*&---------------------------------------------------------------------*
*&      Form  serialize_cpms_byd_objects
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IS_CPMS_BYD_OBJECTS  text
*      -->CV_DATA              text
*----------------------------------------------------------------------*
FORM serialize_byd_objects_metadata
  USING is_byd_objects_metadata TYPE cpms_byd_objects
  CHANGING ct_data TYPE x_line_tab.

  DATA: lo_ixml TYPE REF TO if_ixml,
        lo_document  TYPE REF TO if_ixml_document,
        lo_stream_factory TYPE REF TO if_ixml_stream_factory,
        lo_ostream TYPE REF TO if_ixml_ostream,
        lo_renderer TYPE REF TO if_ixml_renderer,
        lo_encoding TYPE REF TO if_ixml_encoding,
        lo_parent_element TYPE REF TO if_ixml_element,
        lo_components_element TYPE REF TO if_ixml_element,
        lo_element TYPE REF TO if_ixml_element,
        lv_result TYPE i.

  lo_ixml = cl_ixml=>create( ).
  lo_document = lo_ixml->create_document( ).
  lo_encoding = lo_ixml->create_encoding(
                  character_set = 'utf-8'
                  byte_order = -1
                ).

  "Start to populate XML document
  lo_element = lo_document->create_element(
                  name = 'CPMS_BYD_OBJECTS'
               ).

  lo_document->append_child(
    new_child = lo_element
  ).

  lo_parent_element = lo_element.

  lo_element = lo_document->create_element(
                  name = 'CREATED_BY'
                ).
  lo_element->set_value(
    value = is_byd_objects_metadata-created_by
  ).
  lo_parent_element->append_child(
    new_child = lo_element
  ).

  DATA: lv_timestamp_str TYPE string.

  PERFORM convert_timestamp_to_str
    USING is_byd_objects_metadata-created_at
    CHANGING lv_timestamp_str.

  lo_element = lo_document->create_element(
                  name = 'CREATED_AT'
                ).
  lo_element->set_value(
    value = lv_timestamp_str
  ).
  lo_parent_element->append_child(
    new_child = lo_element
  ).

  lo_element = lo_document->create_element(
                  name = 'SYSTEM'
                ).
  lo_element->set_value(
    value = is_byd_objects_metadata-system
  ).
  lo_parent_element->append_child(
    new_child = lo_element
  ).

  lo_element = lo_document->create_element(
                  name = 'SOFTWARE_COMPONENTS'
                ).
  lo_parent_element->append_child(
    new_child = lo_element
  ).

  lo_components_element = lo_element.

  DATA: lr_component TYPE REF TO byd_component.
  LOOP AT is_byd_objects_metadata-components REFERENCE INTO lr_component.
    lo_element = lo_document->create_element(
                  name = 'COMPONENT'
                ).
    lo_element->set_attribute(
      name = 'NAME'
      value = lr_component->name
    ).
    lo_element->set_attribute(
      name = 'RELEASE'
      value = lr_component->release
    ).
    lo_element->set_attribute(
      name = 'EXTRELEASE'
      value = lr_component->extrelease
    ).
    lo_components_element->append_child(
      new_child = lo_element
    ).

    lo_parent_element = lo_element.
    DATA: ls_byd_obj TYPE byd_obj_metadata.
    LOOP AT lr_component->byd_objs INTO ls_byd_obj.

      lo_element = cl_metadata_serializer=>serialize_to_xml(
        io_document = lo_document
        is_metadata = ls_byd_obj
      ).

      lo_parent_element->append_child(
        new_child = lo_element
      ).
    ENDLOOP.
  ENDLOOP.

  "Generate output data
  lo_stream_factory = lo_ixml->create_stream_factory( ).
  lo_ostream = lo_stream_factory->create_ostream_itable(
                  table = ct_data
                ).

  lo_ostream->set_encoding(
    encoding = lo_encoding
  ).

  lo_renderer = lo_ixml->create_renderer(
                document = lo_document
                ostream = lo_ostream
              ).

  lo_renderer->set_normalizing( ).
  lo_renderer->render( ).

  lo_ostream->close( ).
ENDFORM.                    "serialize_cpms_byd_objects


*&---------------------------------------------------------------------*
*&      Form  flatten_structure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_NAME    text
*      -->IV_PREFIX  text
*      -->CT_FIELD   text
*----------------------------------------------------------------------*
FORM flatten_structure
  USING iv_name TYPE string
        iv_prefix TYPE string
  CHANGING ct_field TYPE structure_field_tab.

  DATA: lo_data_descr TYPE REF TO cl_abap_datadescr,
        lo_elem_descr TYPE REF TO cl_abap_elemdescr,
        lo_struct_descr TYPE REF TO cl_abap_structdescr,
        lo_table_descr TYPE REF TO cl_abap_tabledescr,
        lo_class_descr TYPE REF TO cl_abap_classdescr,
        lt_field TYPE ddfields,
        ls_field TYPE dfies,
        lt_struct_field TYPE structure_field_tab,
        lt_tab_struct_field TYPE structure_field_tab,
        lv_tab_line_type TYPE string,
        lv_prefix TYPE string,
        ls_struct_field TYPE structure_field.

  FIELD-SYMBOLS: <fs_struct_field> TYPE structure_field.

  lo_struct_descr ?= cl_abap_typedescr=>describe_by_name( iv_name ).

  lt_field = lo_struct_descr->get_ddic_field_list( p_including_substructres = abap_true ).

  LOOP AT lt_field INTO ls_field.
    CLEAR: ls_struct_field.
    IF ls_field-rollname NE 'PRXCTRLTAB'. "get rid of field CONTROL
      MOVE-CORRESPONDING ls_field TO ls_struct_field.
      APPEND ls_struct_field TO lt_struct_field.

      IF ls_field-datatype EQ 'TTYP'. "flatten table line type
        lo_table_descr ?= cl_abap_typedescr=>describe_by_name( ls_field-rollname ).

        lo_data_descr = lo_table_descr->get_table_line_type( ).
        lo_class_descr ?= cl_abap_typedescr=>describe_by_object_ref( lo_data_descr ).

        lv_tab_line_type = lo_data_descr->get_relative_name( ).

        lv_prefix = iv_prefix && ls_field-lfieldname && '-'.

        IF lo_class_descr->get_relative_name( ) EQ 'CL_ABAP_STRUCTDESCR'.
          lo_struct_descr ?= lo_data_descr.
          PERFORM flatten_structure
            USING lv_tab_line_type
                  lv_prefix
            CHANGING lt_tab_struct_field.

          LOOP AT lt_tab_struct_field ASSIGNING <fs_struct_field>.
            <fs_struct_field>-lfieldname = lv_prefix && <fs_struct_field>-fieldname.
          ENDLOOP.

          APPEND LINES OF lt_tab_struct_field TO lt_struct_field.
        ELSE.
          DATA: ls_elem_field TYPE dfies,
                ls_elem_struct_field TYPE structure_field.

          lo_elem_descr ?= lo_data_descr.
          ls_elem_field = lo_elem_descr->get_ddic_field( ).

          MOVE-CORRESPONDING ls_elem_field TO ls_elem_struct_field.
          ls_elem_struct_field-lfieldname = lv_prefix && ls_elem_struct_field-fieldname.

          APPEND ls_elem_struct_field TO lt_struct_field.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  ct_field = lt_struct_field.

ENDFORM.                    "flatten_structure

*&---------------------------------------------------------------------*
*&      Form  convert_timestamp_to_str
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_TIMESTAMP  text
*      -->CV_RESULT     text
*----------------------------------------------------------------------*
FORM convert_timestamp_to_str
  USING iv_timestamp TYPE timestamp
  CHANGING cv_result TYPE string.

  DATA: lv_char14(14) TYPE c.

  WRITE iv_timestamp TO lv_char14 NO-GROUPING NO-ZERO.
  cv_result = lv_char14.
ENDFORM.                    "convert_timestamp_to_str

*&---------------------------------------------------------------------*
*&      Form  populate_structure_element
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IO_DOCUMENT          text
*      -->IS_STRUCTURE         text
*      -->CO_STURCTURE_ELMENT  text
*----------------------------------------------------------------------*
FORM populate_structure_element
  USING io_document TYPE REF TO if_ixml_document
        is_structure TYPE structure_desc
  CHANGING co_sturcture_elment TYPE REF TO if_ixml_element.

  DATA:
            lo_field_element TYPE REF TO if_ixml_element,
            lr_field TYPE REF TO structure_field.

  co_sturcture_elment = io_document->create_element(
                           name = 'STRUCTURE'
                         ).
  co_sturcture_elment->set_attribute(
   name = 'NAME'
   value =  is_structure-name
 ).

  LOOP AT is_structure-fields REFERENCE INTO lr_field.
    DATA: lv_field_name TYPE string,
          lv_field_type TYPE string,
          lv_field_ddic TYPE string,
          lv_field_length TYPE string,
          lv_field_decimals TYPE string.

    lv_field_name = lr_field->lfieldname.
    lv_field_type = lr_field->datatype.
    lv_field_ddic = lr_field->rollname.
    lv_field_length = lr_field->leng.
    lv_field_decimals = lr_field->decimals.

    lo_field_element = io_document->create_element(
                          name = 'FIELD'
                        ).
    lo_field_element->set_attribute(
      name = 'NAME'
      value = lv_field_name
    ).
    lo_field_element->set_attribute(
      name = 'TYPE'
      value = lv_field_type
    ).

    IF lr_field->rollname IS NOT INITIAL.
      lo_field_element->set_attribute(
        name = 'DDIC'
        value = lv_field_ddic
      ).
    ENDIF.

    IF lr_field->leng IS NOT INITIAL.
      lo_field_element->set_attribute(
        name = 'LENG'
        value = lv_field_length
      ).
    ENDIF.

    IF lr_field->decimals IS NOT INITIAL.
      lo_field_element->set_attribute(
        name = 'DECIMALS'
        value = lv_field_decimals
      ).
    ENDIF.

    co_sturcture_elment->append_child(
      new_child = lo_field_element
    ).
  ENDLOOP.

ENDFORM.                    "populate_structure_element

*&---------------------------------------------------------------------*
*&      Form  populate_bo_element
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IO_DOCUMENT         text
*      -->IS_BUSINESS_OBJECT  text
*      -->CO_BO_ELEMENT       text
*----------------------------------------------------------------------*
FORM populate_bo_element
  USING io_document TYPE REF TO if_ixml_document
        is_business_object TYPE business_object_desc
  CHANGING co_bo_element TYPE REF TO if_ixml_element.

  DATA: lr_bo_node TYPE REF TO business_object_node.

  co_bo_element = io_document->create_element(
                           name = 'BUSINESS_OBJECT'
                         ).
  co_bo_element->set_attribute(
    name = 'NAME'
    value = is_business_object-name
  ).

  LOOP AT is_business_object-business_object_nodes REFERENCE INTO lr_bo_node.
    DATA: lo_bo_node_element TYPE REF TO if_ixml_element,
          lo_structure_element TYPE REF TO if_ixml_element.
    lo_bo_node_element = io_document->create_element(
                            name = 'BO_NODE'
                          ).

    lo_bo_node_element->set_attribute(
      name = 'NAME'
      value = lr_bo_node->name
    ).
    lo_bo_node_element->set_attribute(
      name = 'CHECKSUM'
      value = lr_bo_node->checksum
    ).

    PERFORM populate_structure_element
      USING io_document
            lr_bo_node->structure_desc
      CHANGING lo_structure_element.

    lo_bo_node_element->append_child(
      new_child = lo_structure_element
    ).

    co_bo_element->append_child(
      new_child = lo_bo_node_element
    ).
  ENDLOOP.
ENDFORM.                    "populate_bo_element

*&---------------------------------------------------------------------*
*&      Form  populate_bi_element
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IO_DOCUMENT    text
*      -->IP_OBJECT      text
*      -->CO_IP_ELEMENT  text
*----------------------------------------------------------------------*
FORM populate_bi_element
  USING io_document TYPE REF TO if_ixml_document
        ip_object TYPE ip_desc
  CHANGING co_ip_element TYPE REF TO if_ixml_element.

  DATA:
        lo_bi_node_element TYPE REF TO if_ixml_element,
        lr_ip_node TYPE REF TO ip_node.

  co_ip_element = io_document->create_element( name = 'SUBNODE' ).
  co_ip_element->set_attribute(
    name = 'NAME'
    value = ip_object-name
  ).
  LOOP AT ip_object-ip_nodes REFERENCE INTO lr_ip_node.
    lo_bi_node_element = io_document->create_element( name = 'NODE' ).
    lo_bi_node_element->set_attribute(
      name = 'NAME'
      value = lr_ip_node->name
    ).
    lo_bi_node_element->set_attribute(
      name = 'ISKEY'
      value = lr_ip_node->iskey
    ).
    lo_bi_node_element->set_attribute(
      name = 'ISNAVATR'
      value = lr_ip_node->isnavatr
    ).
    co_ip_element->append_child(
      new_child = lo_bi_node_element
    ).
  ENDLOOP.
ENDFORM.                    "populate_bi_element

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_input.
  CALL FUNCTION 'GUI_FILE_LOAD_DIALOG'
    IMPORTING
      fullpath = p_input.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_output.
  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    IMPORTING
      fullpath = p_output.

************************************************************************************
************************************************************************************
* main program
************************************************************************************
************************************************************************************
START-OF-SELECTION.
  DATA: ls_ttzcu TYPE ttzcu,
        lv_parsing_error TYPE abap_bool,
        lv_serialize_error TYPE abap_bool,
        lt_byd_object TYPE byd_object_tab,
        ls_byd_objects_metadata TYPE cpms_byd_objects,
        lt_byd_component TYPE byd_component_tab,
        ls_byd_component TYPE byd_component,
        lr_byd_component TYPE REF TO byd_component,
        lt_tadir TYPE TABLE OF tadir,
        lr_tadir TYPE REF TO tadir,
        lv_timestamp TYPE timestamp,
        lo_metadata_object TYPE REF TO if_byd_obj_metadata.

* check input file name and output file name are empty.
  IF p_input IS INITIAL.
    WRITE: 'For extraction please specify input file name'.
    RETURN.
  ENDIF.

  IF p_output IS INITIAL.
    WRITE: 'For extraction please specify output file name'.
    RETURN.
  ENDIF.

* get system time zone
  SELECT SINGLE * INTO ls_ttzcu FROM ttzcu.
  IF sy-subrc EQ 0.
    gv_sys_timezone = ls_ttzcu-tzonesys.
  ELSE.
    gv_sys_timezone = 'UTC'.
  ENDIF.

* get inputted objects
  PERFORM byd_objects_upload
    USING p_input
    CHANGING
      lv_parsing_error
      lt_byd_object.

  IF lv_parsing_error EQ abap_true.
    WRITE: 'Error: Inputted file is invalid!'.
    EXIT.
  ENDIF.

  "Added by William, handle if no BYD_OBJECT is found in input file
  IF lt_byd_object IS INITIAL .
    WRITE: 'Error: No BYD_OBJECT is found!'.
    EXIT.
  ENDIF.

* populate metadata
  SELECT * FROM tadir
    INTO TABLE lt_tadir
    FOR ALL ENTRIES IN lt_byd_object
    WHERE pgmid = gc_pgmid_r3tr
    AND object = lt_byd_object-type
    AND obj_name = lt_byd_object-name.

  LOOP AT lt_tadir REFERENCE INTO lr_tadir.
    DATA: lv_comp_name TYPE string,
          lv_comp_ver TYPE string,
          lv_obj_name TYPE string,
          lv_obj_type TYPE string,
          ls_byd_obj_meatadata TYPE byd_obj_metadata.

    FIELD-SYMBOLS: <fs_byd_component> TYPE byd_component.

    lv_comp_name = lr_tadir->component.
    lv_comp_ver = lr_tadir->crelease.
    lv_obj_name = lr_tadir->obj_name.
    lv_obj_type = lr_tadir->object.

    READ TABLE lt_byd_component REFERENCE INTO lr_byd_component WITH TABLE KEY name = lv_comp_name.

    "Create component if it doesn't exist yet.
    IF sy-subrc <> 0.
      CREATE DATA lr_byd_component.
      lr_byd_component->name = lv_comp_name.
      lr_byd_component->release = lv_comp_ver.

      DATA: ls_cvers TYPE cvers.
      SELECT SINGLE * FROM cvers INTO ls_cvers
        WHERE component = lv_comp_name
        AND release = lv_comp_ver.

      IF sy-subrc EQ 0.
        lr_byd_component->extrelease = ls_cvers-extrelease.
      ENDIF.

      APPEND lr_byd_component->* TO lt_byd_component.

      READ TABLE lt_byd_component REFERENCE INTO lr_byd_component WITH TABLE KEY name = lv_comp_name.
    ENDIF.

    lo_metadata_object = cl_metadata_object_factory=>get_metadata_object( iv_type = lv_obj_type ).
    IF lo_metadata_object IS INITIAL.
      WRITE: / 'Error: Unknown data type:', lv_obj_type.
      RETURN.
    ENDIF.

    ls_byd_obj_meatadata = lo_metadata_object->get_metadata(
                               iv_name = lv_obj_name
                               iv_type = lv_obj_type
                            ).
    IF ls_byd_obj_meatadata IS NOT INITIAL.
      APPEND ls_byd_obj_meatadata TO lr_byd_component->byd_objs.
    ENDIF.
  ENDLOOP.

  ls_byd_objects_metadata-system = sy-sysid.
  ls_byd_objects_metadata-created_by = sy-uname.
  CONVERT DATE sy-datlo TIME sy-timlo INTO TIME STAMP lv_timestamp TIME ZONE gv_sys_timezone.
  ls_byd_objects_metadata-created_at = lv_timestamp.
  ls_byd_objects_metadata-components = lt_byd_component.

* output object metadata to file.
  PERFORM byd_objects_metadata_download
    USING p_output
          ls_byd_objects_metadata
    CHANGING lv_serialize_error.

  IF lv_serialize_error EQ abap_true.
    WRITE: 'Error: It''s failed to output metadata file.'.
  ELSE.
    WRITE: 'Metadata xml is created successfully!'.
  ENDIF.

END-OF-SELECTION.