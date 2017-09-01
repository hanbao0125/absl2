*&---------------------------------------------------------------------*
*& Report  ZAP_OM_MERGE_FORM_XSD
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_JAN_OM_MERGE_FORM_XSD.
SET EXTENDED CHECK OFF.

CLASS lcl_schema DEFINITION DEFERRED.

* Type Declaration
TYPES: BEGIN OF ty_ns_prefix,
          prefix TYPE string,
          ns TYPE string,
  END OF ty_ns_prefix.
TYPES: BEGIN OF ty_ns_schemaloc,
        ns TYPE string,
        schema_name TYPE string,
        schema_loc TYPE string,
END OF ty_ns_schemaloc.

TYPES: ty_prefix_ns_lt TYPE STANDARD TABLE OF ty_ns_prefix,
       ty_ns_schemaloc_lt TYPE STANDARD TABLE OF ty_ns_schemaloc.
TYPES: BEGIN OF ty_schema_proc,
         schema_name TYPE string,
  END OF ty_schema_proc.
TYPES: BEGIN OF ty_schema_objects,
        obj TYPE REF TO lcl_schema,
  END OF ty_schema_objects.
TYPES: BEGIN OF xml_line,
      data(80) TYPE x,
     END OF xml_line.

* Includes
INCLUDE Z_OM_MERGE_FORM_XSD_FORMS01.
*INCLUDE ZAP_OM_MERGE_FORM_XSD_forms01.
INCLUDE Z_OM_MERGE_FORM_XSD_CLASS01.
*INCLUDE ZAP_OM_MERGE_FORM_XSD_class01.

* Type pools
TYPE-POOLS: ixml.

* Data Declaration
DATA: upload_path TYPE string.  " File upload path
DATA: xmldata TYPE xstring.     " Main Schema document

DATA: g_ixml TYPE REF TO if_ixml.                           " Main XML factory
DATA: g_streamfactory TYPE REF TO if_ixml_stream_factory.   " Stream factory
DATA: ixml_document TYPE REF TO if_ixml_document.           " Document

DATA: target_ns TYPE string,                                " Target Namespace
      default_ns TYPE string,                               " Default Namespace
      xsd_ns TYPE string.                                   " XSD Namespace

DATA:  xml_table TYPE TABLE OF xml_line,                    " xml table to store the data to be downloaded
       xml_size  TYPE i.                                    " size of the xml data to be downloaded.

DATA: ostream TYPE REF TO if_ixml_ostream.                  " Output Stream
DATA: enc TYPE REF TO if_ixml_encoding.                     " XML Encoding

SELECTION-SCREEN BEGIN OF BLOCK comm WITH FRAME TITLE text-003.
SELECTION-SCREEN COMMENT /1(79) text-002.
SELECTION-SCREEN COMMENT /1(79) text-004.
SELECTION-SCREEN END OF BLOCK comm.

* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK file WITH FRAME TITLE text-001.
PARAMETERS: file TYPE string OBLIGATORY LOWER CASE.
PARAMETERS: file_out TYPE string OBLIGATORY DEFAULT 'C:\Temp\MergedXSD.xsd' LOWER CASE.
SELECTION-SCREEN END OF BLOCK file.

* Initialization
INITIALIZATION.
* Create the main iXML factory.
* Create the stream factory
  CLASS cl_ixml DEFINITION LOAD.
  g_ixml = cl_ixml=>create( ).
  g_streamfactory = g_ixml->create_stream_factory( ).

* At Selection Screen

* At Selection Screen on value request
  AT SELECTION-SCREEN ON VALUE-REQUEST FOR file.
    PERFORM filename_value_request CHANGING file upload_path.

    AT SELECTION-SCREEN ON VALUE-REQUEST FOR file_out.
      PERFORM filesave_value_request CHANGING file_out.

* Start of selection
START-OF-SELECTION.
* Upload the main schema document
  CALL METHOD lcl_utility=>upload_file
    EXPORTING
      file        = file
    IMPORTING
      upload_path = upload_path
    CHANGING
      xmldata     = xmldata.

* From the Main Schema document (binary data) obtain the IF_IXML_DOCUMENT object
  CALL METHOD lcl_utility=>get_ixml_document
    EXPORTING
      xmldata        = xmldata
      ixml           = g_ixml
      stream_factory = g_streamfactory
    IMPORTING
      ixml_document  = ixml_document.

* Check if main schema XML document object is not initial.
  IF ixml_document IS INITIAL.
*   Handle Errors
    EXIT.
  ENDIF.

* Read all the nodes of the Main Schema and extract the attributes
  DATA: node TYPE REF TO if_ixml_node.
  DATA: iterator TYPE REF TO if_ixml_node_iterator.

* Cast the document object and create the iterator.
  node ?= ixml_document.
  iterator = node->create_iterator( ).

  DATA: node_type  TYPE i,                                " Node Type
        node_name  TYPE string.                           " Node Name
  DATA: nodemap    TYPE REF TO if_ixml_named_node_map,    " Node Map - For Attributes
        attr       TYPE REF TO if_ixml_node,              " Attribute object
        count      TYPE i,
        index      TYPE i,
        attr_name  TYPE string,                           " Attribute Name
        attr_value TYPE string.                           " Attribute Value

  DATA: lt_prefix TYPE STANDARD TABLE OF ty_ns_prefix,    " Table to store the prefix and the namespace
        ls_prefix TYPE ty_ns_prefix.                      " Work Area
  DATA: lt_schema TYPE STANDARD TABLE OF ty_ns_schemaloc, " Table to store the imported schema name, location and imported namespace.
        ls_schema TYPE ty_ns_schemaloc.                   " Work Area

