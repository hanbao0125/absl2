
REPORT  ZDISPLAY_FE_RELATED.
DATA:
      lv_bo_name_slct             TYPE  mdrs_ext_bo_name_wb,
      lv_bo_node_name_slct        TYPE  mdrs_ext_bo_node_name,
      lv_co_name_slct             TYPE  mdrs_ext_bo_node_name,
      lv_bo_name                  TYPE  sesf_business_object,
      lv_bo_node_name             TYPE  sesf_business_object_node,
      lv_co_name                  TYPE  sesf_business_object_node,
      lt_co_name                  TYPE TABLE OF sesf_business_object_node,
      gs_where_used               TYPE mdrs_s_rfb_ref_fld_whl_wb,
      gt_where_used               TYPE STANDARD TABLE OF mdrs_s_rfb_ref_fld_whl_wb,
      fieldcatalog                TYPE slis_t_fieldcat_alv WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK bo_obj WITH FRAME TITLE text-001.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (30) text-002 FOR FIELD s_bo.
SELECT-OPTIONS: s_bo FOR lv_bo_name_slct OBLIGATORY NO INTERVALS NO-EXTENSION MEMORY ID bo.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (30) text-003 FOR FIELD s_node.
SELECT-OPTIONS: s_node FOR lv_bo_node_name_slct OBLIGATORY NO INTERVALS NO-EXTENSION MEMORY ID node.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK bo_obj.


START-OF-SELECTION.

  DATA lo_reference_field       TYPE REF TO /ext/if_cus_reference_field.
  DATA lo_rfb_access            TYPE REF TO /ext/if_cus_rfb_access.
  DATA lo_ref_fld_collection    TYPE REF TO /ext/if_cus_ref_fld_collection.
  DATA lo_ref_fld_fm_collection TYPE REF TO /ext/if_cus_ref_fld_collection.
  DATA lo_ref_fld_ui_collection TYPE REF TO /ext/if_cus_ref_fld_collection.
  DATA lo_ref_fld_si_collection TYPE REF TO /ext/if_cus_ref_fld_collection.
  DATA lo_ref_fld_es_collection TYPE REF TO /ext/if_cus_ref_fld_collection.
  DATA lo_ref_fld_iterator      TYPE REF TO /ext/if_cus_ref_fld_iterator.
  DATA lo_ref_fld_qry           TYPE REF TO /ext/if_cus_ref_fld_qry.
  DATA lo_ref_fld_msg           TYPE REF TO /ext/if_cus_ref_fld_msg.
  DATA lo_ref_fld_imsg          TYPE REF TO /ext/if_cus_ref_fld_imsg.
  DATA lo_ref_fld_omsg          TYPE REF TO /ext/if_cus_ref_fld_omsg.
  DATA lo_ref_fld_node          TYPE REF TO /ext/if_cus_ref_fld_node.
  DATA lo_ref_fld_bo_to_bo      TYPE REF TO /ext/if_cus_ref_fld_bo_to_bo.
  DATA lv_type                  TYPE        /ext/if_cus_reference_field=>ty_type.

* initialization
  SET PARAMETER ID 'bo' FIELD s_bo.
  SET PARAMETER ID 'node' FIELD s_node.

  lv_bo_name      = s_bo-low.
  lv_bo_node_name = s_node-low.

  TRY.
      lo_rfb_access         = /ext/cl_cus_rfb_access=>get_instance( ).
      lo_ref_fld_collection = /ext/cl_cus_ref_fld_collection=>create_instance( ).

*
      lo_ref_fld_fm_collection = lo_rfb_access->GET_FORM_FIELDS_BY_PERSISTENCE( iv_bo_name      = lv_bo_name
                                                                              iv_bo_node_name = lv_bo_node_name ).
      lo_ref_fld_iterator = lo_ref_fld_fm_collection->get_all( ).
      WHILE lo_ref_fld_iterator->has_next( ) = abap_true.
        lo_reference_field = lo_ref_fld_iterator->get_next( ).
        lo_ref_fld_collection->add( lo_reference_field ).
      ENDWHILE.

      lo_ref_fld_ui_collection = lo_rfb_access->GET_UI_FIELDS_BY_PERSISTENCE( iv_bo_name      = lv_bo_name
                                                                              iv_bo_node_name = lv_bo_node_name ).
      lo_ref_fld_iterator = lo_ref_fld_ui_collection->get_all( ).
      WHILE lo_ref_fld_iterator->has_next( ) = abap_true.
        lo_reference_field = lo_ref_fld_iterator->get_next( ).
        lo_ref_fld_collection->add( lo_reference_field ).
      ENDWHILE.

      lo_ref_fld_si_collection = lo_rfb_access->GET_SI_FIELDS_BY_PERSISTENCE( iv_bo_name      = lv_bo_name
                                                                              iv_bo_node_name = lv_bo_node_name ).
      lo_ref_fld_iterator = lo_ref_fld_si_collection->get_all( ).
      WHILE lo_ref_fld_iterator->has_next( ) = abap_true.
        lo_reference_field = lo_ref_fld_iterator->get_next( ).
        lo_ref_fld_collection->add( lo_reference_field ).
      ENDWHILE.

      lo_ref_fld_es_collection = lo_rfb_access->GET_SI_FIELDS_BY_PERSISTENCE( iv_bo_name      = lv_bo_name
                                                                              iv_bo_node_name = lv_bo_node_name ).
      lo_ref_fld_iterator = lo_ref_fld_es_collection->get_all( ).
      WHILE lo_ref_fld_iterator->has_next( ) = abap_true.
        lo_reference_field = lo_ref_fld_iterator->get_next( ).
        lo_ref_fld_collection->add( lo_reference_field ).
      ENDWHILE.

