class name: SF0A0001BO_VIEWER
backup date: 2009-04-02

class /SF0A0001/BO_VIEWER definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/BO_VIEWER
*"* do not include other source files here!!!

  types:
    BEGIN OF bo_meta_data,
     flag     TYPE i,
     nodename TYPE string,
     content  TYPE REF TO data,
     parent_nodename TYPE string,
     level TYPE i,
     node_id TYPE SESF_BO_NODE_ID,
     parent_id TYPE SESF_BO_NODE_ID,
   END OF bo_meta_data .
  types:
    bo_meta_data_tab TYPE STANDARD TABLE OF bo_meta_data .
  types:
    BEGIN OF root_node_map_item,
      node_id TYPE SESF_BO_NODE_ID,
      pointer TYPE REF TO if_ixml_element,
    ENd OF root_node_map_item .
  types:
    root_node_map_tab TYPE STANDARD TABLE OF root_node_map_item with key node_id .
  types:
    BEGIN OF root_string_map_item,
      name TYPE STRING,
      pointer TYPE REF TO if_ixml_element,
    END OF root_string_map_item .
  types:
    root_string_map_tab TYPE STANDARD TABLe OF root_string_map_item with key name .

  class-data LV_BO_VIEW type I value 0. "#EC NOTEXT .
  class-data LV_UI_TEXT type I value 1. "#EC NOTEXT .
  class-data LV_LEAD_ZERO type I value 2. "#EC NOTEXT .

  class-methods DISPLAY_NODE_LIST
    importing
      !IV_DYNPROFLD type HELP_INFO-DYNPROFLD
      !IV_BO_NAME type SCOOLBUSINESSOBJECT .
  class-methods DOWNLOAD_XML
    importing
      !IN_FILE_PATH type STRING .
  class-methods TRACE .
  class-methods HANDLE_ROOT .
  class-methods READ_SUBNODE
    changing
      !C_NODE_LEVEL type I
      !C_NODE_ID type SESF_BO_NODE_ID
      !C_PARENT_NAME type STRING
      !C_NODE_DESP type ref to IF_ESF_BO_NODE_DESC .
  class-methods INIT
    importing
      !IN_BO_NAME type SCOOLBUSINESSOBJECT
      !IN_NODE_ID type CHAR32
      !IN_WORKING_MODE type I .

private section.
*"* private components of class /SF0A0001/BO_VIEWER
*"* do not include other source files here!!!

  class-data LV_WORK_MODE type I .
  class-data LV_NODE_ID type SESF_BO_NODE_ID .
  class-data LV_BO_NAME type STRING .
  class-data LR_LCP type ref to IF_ESF_LCP .
  class-data LT_META_TABLE type BO_META_DATA_TAB .
  class-data LS_META_ITEM type BO_META_DATA .
  class-data LS_ROOT_ITEM type ROOT_NODE_MAP_ITEM .
  class-data LT_ROOT_TAB type ROOT_NODE_MAP_TAB .
  class-data NODE_ELEMENT type I value 1. "#EC NOTEXT .
  class-data CHILD_ELEMENT type I value 2. "#EC NOTEXT .
  class-data LS_ROOT_STRING_ITEM type ROOT_STRING_MAP_ITEM .

  interface IF_ESF_FLAT_ATTRIBUTE_DESC load .
  class-methods EXTRACT_ROOT_DATA
    importing
      !IM_ROOT type ANY TABLE
      !IM_TARGET_BO_NODE_NAME type STRING
      !IM_RECUR_LEVEL type I
      !IM_RECUR_PARENT_NODE_ID type SESF_BO_NODE_ID
      !IM_PARENT_NODE_NAME type STRING
      !IM_ATTR_TABLE type IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR_TABLE .
  type-pools ABAP .
  class-methods IS_ASS_DISABLE
    importing
      !IM_ASS_DESC type ref to IF_ESF_ASSOCIATION_DESC
    exporting
      !EX_DISABLE type ABAP_BOOL .
  class-methods RETRIEVE_DATA
    importing
      !IN_BO_NODE_NAME type STRING
      !IN_ASSO_NAME type STRING
      !IN_NODE_ID type SESF_BO_NODE_ID_TAB
    exporting
      !EX_DATA type ANY TABLE .
  class-methods SINGLE_RETRIEVE
    importing
      !IN_NODE_NAME type STRING
      !IN_NODE_ID type SESF_BO_NODE_ID_TAB
    exporting
      !EX_DATA type ANY TABLE .

