CLASS cl_abap_git_issue_tool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .



  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_sorted_node,
        index     TYPE string,
        attribute TYPE string,
        value     TYPE string,
      END OF ty_sorted_node .
    TYPES:
      tt_sorted_node TYPE STANDARD TABLE OF ty_sorted_node .

    CLASS-METHODS read_txt_file
      IMPORTING
        !iv_path       TYPE string
      RETURNING
        VALUE(rv_text) TYPE string .
    CLASS-METHODS download_as_text_file
      IMPORTING
        !iv_file_path    TYPE string
        !iv_text_content TYPE string .
    CLASS-METHODS parse_json_to_internal_table
      IMPORTING
        !iv_json        TYPE string
      EXPORTING
        !et_node        TYPE tt_sorted_node
        !ev_node_number TYPE int4 .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_level,
        level     TYPE i,
        indicator TYPE string,
      END OF ty_level .
    TYPES:
      tt_level TYPE STANDARD TABLE OF ty_level WITH KEY level .

    TYPES:
      BEGIN OF ty_node,
        node_type TYPE string,
        prefix    TYPE string,
        name      TYPE string,
        nsuri     TYPE string,
        value     TYPE string,
        value_raw TYPE xstring,
      END OF ty_node .
    TYPES:
      tt_node TYPE TABLE OF ty_node .

    CONSTANTS gc_json_open_element TYPE string VALUE 'open element' ##NO_TEXT.
    CONSTANTS gc_json_attribute TYPE string VALUE 'attribute' ##NO_TEXT.
    CONSTANTS gc_json_close_element TYPE string VALUE 'close element' ##NO_TEXT.
    CONSTANTS gc_json_value TYPE string VALUE 'value' ##NO_TEXT.
    CONSTANTS gc_json_error TYPE string VALUE 'Error' ##NO_TEXT.

    CLASS-METHODS parse_json_to_raw_table
      IMPORTING
        !iv_json TYPE string
      EXPORTING
        !et_node TYPE tt_node
      EXCEPTIONS
        json_parse_error .
    CLASS-METHODS sort_raw_table
      IMPORTING
        !it_node        TYPE tt_node
      EXPORTING
        !et_sorted_node TYPE tt_sorted_node
        !ev_node_number TYPE int4 .
ENDCLASS.



CLASS cl_abap_git_issue_tool IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_TOOL=>DOWNLOAD_AS_TEXT_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FILE_PATH                   TYPE        STRING
* | [--->] IV_TEXT_CONTENT                TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD download_as_text_file.
    DATA: lt_data_tab TYPE TABLE OF sdokcntasc.

    CALL FUNCTION 'SCMS_STRING_TO_FTEXT'
      EXPORTING
        text      = iv_text_content
      TABLES
        ftext_tab = lt_data_tab.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename = iv_file_path
        codepage = '8400'
      CHANGING
        data_tab = lt_data_tab.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_TOOL=>PARSE_JSON_TO_INTERNAL_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_JSON                        TYPE        STRING
* | [<---] ET_NODE                        TYPE        TT_SORTED_NODE
* | [<---] EV_NODE_NUMBER                 TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD parse_json_to_internal_table.
    DATA lt_raw_node TYPE tt_node.

    CALL METHOD parse_json_to_raw_table
      EXPORTING
        iv_json          = iv_json
      IMPORTING
        et_node          = lt_raw_node
      EXCEPTIONS
        json_parse_error = 1
        OTHERS           = 2.

    ASSERT sy-subrc = 0.

    CALL METHOD sort_raw_table
      EXPORTING
        it_node        = lt_raw_node
      IMPORTING
        et_sorted_node = et_node
        ev_node_number = ev_node_number.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method CL_ABAP_GIT_ISSUE_TOOL=>PARSE_JSON_TO_RAW_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_JSON                        TYPE        STRING
* | [<---] ET_NODE                        TYPE        TT_NODE
* | [EXC!] JSON_PARSE_ERROR
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD parse_json_to_raw_table.
    DATA:
      node_wa TYPE ty_node.

    DATA(json) = cl_abap_codepage=>convert_to( iv_json ).
    DATA(reader) = cl_sxml_string_reader=>create( json ).

    TRY.
        DO.
          CLEAR node_wa.
          DATA(node) = reader->read_next_node( ).
          IF node IS INITIAL.
            EXIT.
          ENDIF.
          CASE node->type.
            WHEN if_sxml_node=>co_nt_element_open.
              DATA(open_element) = CAST if_sxml_open_element( node ).
              node_wa-node_type = gc_json_open_element.
              node_wa-prefix    = open_element->prefix.
              node_wa-name      = open_element->qname-name.
              node_wa-nsuri     = open_element->qname-namespace.
              DATA(attributes)  = open_element->get_attributes( ).
              APPEND node_wa TO et_node.
              LOOP AT attributes INTO DATA(attribute).
                node_wa-node_type = gc_json_attribute.
                node_wa-prefix    = attribute->prefix.
                node_wa-name      = attribute->qname-name.
                node_wa-nsuri     = attribute->qname-namespace.
                IF attribute->value_type = if_sxml_value=>co_vt_text.
                  node_wa-value = attribute->get_value( ).
                ELSEIF attribute->value_type =
                                   if_sxml_value=>co_vt_raw.
                  node_wa-value_raw = attribute->get_value_raw( ).
                ENDIF.
                APPEND node_wa TO et_node.
              ENDLOOP.
              CONTINUE.
            WHEN if_sxml_node=>co_nt_element_close.
              DATA(close_element) = CAST if_sxml_close_element( node ).
              node_wa-node_type   = gc_json_close_element.
              node_wa-prefix      = close_element->prefix.
              node_wa-name        = close_element->qname-name.
              node_wa-nsuri       = close_element->qname-namespace.
              APPEND node_wa TO et_node.
              CONTINUE.
            WHEN if_sxml_node=>co_nt_value.
              DATA(value_node) = CAST if_sxml_value_node( node ).
              node_wa-node_type   = gc_json_value.
              IF value_node->value_type = if_sxml_value=>co_vt_text.
                node_wa-value = value_node->get_value( ).
              ELSEIF value_node->value_type = if_sxml_value=>co_vt_raw.
                node_wa-value_raw = value_node->get_value_raw( ).
              ENDIF.
              APPEND node_wa TO et_node.
              CONTINUE.
            WHEN OTHERS.
              node_wa-node_type   = gc_json_error.
              APPEND node_wa TO et_node.
              EXIT.
          ENDCASE.
        ENDDO.
      CATCH cx_sxml_parse_error INTO DATA(parse_error).
        RAISE json_parse_error.
    ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_TOOL=>READ_TXT_FILE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PATH                        TYPE        STRING