* Get the current node
  node = iterator->get_next( ).
  WHILE NOT node IS INITIAL.
*   Get the node type.
    node_type = node->get_type( ).
*   Get the node name.
    node_name = node->get_name( ).

*   Check the value of node type and node name
*   Case - Root element xsd:schema
    IF node_type EQ if_ixml_node=>co_node_element AND node_name EQ 'schema'.
*     Get all the attributes
      nodemap = node->get_attributes( ).
      IF NOT nodemap IS INITIAL.
*       Should not be initial as the root element has atleast 3 attributes.
        count = nodemap->get_length( ).
        DO count TIMES.
*         Read each attribute and decide whether we need to use this.
          index       = sy-index - 1.
          attr        = nodemap->get_item( index ).
          attr_name   = attr->get_name( ).
          attr_value  = attr->get_value( ).

          IF attr_name EQ 'targetNamespace'.
*           Save the target namespace
            target_ns = attr_value.
          ELSEIF attr_name EQ 'xmlns'.
*           Save the default namespace.
            default_ns = attr_value.
          ELSEIF attr_name EQ 'xsd'.
*           Save the XSD namespace
            xsd_ns = attr_value.
          ELSE.
*           Internal Table LT_PREFIX saves the prefix and the namespace which will be imported.
            ls_prefix-prefix = attr_name.
            ls_prefix-ns = attr_value.
            APPEND ls_prefix TO lt_prefix.
            CLEAR ls_prefix.
          ENDIF.
        ENDDO.
      ENDIF.
*   Check the value of node type and node name
*   Case - Element xsd:import
    ELSEIF node_type EQ if_ixml_node=>co_node_element AND node_name EQ 'import'.
*     Get all the attributes for the import element.
      nodemap = node->get_attributes( ).
      IF NOT nodemap IS INITIAL.
*       Should not be initial as import element has mandatory attributes.
        count = nodemap->get_length( ).
        DO count TIMES.
          index       = sy-index - 1.
          attr        = nodemap->get_item( index ).
          attr_name   = attr->get_name( ).
          attr_value  = attr->get_value( ).

          IF attr_name EQ 'namespace'.
*           Internal Table LT_SCHEMA holds the location of imported schema file, Name of Imported Schema File and the imported namespace.
            ls_schema-ns = attr_value.
          ELSEIF attr_name EQ 'schemaLocation'.
            DATA: lv_schema_name TYPE string,
                  lv_schema_ext TYPE string.
            ls_schema-schema_loc = attr_value.

*           Get the schema name only
            SPLIT attr_value AT '.' INTO lv_schema_name lv_schema_ext.
            TRANSLATE lv_schema_name TO UPPER CASE.
            ls_schema-schema_name = lv_schema_name.

            APPEND ls_schema TO lt_schema.
            CLEAR ls_schema.
          ENDIF.
        ENDDO.
      ENDIF.
    ENDIF.

*   Navigate to the next node.
    node = iterator->get_next( ).
  ENDWHILE.

* At this stage the main schema has been read and relevant data has been extracted from the MainSchema Document.
* Now the document is processed meaning - the imported Schema is uploaded. This is a recursive process.

* Create an object for the main schema.
  DATA: o_main TYPE REF TO lcl_schema.

* Main Schema object
  CREATE OBJECT o_main
    EXPORTING
      t_prefix       = lt_prefix
      t_schemaloc    = lt_schema
      document       = ixml_document
      upload_path    = upload_path
      ixml           = g_ixml
      stream_factory = g_streamfactory.

* Process the Main schema
  DATA: ls_obj TYPE ty_schema_objects.
  o_main->process_document( ).

* At this the table lcl_utility=>lt_obj has all the objects, each representing one XSD document.
* At this stage the merge process is started and the final XSD is downloaded.

* Create the output stream
  ostream =  g_streamfactory->create_ostream_itable( xml_table ).
* Set Pretty print
  ostream->set_pretty_print( pretty_print = 'X' ).
* Set Encoding
  enc = g_ixml->create_encoding( character_set = 'UTF-8' byte_order = 1 ).
  ostream->set_encoding( encoding = enc ).

* Start the merge process
  lcl_utility=>merge_document( target_ns = target_ns
                               def_ns    = default_ns
                               xsd_ns    = xsd_ns
                               ostream   = ostream ).

* Get the actual number of bytes written to the output stream
  xml_size = ostream->get_num_written_raw( ).

* Download the file
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      bin_filesize              = xml_size
      filename                  = file_out
      filetype                  = 'BIN'
      trunc_trailing_blanks     = 'X'
      codepage                  = 'UTF-8'
      trunc_trailing_blanks_eol = 'X'
    CHANGING
      data_tab                  = xml_table
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Close the streams
  ostream->close( ).