method DISPLAY_NODE_LIST.
  TYPES: BEGIN OF f4list_s,
            id TYPE apc_c_btd_id,
            node_id TYPE sesf_bo_node_id,
         END OF f4list_s.

  DATA: lt_node_id TYPE sesf_bo_node_id_tab,
        lt_root_id TYPE sesf_bo_node_id_tab,
        ls_node_id TYPE sesf_bo_node_id,
        ls_f4list TYPE f4list_s,
        lr_f4list TYPE REF TO f4list_s,
        lt_f4list TYPE TABLE OF f4list_s,
        ls_query_options  TYPE  sesf_query_options,
        lt_requested_attributes	TYPE sesf_string_tab,
        in_lcp_facade TYPE REF TO IF_ESF_LCP_FACADE,
        lx_esf_core TYPE REF TO cx_esf_core_service,
        lv_root_node_name TYPE string,
        lv_bo_proxy_name TYPE string,
        get_bodesc_ex_text TYPE string,
        lo_bo_desc TYPE REF TO if_esf_bo_desc,
        lo_bo_rootnode_desc TYPE REF TO if_esf_bo_node_desc,
        lr_root_structure_desp type ref to IF_ESF_STRUCTURE_DESC,
        lx_metadata_error TYPE REF TO cx_esf_metadata_error,
        lt_table type ref to data,
        ls_item  type ref to data,
        bo_id TYPE APC_C_BTD_ID,
        ls_entry TYPE SCOL_BO_HEADER,
        lo_lcp  TYPE REF TO if_esf_lcp.

  field-symbols:
          <lt_root> type INDEX table,
          <content> type any,
          <ls_item> type any.
  lv_bo_proxy_name = iv_bo_name.
  SELECT * FROM SCOL_BO_HEADER into ls_entry where bo_name = lv_bo_proxy_name.
  ENDSELECT.
  IF sy-subrc = 4.
    EXIT.
  ENDIF.
  WRITE: 'ok'.
  TRY.
    CALL METHOD cl_esf_descriptor_factory=>get_bo_descriptor
          EXPORTING
            in_bo_proxy_name  = lv_bo_proxy_name
          RECEIVING
            out_bo_descriptor = lo_bo_desc.
      CATCH cx_esf_metadata_error INTO lx_metadata_error.
        get_bodesc_ex_text = lx_metadata_error->get_text( ).
        get_bodesc_ex_text = 'Get BO Descriptor Error: ' && get_bodesc_ex_text. "#EC NOTEXT
        MESSAGE get_bodesc_ex_text TYPE 'E'.
   ENDTRY.
   CALL METHOD lo_bo_desc->get_root_bo_node_descriptor
      RECEIVING
        bo_node_descriptor = lo_bo_rootnode_desc.
   lr_root_structure_desp = lo_bo_rootnode_desc->GET_COMPOUND_STRUCTURE_DESCR( ).
   lt_table = lr_root_structure_desp->create_table( ).
   ls_item = lr_root_structure_desp->CREATE_DATA( ).
   lv_root_node_name = lo_bo_rootnode_desc->get_proxy_name( ).
   assign ls_item->* to <ls_item>.
   assign lt_table->* to <lt_root>.
  TRY.
    CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
     RECEIVING out_lcp_facade = in_lcp_facade.
       lo_lcp = in_lcp_facade->get_lcp( lv_bo_proxy_name ).
  CATCH cx_esf_core_service.
      MESSAGE 'BO PROXY NAME INVALID,PLEASE CHECK!' TYPE 'E'.
  ENDTRY.

  APPEND 'NODE_ID' TO  lt_requested_attributes.
  ls_query_options-maximum_rows = 200.
  CALL METHOD lo_lcp->query
        EXPORTING
          in_bo_node_name         = lv_root_node_name
          in_query_name           = 'SELECT_ALL'
          in_query_options        = ls_query_options
        IMPORTING
          out_node_ids            = lt_node_id.
   IF lt_node_id is INITIAL.
      DATA lv_messages TYPE string.
      lv_messages = 'No BO Instance for ' && iv_bo_name && 'Exsited in system: ' && sy-host. "#EC NOTEXT

      EXIT.
   ENDIF.

   LOOP AT lt_node_id INTO ls_node_id.
       ls_f4list-node_id = ls_node_id.
       CLEAR lt_root_id.
       APPEND ls_node_id TO lt_root_id.
       TRY.
          CALL METHOD lo_lcp->retrieve
             EXPORTING
                IN_BO_NODE_NAME = lv_root_node_name
                IN_NODE_IDS = lt_root_id
             IMPORTING
                OUT_DATA = <lt_root>.
          CATCH cx_esf_core_service.
             MESSAGE 'ERROR When Retrieve Node List!' TYPE 'E'. "#EC NOTEXT
          ENDTRY.
       READ TABLE <lt_root> INTO <ls_item> INDEX 1.
       ASSIGN component 'ID-CONTENT' of structure <ls_item> to <content>.
       ls_f4list-id = <content>.
       APPEND ls_f4list to lt_f4list.
   ENDLOOP.

   SORT lt_f4list BY ID.
   LOOP AT lt_f4list REFERENCE INTO lr_f4list.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
             input         = lr_f4list->id
          IMPORTING
             OUTPUT        = lr_f4list->id.
   ENDLOOP.
   DATA title(20) TYPE c.
   title = lv_bo_name.
   CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
   EXPORTING
      retfield        = 'NODE_ID'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = iv_dynprofld
      value_org       = 'S'
      WINDOW_TITLE    = title
   TABLES
      value_tab       = lt_f4list
   EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