* | [<-()] RV_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD read_txt_file.

    DATA: l_filename TYPE string,
          l_rawtab   TYPE string_table,
          l_len      TYPE i.

    l_filename = iv_path.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = l_filename
        filetype                = 'ASC'
        codepage                = '8400'
      IMPORTING
        filelength              = l_len
      CHANGING
        data_tab                = l_rawtab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    ASSERT sy-subrc = 0.

    LOOP AT l_rawtab ASSIGNING FIELD-SYMBOL(<line>).
      rv_text = rv_text && <line>.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method CL_ABAP_GIT_ISSUE_TOOL=>SORT_RAW_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_NODE                        TYPE        TT_NODE
* | [<---] ET_SORTED_NODE                 TYPE        TT_SORTED_NODE
* | [<---] EV_NODE_NUMBER                 TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD sort_raw_table.
    DATA:
      ls_node              TYPE ty_node,
      lv_level_counter     TYPE i VALUE 0,
      lv_attribute_name    TYPE string,
      lv_seperator         TYPE char1,
      ls_sorted_node       TYPE ty_sorted_node,
      lv_node_counter      TYPE i VALUE 1,
      lv_node_flag_counter TYPE i,
      lt_level_tab         TYPE tt_level,
      ls_level_tab         TYPE ty_level,
      lv_index             TYPE i,
      lv_temp_counter      TYPE i.

    FIELD-SYMBOLS <fs_level_tab> TYPE ty_level.

    LOOP AT it_node INTO ls_node.
*Check if open element, if yes increase level counter
      IF  ls_node-node_type = gc_json_open_element.
        lv_level_counter = lv_level_counter + 1.

*Check if it is new node, if yes increase node counter
        IF lv_node_flag_counter IS NOT INITIAL AND lv_level_counter = lv_node_flag_counter.
          lv_node_counter = lv_node_counter + 1.
        ENDIF.

*Add level indicator to level table in order to remember which level we are in
        CLEAR ls_level_tab.
        READ TABLE lt_level_tab INTO ls_level_tab WITH TABLE KEY level = lv_level_counter.
        IF ls_level_tab IS INITIAL.
          ls_level_tab-level = lv_level_counter.
          APPEND ls_level_tab TO lt_level_tab.
        ENDIF.
      ENDIF.

*Check if attribute
      IF  ls_node-node_type = gc_json_attribute.
*If no entry in our generated result table then me mark current level as the begining of each node
        IF et_sorted_node IS INITIAL.
          lv_node_flag_counter = lv_level_counter - 1.
        ENDIF.

        LOOP AT lt_level_tab ASSIGNING <fs_level_tab> WHERE level = lv_level_counter.
          <fs_level_tab>-indicator =  ls_node-value.
        ENDLOOP.
      ENDIF.


*Check if value
*-------------------------------------------------------------------------
*Add level indicator to level table in order to show hierachy node
*For instance if we have following node hieracy
*   -A
*     -a
*     -b
*we wil have following naming convertion in our generated table
*  A-a  &  A-b
*-------------------------------------------------------------------------
      IF  ls_node-node_type = gc_json_value.
        CLEAR lv_attribute_name.
        LOOP AT lt_level_tab ASSIGNING <fs_level_tab> FROM 0 TO lv_level_counter.
          IF <fs_level_tab>-indicator IS NOT INITIAL.
            CONCATENATE lv_attribute_name '-' <fs_level_tab>-indicator INTO lv_attribute_name.
          ENDIF.
        ENDLOOP.

        CLEAR: lv_seperator, lv_index.
        lv_seperator = lv_attribute_name+0(1).
        IF lv_seperator = '-'.
          lv_index = strlen( lv_attribute_name ) - 1.
          lv_attribute_name = lv_attribute_name+1(lv_index).
        ENDIF.

        IF lv_attribute_name IS NOT INITIAL.
          ls_sorted_node-attribute = lv_attribute_name.
          ls_sorted_node-value =  ls_node-value.
          ls_sorted_node-index = lv_node_counter.
          APPEND ls_sorted_node TO et_sorted_node.
        ENDIF.
        CLEAR: ls_sorted_node.
      ENDIF.

*Check if close element
      IF  ls_node-node_type = gc_json_close_element.
        lv_level_counter = lv_level_counter - 1.

*Remove level indicator from level table
        DESCRIBE TABLE lt_level_tab LINES lv_temp_counter.
        LOOP AT lt_level_tab ASSIGNING <fs_level_tab> FROM lv_level_counter + 1 TO lv_temp_counter.
          <fs_level_tab>-indicator = ''.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

*Return total number of nodes
    ev_node_number = lv_node_counter.
  ENDMETHOD.
ENDCLASS.