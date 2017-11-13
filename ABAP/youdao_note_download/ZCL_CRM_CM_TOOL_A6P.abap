class ZCL_CRM_CM_TOOL definition
  public
  final
  create public .

public section.

  class-methods GET_DATA_BY_URL
    importing
      !IV_URL type STRING
    returning
      value(EV_DATA) type XSTRING .
  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_TEXT_BY_URL
    importing
      !IV_URL type STRING
    returning
      value(EV_TEXT) type STRING .
  class-methods DOWNLOAD_LOCALLY
    importing
      !IV_LOCAL_PATH type STRING
      !IV_BINARY type XSTRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CRM_CM_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRM_CM_TOOL=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CLASS_CONSTRUCTOR.
    CALL FUNCTION 'SDOK_INTERNAL_MODE_ACCESS'
      EXPORTING
        MODE_REQUESTED = '01'.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRM_CM_TOOL=>DOWNLOAD_LOCALLY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_LOCAL_PATH                  TYPE        STRING
* | [--->] IV_BINARY                      TYPE        XSTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD download_locally.
    TYPES: BEGIN OF ts_line,
             data(1024) TYPE x,
           END OF ts_line.

    DATA: lv_size TYPE int4,
          lt_data TYPE STANDARD TABLE OF ts_line.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = iv_binary
      IMPORTING
        output_length = lv_size
      TABLES
        binary_tab    = lt_data.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        bin_filesize = lv_size
        filename     = iv_local_path
        filetype     = 'BIN'
        append       = space
      IMPORTING
        filelength   = lv_size
      CHANGING
        data_tab     = lt_data
      EXCEPTIONS
        OTHERS       = 01.

    ASSERT sy-subrc = 0.

    DATA(lv_file) = |File: { iv_local_path }, size: { lv_size }|.
    WRITE: / lv_file COLOR COL_NEGATIVE.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRM_CM_TOOL=>GET_DATA_BY_URL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_URL                         TYPE        STRING
* | [<-()] EV_DATA                        TYPE        XSTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_DATA_BY_URL.
    DATA:lo_http_client           TYPE REF TO if_http_client,
         lv_status                TYPE i,
         lv_sysubrc               TYPE sysubrc.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = iv_url
        "proxy_host         = 'PROXY.SHA.SAP.CORP'
        "proxy_service      = '8080'
        "ssl_id             = 'ANONYM'
        "sap_username       = ''
        "sap_client         = ''
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    ASSERT sy-subrc = 0.

    CALL METHOD lo_http_client->request->set_method( if_http_request=>co_request_method_get ).

*Disable pop-up when request receives unauthorized error: error 401.
    lo_http_client->propertytype_logon_popup = if_http_client=>co_disabled.

*Send request.
    CALL METHOD lo_http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    ASSERT sy-subrc = 0.

* Get response.
    CALL METHOD lo_http_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

   IF sy-subrc <> 0.
        CALL METHOD lo_http_client->get_last_error
        IMPORTING
          code    = lv_sysubrc
          message = DATA(ev_message).
        BREAK-POINT.
        RETURN.
   ENDIF.

   ev_data = lo_http_client->response->get_data( ).

   lo_http_client->close( ).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRM_CM_TOOL=>GET_TEXT_BY_URL
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_URL                         TYPE        STRING
* | [<-()] EV_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_TEXT_BY_URL.
    DATA:lo_http_client           TYPE REF TO if_http_client,
         lv_status                TYPE i,
         lv_sysubrc               TYPE sysubrc.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = iv_url
*        proxy_host         = 'PROXY.SHA.SAP.CORP'
*        proxy_service      = '8080'
*        ssl_id             = 'ANONYM'
*        sap_username       = ''
*        sap_client         = ''
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    ASSERT sy-subrc = 0.

    CALL METHOD lo_http_client->request->set_method( if_http_request=>co_request_method_get ).

*Disable pop-up when request receives unauthorized error: error 401.
    "lo_http_client->propertytype_logon_popup = if_http_client=>co_disabled.

*Send request.
    CALL METHOD lo_http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    ASSERT sy-subrc = 0.

* Get response.
    CALL METHOD lo_http_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

   IF sy-subrc <> 0.
        CALL METHOD lo_http_client->get_last_error
        IMPORTING
          code    = lv_sysubrc
          message = DATA(ev_message).
        BREAK-POINT.
        RETURN.
   ENDIF.

   ev_text = lo_http_client->response->get_cdata( ).

   lo_http_client->close( ).
  endmethod.
ENDCLASS.