endmethod.

method DOWNLOAD_XML.
  DATA: lo_ixml TYPE REF TO if_ixml,
        lo_document  TYPE REF TO if_ixml_document,
        lo_stream_factory TYPE REF TO if_ixml_stream_factory,
        lo_ostream TYPE REF TO if_ixml_ostream,
        lo_renderer TYPE REF TO if_ixml_renderer,
        lo_encoding TYPE REF TO if_ixml_encoding,
        lo_parent_element TYPE REF TO if_ixml_element,
        lo_components_element TYPE REF TO if_ixml_element,
        lo_element TYPE REF TO if_ixml_element,
        lo_tentative_parent TYPE REF TO if_ixml_element,
        lo_attr TYPE REF TO IF_IXML_ATTRIBUTE,
        lv_content TYPE STRING,
        lv_result TYPE i.
  field-symbols: <content> type any.
  lo_ixml = cl_ixml=>create( ).
  lo_document = lo_ixml->create_document( ).
  lo_encoding = lo_ixml->create_encoding(
                  character_set = 'utf-8'
                  byte_order = -1
                ).

  "Start to populate XML document
  lo_element = lo_document->create_element(
                  name = lv_bo_name
               ).

  lo_document->append_child(
    new_child = lo_element
  ).

  lo_parent_element = lo_element. " lo_parent_element points to APDL_OUTBOUND_DELIVERY

  DATA: lt_root_string_tab TYPE root_string_map_tab.
  LOOP AT lt_meta_table INTO ls_meta_item.
    IF ls_meta_item-flag = NODE_ELEMENT.
      " populate node name
      " a new session, clear the root string tab!
      CLEAR lt_root_string_tab.
      lo_element = lo_document->create_element( name = ls_meta_item-nodename ). "ROOT
      lo_element->SET_ATTRIBUTE( name = 'node_id' value = ls_meta_item-node_id ).

      READ TABLE lt_root_tab into ls_root_item WITH TABLE KEY node_id = ls_meta_item-parent_id.
      IF sy-subrc = 0.
         lo_parent_element = ls_root_item-pointer.
      ENDIF.
      lo_parent_element->append_child( new_child = lo_element ).
      READ TABLE lt_root_tab WITH TABLE KEY node_id = ls_meta_item-node_id TRANSPORTING NO FIELDS.
      IF sy-subrc = 4.
        CLEAR ls_root_item.
        ls_root_item-node_id = ls_meta_item-node_id.
        ls_root_item-pointer = lo_element.
        APPEND ls_root_item TO lt_root_tab.
      ENDIF.
      lo_parent_element = lo_element.
    ELSE. " child_element
      DATA: itab TYPE TABLE OF string,
            lv_sub_field TYPE string,
            i_size TYPE i.
      CLEAR itab.
      i_size = 0.
      SPLIT ls_meta_item-nodename AT '-' INTO TABLE itab.
      DESCRIBE TABLE itab LINES i_size.
      IF i_size = 1.
         " impossible to become a parent node
         READ TABLE lt_root_tab into ls_root_item WITH TABLE KEY node_id = ls_meta_item-parent_id.
         IF sy-subrc = 0.
           lo_parent_element = ls_root_item-pointer.
         ENDIF.
         lo_element = lo_document->create_element( name = ls_meta_item-nodename ). "PROCESSING_TYPE_CODE
         IF ls_meta_item-content IS NOT INITIAL.
           assign ls_meta_item-content->* to <content>.
           lv_content = <content>.
           lo_element->IF_IXML_NODE~SET_VALUE( lv_content ).
         ENDIF.
         lo_parent_element->append_child( new_child = lo_element ).
      ELSEIF i_size = 0.
        CONTINUE.
      ELSE. "UUID-TYPE-CONTENT i_size = 2.
         DATA: lv_current_parent_name TYPE string,
               lv_search_name TYPE string.
         " mustn't clear this table! CLEAR lt_root_string_tab.
         LOOP AT itab INTO lv_sub_field.
            CLEAR ls_root_string_item.
            CASE sy-tabix.
              WHEN 1.
                " period_role-content
                " a.SYSTEM_ADMINISTRATIVE_DATA-CREATE_DATE_TIME
                " b.SYSTEM_ADMINISTRATIVE_DATA-LAST_CHANGE_DATE_TIME
                " FIRST try in root string table

                READ TABLE lt_root_string_tab INTO ls_root_string_item with table key name = lv_sub_field.
                IF sy-subrc = 0. " scenario b! Needn't create a new element!
                   lo_parent_element = ls_root_string_item-pointer.
                   continue.
                ELSE. "scenario a!
                   READ TABLE lt_root_tab INTO ls_root_item with table key node_id = ls_meta_item-parent_id.
                   ASSERT sy-subrc = 0.
                   lo_element = lo_document->create_element( name = lv_sub_field ).
                   lo_parent_element = ls_root_item-pointer.
                   ls_root_string_item-name = lv_sub_field.
                   ls_root_string_item-pointer = lo_element.
                   lo_parent_element->append_child( new_child = lo_element ).
                   APPEND ls_root_string_item to lt_root_string_tab.
                   lv_current_parent_name = lv_sub_field.
                ENDIF.

              WHEN i_size.
                READ TABLE lt_root_string_tab INTO ls_root_string_item with table key name = lv_current_parent_name.
                ASSERT sy-subrc = 0.
                lo_parent_element = ls_root_string_item-pointer.
                lo_element = lo_document->create_element( name = lv_sub_field ).
                IF ls_meta_item-content IS NOT INITIAL.
                   assign ls_meta_item-content->* to <content>.
                   lv_content = <content>.
                   lo_element->IF_IXML_NODE~SET_VALUE( lv_content ).
                ENDIF.
                lo_parent_element->append_child( new_child = lo_element ).
              WHEN OTHERS.
                READ TABLE lt_root_string_tab INTO ls_root_string_item with table key name = lv_current_parent_name.
                ASSERT sy-subrc = 0.
                lo_parent_element = ls_root_string_item-pointer.
                lo_element = lo_document->create_element( name = lv_sub_field ).
                lo_parent_element->append_child( new_child = lo_element ).
                ls_root_string_item-name = lv_sub_field.
                ls_root_string_item-pointer = lo_element.
                APPEND ls_root_string_item to lt_root_string_tab.
                lv_current_parent_name = lv_sub_field.

            ENDCASE.