*     build up where used list
      PERFORM build_where_used_list USING lo_ref_fld_collection.

*     show result list
      PERFORM build_fieldcatalog.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program = sy-repid
          it_fieldcat        = fieldcatalog[]
        TABLES
          t_outtab           = gt_where_used
        EXCEPTIONS
          program_error      = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.


    CATCH /ext/cx_cus_reference_field .                 "#EC NO_HANDLER
  ENDTRY.

*&---------------------------------------------------------------------*
*&      Form  BUILD_WHERE_USED_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_where_used_list  USING io_ref_fld_collection  TYPE REF TO /ext/if_cus_ref_fld_collection.

  TRY.
      lo_ref_fld_iterator = io_ref_fld_collection->get_all( ).
      WHILE lo_ref_fld_iterator->has_next( ) = abap_true.
        lo_reference_field = lo_ref_fld_iterator->get_next( ).
        PERFORM where_used_add_node_info USING lo_reference_field.
      ENDWHILE.

    CATCH /ext/cx_cus_reference_field .                 "#EC NO_HANDLER
  ENDTRY.

ENDFORM.                    " BUILD_WHERE_USED_LIST

*&---------------------------------------------------------------------*
*&      Form  WHERE_USED_ADD_NODE_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM where_used_add_node_info  USING  lo_ref_fld  TYPE REF TO /ext/if_cus_reference_field.

   DATA ls_ref_fld_key           TYPE        /ext/s_cus_reference_field_key.
*
** get data from Reference Field
   CLEAR gs_where_used.
   ls_ref_fld_key                      = lo_ref_fld->get_key( ).
   lv_type = lo_ref_fld->get_type( ).

   CASE lv_type.
     WHEN /EXT/IF_CUS_REF_FLD_MSG=>gc_type.
        lo_ref_fld_msg ?= lo_ref_fld.
        gs_where_used-APR_MT_NAME           = lo_ref_fld_msg->GET_APPEARANCE_MT_NAME( ).
     WHEN /EXT/IF_CUS_REF_FLD_QRY=>GC_TYPE.
        lo_ref_fld_qry ?= lo_ref_fld.
        gs_where_used-APR_QRY_NAME           = lo_ref_fld_QRY->GET_APPEARANCE_QUERY_NAME( ).
        gs_where_used-apr_bo_name           = lo_ref_fld_qry->get_appearance_bo_name( ).
        gs_where_used-apr_node_nm           = lo_ref_fld_qry->get_appearance_bo_node_name( ).
     WHEN /EXT/IF_CUS_REF_FLD_NODE=>gc_type.
        lo_ref_fld_node ?= lo_ref_fld.
        gs_where_used-apr_bo_name           = lo_ref_fld_node->get_appearance_bo_name( ).
        gs_where_used-apr_node_nm           = lo_ref_fld_node->get_appearance_bo_node_name( ).
     WHEN /EXT/IF_CUS_REF_FLD_IMSG=>gc_type.
        lo_ref_fld_imsg ?= lo_ref_fld.
        gs_where_used-APR_MT_NAME           = lo_ref_fld_imsg->GET_APPEARANCE_MT_NAME( ).
     WHEN /EXT/IF_CUS_REF_FLD_OMSG=>gc_type.
        lo_ref_fld_omsg ?= lo_ref_fld.
        gs_where_used-APR_MT_NAME           = lo_ref_fld_omsg->GET_APPEARANCE_MT_NAME( ).
     WHEN OTHERS.
        BREAK-POINT.
   ENDCASE.

   gs_where_used-rfb_name = lo_ref_fld->get_key( ).

   READ TABLE gt_where_used FROM gs_where_used TRANSPORTING NO FIELDS.
   IF sy-subrc <> 0.
     APPEND gs_where_used TO gt_where_used.
   ENDIF.


ENDFORM.                    " WHERE_USED_ADD_NODE_INFO


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .
  fieldcatalog-fieldname   = 'RFB_NAME'.
  fieldcatalog-seltext_m   = 'RFB name'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-outputlen   = 30.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.
  fieldcatalog-fieldname   = 'APR_BO_NAME'.
  fieldcatalog-seltext_m   = 'Appearance BO Name'.
  fieldcatalog-col_pos     = 1.
  fieldcatalog-outputlen   = 30.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.
  fieldcatalog-fieldname   = 'APR_NODE_NM'.
  fieldcatalog-seltext_l   = 'Appearance BO Node Name'.
  fieldcatalog-col_pos     = 2.
  fieldcatalog-outputlen   = 30.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.
  fieldcatalog-fieldname   = 'APR_MT_NAME'.
  fieldcatalog-seltext_m   = fieldcatalog-seltext_l =  'Message Type Proxy Name'.
  fieldcatalog-col_pos     = 3.
  fieldcatalog-outputlen   = 50.
  APPEND fieldcatalog TO fieldcatalog.
  fieldcatalog-fieldname   = 'APR_QRY_NAME'.
  fieldcatalog-seltext_m   = 'Query Proxy Name'.
  fieldcatalog-col_pos     = 4.
  fieldcatalog-outputlen   = 30.
  APPEND fieldcatalog TO fieldcatalog.

ENDFORM.                    "BUILD_FIELDCATALOG