*            IF sy-tabix <> i_size. " UUID
*               " first search if there is literal parent for UUID
*               IF lv_current_parent_name IS INITIAL.
*                  lv_search_name = ls_meta_item-parent_name.
*               ELSE.
*                  lv_search_name = lv_current_parent_name.
*               ENDIF.
*               READ TABLE lt_root_string_tab INTO ls_root_string_item WITH TABLE KEY name =
         ENDLOOP.
      ENDIF.
    ENDIF.

  ENDLOOP.
  TYPES: x_line(80) TYPE x.
  TYPES: x_line_tab TYPE TABLE OF x_line.
  DATA ct_data TYPE x_line_tab.
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
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename          = in_file_path
      filetype          = 'BIN'
      codepage          = '4110'
      confirm_overwrite = ''
    TABLES
      data_tab          = ct_data
    EXCEPTIONS
      OTHERS            = 1.
endmethod.

method HANDLE_ROOT.
  DATA: lo_bo_desc TYPE REF TO if_esf_bo_desc,
        lx_metadata_error TYPE REF TO cx_esf_metadata_error,
        lx_core_error  TYPE REF TO CX_esf_core_service,
        lv_level TYPE i,
        lt_attributes TYPE IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR_TABLE,
        ls_attributes TYPE IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR,
        lo_bo_rootnode_desc TYPE REF TO if_esf_bo_node_desc,
        lr_root_structure_desp TYPE REF TO IF_ESF_STRUCTURE_DESC,
        lt_data_structure TYPE REF TO IF_ESF_STRUCTURE_DESC,
        lr_flat TYPE REF TO IF_ESF_FLAT_STRUCTURE_DESC,
        lt_table TYPE REF TO data,
        ls_item  TYPE REF TO data,
        lt_node_id TYPE SESF_BO_NODE_ID_TAB,
        lv_root_name TYPE string,
        lv_error     TYPE string,
        lv_name TYPE string,
        get_bodesc_ex_text TYPE string.
  FIELD-SYMBOLS:
          <lt_root> TYPE ANY TABLE,
          <content> TYPE any,
          <place_holder> TYPE any,
          <ls_item> TYPE any.
  TRY.
    CALL METHOD cl_esf_descriptor_factory=>get_bo_descriptor
          EXPORTING
            in_bo_proxy_name  = lv_bo_name
          RECEIVING
            out_bo_descriptor = lo_bo_desc.
      CATCH cx_esf_metadata_error INTO lx_metadata_error.
        get_bodesc_ex_text = lx_metadata_error->get_text( ).
        MESSAGE get_bodesc_ex_text TYPE 'E' DISPLAY LIKE 'E'.
   ENDTRY.

   lv_level = 0.

   CALL METHOD lo_bo_desc->get_root_bo_node_descriptor
      RECEIVING
        bo_node_descriptor = lo_bo_rootnode_desc.

   lr_root_structure_desp = lo_bo_rootnode_desc->GET_COMPOUND_STRUCTURE_DESCR( ).
   lt_data_structure = lo_bo_rootnode_desc->GET_DATA_STRUCTURE_DESCRIPTOR( ).
   lr_flat = lt_data_structure->GET_FLAT_STRUCTURE_DESCRIPTOR( ).
   lt_attributes =  lr_flat->GET_ATTRIBUTE_DESCRIPTORS( ).
   TRY.
      lt_table = lr_root_structure_desp->create_table( ).
      CATCH cx_esf_metadata_error INTO lx_metadata_error.
        get_bodesc_ex_text = lx_metadata_error->get_text( ).
        MESSAGE get_bodesc_ex_text TYPE 'E' DISPLAY LIKE 'E'.
   ENDTRY.
   TRY.
      ls_item = lr_root_structure_desp->CREATE_DATA( ).
      CATCH cx_esf_metadata_error INTO lx_metadata_error.
        get_bodesc_ex_text = lx_metadata_error->get_text( ).
        MESSAGE get_bodesc_ex_text TYPE 'E' DISPLAY LIKE 'E'.
   ENDTRY.
   lv_root_name = lo_bo_rootnode_desc->get_proxy_name( ).
   ASSIGN ls_item->* TO <ls_item>.
   ASSIGN lt_table->* TO <lt_root>.

   APPEND lv_node_id TO lt_node_id.
   CALL METHOD /SF0A0001/BO_VIEWER=>single_retrieve
      EXPORTING
        IN_NODE_NAME = lv_root_name
        IN_NODE_ID = lt_node_id
      IMPORTING
        ex_DATA  = <lt_root>.

   IF <lt_root> IS INITIAL.
      lv_error = 'NO Data Exists for BO: ' && lv_bo_name && ' node id: ' && lv_node_id. "#EC NOTEXT
      MESSAGE lv_error TYPE 'E'.
   ENDIF.
   LOOP AT  <lt_root> INTO <ls_item>.
      IF sy-index = 1.
         EXIT.
      ENDIF.
   ENDLOOP.

    CLEAR ls_meta_item.
    ls_meta_item-flag = NODE_ELEMENT.
    ls_meta_item-nodename = lv_root_name. "ROOT".
    ls_meta_item-level = lv_level.
    ls_meta_item-node_id = lv_node_id.
    ls_meta_item-parent_id = lv_node_id.
    ls_meta_item-parent_nodename = lv_root_name.
    APPEND ls_meta_item TO lt_meta_table.

    DATA lr_type TYPE REF TO IF_ESF_DESC.
    DATA component_type TYPE string.
    DATA extend_field TYPE string.

    CASE lv_work_mode.
      WHEN /SF0A0001/BO_VIEWER=>LV_UI_TEXT.
        CALL METHOD /SF0A0001/UI_TEXT_TOOL=>GET_NAME_BY_ATTR
          EXPORTING
            IM_BO_NODE_DESCRIPTOR = lo_bo_rootnode_desc
            IM_ATTR = lt_attributes.

      WHEN /SF0A0001/BO_VIEWER=>LV_BO_VIEW.
        " modify 2009-02-26 <content> only make sense when working on BO_VIEW mode

       LOOP AT lt_attributes INTO ls_attributes.
         lv_name = ls_attributes->IF_ESF_DESC~GET_PROXY_NAME( ).
         ASSIGN COMPONENT lv_name OF STRUCTURE <ls_item> TO <content>.
         CHECK sy-subrc = 0.
         CHECK <content> IS NOT INITIAL.
         CHECK lv_name(1) <> '/'.

         TRY.
           lr_type = ls_attributes->GET_TYPE_DESC( ).
         CATCH cx_esf_metadata_error INTO lx_metadata_error.
           get_bodesc_ex_text = lx_metadata_error->get_text( ).
           MESSAGE get_bodesc_ex_text TYPE 'E' DISPLAY LIKE 'E'.
         ENDTRY.
         component_type = lr_type->GET_PROXY_NAME( ).
         CLEAR ls_meta_item.
         ls_meta_item-flag = CHILD_ELEMENT.
         ls_meta_item-nodename = lv_name.
         ls_meta_item-level = lv_level.
         " child element neen't node id
         " ls_meta_item-node_id = <content>.
         ls_meta_item-parent_id = lv_node_id.
         ls_meta_item-parent_nodename = lv_root_name.
         CREATE DATA ls_meta_item-content TYPE (component_type).
         ASSIGN ls_meta_item-content->* TO <place_holder>.
         <place_holder> = <content>.

         APPEND ls_meta_item TO lt_meta_table.
         WRITE :/ lv_name , ': ', <content>.
       ENDLOOP.
     WHEN /SF0A0001/BO_VIEWER=>lv_lead_zero.
        CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_LEAD_ZERO_SETTING
          EXPORTING
            IM_BO_NODE_DESC = lo_bo_rootnode_desc
            IM_ATTR = lt_attributes.
     WHEN OTHERS.
        ASSERT 0 = 1.

    ENDCASE.

    CALL METHOD /SF0A0001/BO_VIEWER=>READ_SUBNODE
       CHANGING
           c_node_level  = lv_level
           c_node_id     = lv_node_id
           c_parent_name = lv_root_name
           c_node_desp   = lo_bo_rootnode_desc.

endmethod.

method INIT.
  DATA : in_lcp_facade type ref to if_esf_lcp_facade.

  lv_bo_name = in_bo_name.
  lv_node_id = in_node_id.
  lv_work_mode = in_working_mode.
  TRY.
  CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
     RECEIVING out_lcp_facade = in_lcp_facade.
  lr_lcp = in_lcp_facade->get_lcp( lv_bo_name ).
  CATCH cx_esf_core_service.
      MESSAGE 'BO PROXY NAME INVALID,PLEASE CHECK!' TYPE 'E'.
  ENDTRY.

endmethod.

method READ_SUBNODE.
  DATA:
        lt_association_desc               TYPE if_esf_association_desc=>ty_descriptor_table,
        lv_classification                 TYPE i,
        lv_isfinaldisabled_flag           TYPE abap_bool,
        lo_tgt_bo_node_desc               TYPE REF TO if_esf_bo_node_desc,
        lv_proxy_target_bo_node_name      TYPE string,
        lv_parent_node_name               TYPE string,
        lv_current_parent_name            TYPE string,
        lv_recur_level                    TYPE i,
        lv_recur_node_id                  TYPE SESF_BO_NODE_ID,
        lt_root_id                        TYPE SESF_BO_NODE_ID_TAB,
        lv_asso_name                      TYPE string,
        lv_result                         TYPE string,
        lv_output                         TYPE string,
        LR_EXCEPTION                      TYPE REF TO cx_esf_core_service,
        lx_metadata_error                 TYPE REF TO cx_esf_metadata_error,
        lv_recur_parent_id                TYPE SESF_BO_NODE_ID.

  lv_recur_level = c_node_level + 1.
  lv_recur_parent_id = c_node_id.
  lv_parent_node_name = c_parent_name.
  " need to use retrieve to get child node id and structure
  " p_parent_name

  FIELD-SYMBOLS:
                 <lo_association_desc> TYPE REF TO if_esf_association_desc.
  APPEND c_node_id to lt_root_id.
  CALL METHOD c_node_desp->get_association_descriptors
    RECEIVING
      association_descriptors = lt_association_desc.

  CHECK lt_association_desc IS NOT INITIAL.

  LOOP AT lt_association_desc ASSIGNING <lo_association_desc>.

*   check if association is not disabled final
    CLEAR lv_isfinaldisabled_flag.

    CALL METHOD /SF0A0001/BO_VIEWER=>IS_ASS_DISABLE
      EXPORTING
        im_ass_desc = <lo_association_desc>
      IMPORTING
        ex_disable = lv_isfinaldisabled_flag.

    CHECK lv_isfinaldisabled_flag = abap_false.

*   get the classification
    CLEAR lv_classification.

    CALL METHOD <lo_association_desc>->get_classification
      RECEIVING
        classification = lv_classification.

*   process only compositional associations
    CASE lv_classification.

      WHEN if_esf_association_desc=>co_classification_composition
      OR if_esf_association_desc=>co_classification_dependent_bo
      OR if_esf_association_desc=>co_classification_text_assoc.

        CLEAR lv_proxy_target_bo_node_name.
        CALL METHOD <lo_association_desc>->get_target_bo_node_proxy_name
          RECEIVING
            target_bo_node_proxy_name = lv_proxy_target_bo_node_name.
        " filter out extend nodes
        IF lv_proxy_target_bo_node_name(1) = '/' AND lv_work_mode = /SF0A0001/BO_VIEWER=>LV_BO_VIEW.
           CONTINUE.
        ENDIF.
        CLEAR ls_meta_item.
        lv_asso_name = <lo_association_desc>->IF_ESF_DESC~GET_PROXY_NAME( ).

        TRY.
          CALL METHOD <lo_association_desc>->get_target_bo_node_desc
            RECEIVING
              target_bo_node_desc = lo_tgt_bo_node_desc.
        CATCH cx_esf_metadata_error INTO lx_metadata_error.
           lv_result = lx_metadata_error->get_text( ).
           MESSAGE lv_result TYPE 'E' DISPLAY LIKE 'E'.
        ENDTRY.

        DATA: lt_table TYPE REF TO data,
              ls_item  TYPE REF TO data,

              lr_flat TYPE REF TO IF_ESF_FLAT_STRUCTURE_DESC,
              lt_a TYPE IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR_TABLE,
              lr_type TYPE REF TO IF_ESF_DESC,

              lr_node_struct_desp TYPE REF TO IF_ESF_STRUCTURE_DESC,
              lt_data_structure TYPE REF TO IF_ESF_STRUCTURE_DESC.
        FIELD-SYMBOLS:
          <lt_root> TYPE ANY TABLE,
          <content> TYPE any,
          <ls_item> TYPE any.

        lt_data_structure = lo_tgt_bo_node_desc->GET_DATA_STRUCTURE_DESCRIPTOR( ).
        lr_flat = lt_data_structure->GET_FLAT_STRUCTURE_DESCRIPTOR( ).
        lt_a =  lr_flat->GET_ATTRIBUTE_DESCRIPTORS( ).
        lr_node_struct_desp = lo_tgt_bo_node_desc->GET_COMPOUND_STRUCTURE_DESCR( ).
        TRY.
          lt_table = lr_node_struct_desp->create_table( ).
        CATCH cx_esf_metadata_error INTO lx_metadata_error.
           lv_result = lx_metadata_error->get_text( ).
           MESSAGE lv_result TYPE 'E' DISPLAY LIKE 'E'.
        ENDTRY.
        ls_item = lr_node_struct_desp->create_data( ).
        ASSIGN lt_table->* to <lt_root>.
        ASSIGN ls_item->* to <ls_item>.

        CASE lv_work_mode.
          WHEN /SF0A0001/BO_VIEWER=>lv_ui_text.
            CALL METHOD /SF0A0001/UI_TEXT_TOOL=>GET_NAME_BY_ATTR
              EXPORTING
                 IM_BO_NODE_DESCRIPTOR = lo_tgt_bo_node_desc
                 IM_ATTR = lt_a.
            CALL METHOD /SF0A0001/BO_VIEWER=>READ_SUBNODE
                CHANGING
                   c_node_level  = lv_recur_level
                   c_node_id     = c_node_id
                   c_parent_name = lv_proxy_target_bo_node_name
                   c_node_desp   = lo_tgt_bo_node_desc.

          WHEN /SF0A0001/BO_VIEWER=>lv_bo_view.

            CALL METHOD /SF0A0001/BO_VIEWER=>RETRIEVE_DATA
              EXPORTING
                 in_bo_node_name = lv_parent_node_name
                 in_asso_name = lv_asso_name
                 in_node_id = lt_root_id
              IMPORTING
                 ex_data = <lt_root>.

           IF <lt_root> IS NOT INITIAL.
              CALL METHOD /SF0A0001/BO_VIEWER=>EXTRACT_ROOT_DATA
                 EXPORTING
                   im_root = <lt_root>
                   im_target_bo_node_name = lv_proxy_target_bo_node_name
                   im_recur_level = lv_recur_level
                   im_recur_parent_node_id = lv_recur_parent_id
                   im_parent_node_name = lv_parent_node_name
                   im_attr_table = lt_a.

             CALL METHOD /SF0A0001/BO_VIEWER=>READ_SUBNODE
                CHANGING
                   c_node_level  = lv_recur_level
                   c_node_id     = lv_recur_node_id
                   c_parent_name = lv_proxy_target_bo_node_name
                   c_node_desp   = lo_tgt_bo_node_desc.

          ELSE.

             CALL METHOD /SF0A0001/BO_VIEWER=>READ_SUBNODE
                CHANGING
                   c_node_level  = lv_recur_level
                   c_node_id     = c_node_id
                   c_parent_name = lv_proxy_target_bo_node_name
                   c_node_desp   = lo_tgt_bo_node_desc.

         ENDIF.
      WHEN /SF0A0001/BO_VIEWER=>lv_lead_zero.
         CALL METHOD /SF0A0001/LEAD_ZERO_TOOL=>GET_LEAD_ZERO_SETTING
            EXPORTING
              IM_BO_NODE_DESC = lo_tgt_bo_node_desc
              IM_ATTR = lt_a.
         CALL METHOD /SF0A0001/BO_VIEWER=>READ_SUBNODE
                CHANGING
                   c_node_level  = lv_recur_level
                   c_node_id     = c_node_id
                   c_parent_name = lv_proxy_target_bo_node_name
                   c_node_desp   = lo_tgt_bo_node_desc.

      WHEN OTHERS.
        ASSERT 0 = 1.
      ENDCASE.
    ENDCASE.
  ENDLOOP.

endmethod.

method TRACE.
  LOOP AT lt_meta_table INTO ls_meta_item.
     WRITE :/ ls_meta_item-flag.
  ENDLOOP.
endmethod.

method EXTRACT_ROOT_DATA.
   DATA: lv_output TYPE string,
         lv_current_parent_name TYPE string,
         lv_field_name TYPE string,
         component_type TYPE string,
         lv_recur_node_id TYPE SESF_BO_NODE_ID,
         ls_attr TYPE IF_ESF_FLAT_ATTRIBUTE_DESC=>TY_DESCRIPTOR,
         lr_type TYPE REF TO IF_ESF_DESC.

   FIELD-SYMBOLS: <ls_item> TYPE ANY,
                  <content> TYPE ANY,
                  <lt_root> TYPE ANY TABLE.
   CHECK lv_work_mode = /SF0A0001/BO_VIEWER=>lv_bo_view.
   ASSIGN im_root TO <lt_root>.

   LOOP AT <lt_root> ASSIGNING <ls_item>.
      CLEAR ls_meta_item.
      ASSIGN COMPONENT 'NODE_ID' OF STRUCTURE <ls_item> TO <content>.
      ls_meta_item-flag = NODE_ELEMENT.
      ls_meta_item-nodename = IM_TARGET_BO_NODE_NAME.
      ls_meta_item-level = im_recur_level.
      ls_meta_item-node_id = <content>.
      ls_meta_item-parent_id = im_recur_parent_node_id.
      ls_meta_item-parent_nodename = im_parent_node_name.
      lv_recur_node_id = <content>.
      APPEND ls_meta_item TO lt_meta_table.
      NEW-LINE.
      DO im_recur_level TIMES.
         lv_output = lv_output && '*'.
      ENDDO.
      IF lv_work_mode = /SF0A0001/BO_VIEWER=>lv_bo_view.
          WRITE:/ lv_output,im_parent_node_name, 'node_id: ', im_recur_parent_node_id.
          lv_output = lv_output && '*'.
          WRITE:/ lv_output,im_target_bo_node_name, ' : ', <content>.
      ENDIF.
      " all type 2 structure must set its parent node name as lv_proxy_target_bo_node_name.
      lv_current_parent_name = im_target_bo_node_name.
      LOOP AT im_attr_table INTO ls_attr.

          FIELD-SYMBOLS : <place_holder> TYPE any.
          lv_field_name = ls_attr->IF_ESF_DESC~GET_PROXY_NAME( ).
          ASSIGN COMPONENT lv_field_name OF STRUCTURE <ls_item> TO <content>.
          CHECK sy-subrc = 0.
          CHECK <content> IS NOT INITIAL.
          lr_type = ls_attr->GET_TYPE_DESC( ).
          component_type = lr_type->GET_PROXY_NAME( ).
          CLEAR ls_meta_item.
          ls_meta_item-flag = CHILD_ELEMENT.
          ls_meta_item-nodename = lv_field_name.
          ls_meta_item-level = im_recur_level.
          " child element neen't node id
          " ls_meta_item-node_id = <content>.
          " WRONG ls_meta_item-parent_id = lv_recur_parent_id.
          ls_meta_item-parent_id = lv_recur_node_id.
          ls_meta_item-parent_nodename = lv_current_parent_name.

          CREATE DATA ls_meta_item-content TYPE (component_type).
          ASSIGN ls_meta_item-content->* TO <place_holder>.
          <place_holder> = <content>.

          APPEND ls_meta_item to lt_meta_table.
          IF lv_work_mode = /SF0A0001/BO_VIEWER=>lv_bo_view.
              WRITE :/ lv_output,lv_field_name , ' : ', <content>.
          ENDIF.
      ENDLOOP.
   ENDLOOP.
endmethod.

method IS_ASS_DISABLE.
  DATA: lv_result TYPE string,
        lx_util_metadata TYPE REF TO cx_esfts_util_metadata.
  TRY.
      CALL METHOD cl_esfts_util_metadata=>if_esfts_util_metadata~evaluate_desc
          EXPORTING
            io_desc              = im_ass_desc
          IMPORTING
            ev_is_final_disabled = ex_disable.
      CATCH cx_esfts_util_metadata INTO lx_util_metadata.
        lv_result = lx_util_metadata->get_text( ).
        MESSAGE: lv_result TYPE 'E'. "#EC NOTEXT
    ENDTRY.
endmethod.

method RETRIEVE_DATA.
  DATA: lr_exception TYPE REF TO cx_esf_core_service,
        lv_result TYPE string.
  TRY.
     CALL METHOD lr_lcp->RETRIEVE_BY_ASSOCIATION
        EXPORTING
            IN_BO_NODE_NAME = in_bo_node_name
            IN_ASSOCIATION_NAME = in_asso_name
            IN_NODE_IDS = in_node_id
            in_fill_data = 'X'
        IMPORTING
            out_data = ex_data.
        CATCH cx_esf_core_service INTO lr_exception.
            CALL METHOD lr_exception->IF_MESSAGE~GET_TEXT
               RECEIVING
                    result = lv_result.
            lv_result = 'ERROR: ' && lv_result.

            "MESSAGE lv_result TYPE 'E'.
        CATCH CX_FATAL_EXCEPTION.
            MESSAGE: 'FATAL EXCEPTION OCCURRED!' TYPE 'E'.
   ENDTRY.
endmethod.

method SINGLE_RETRIEVE.
  DATA: get_bodesc_ex_text TYPE STRING,
        lx_core_error TYPE REF TO CX_esf_core_service.
  TRY.
     CALL METHOD lr_lcp->retrieve
       EXPORTING
        IN_BO_NODE_NAME = in_node_name
        IN_NODE_IDS = in_node_id
       IMPORTING
        OUT_DATA  = ex_data.
   CATCH CX_esf_core_service into lx_core_error.
      get_bodesc_ex_text = lx_core_error->get_text( ).
      MESSAGE get_bodesc_ex_text TYPE 'E' DISPLAY LIKE 'E'.
   ENDTRY.
endmethod.
