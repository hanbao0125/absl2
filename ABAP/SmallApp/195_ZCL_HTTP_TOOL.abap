class ZCL_HTTP_TOOL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF Ty_name_pair,
          name type string,
          value type string,
         end of ty_name_pair .
  types:
    tt_name_pair TYPE STANDARD TABLE OF ty_name_pair .

  class-methods SEND_REQUEST
    importing
      !IV_REQ_TYPE type STRING
      !IV_URL type STRING
      !IT_HEADER type TT_NAME_PAIR optional
      !IT_FORM type TT_NAME_PAIR optional
    exporting
      !EV_RESPONSE type XSTRING .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HTTP_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HTTP_TOOL=>SEND_REQUEST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_REQ_TYPE                    TYPE        STRING
* | [--->] IV_URL                         TYPE        STRING
* | [--->] IT_HEADER                      TYPE        TT_NAME_PAIR(optional)
* | [--->] IT_FORM                        TYPE        TT_NAME_PAIR(optional)
* | [<---] EV_RESPONSE                    TYPE        XSTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SEND_REQUEST.
    DATA:lo_http_client           TYPE REF TO if_http_client,
         lv_status                TYPE i,
         lv_sysubrc               TYPE sysubrc.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = iv_url
        proxy_host         = 'PROXY.SHA.SAP.CORP'
        proxy_service      = '8080'
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.
    ASSERT sy-subrc = 0.

    lo_http_client->request->set_method( iv_req_type ).

    LOOP AT it_header ASSIGNING FIELD-SYMBOL(<header>).
      lo_http_client->request->set_header_field( name = <header>-name value = <header>-value ).
    ENDLOOP.

    LOOP AT it_form ASSIGNING FIELD-SYMBOL(<form>).
      lo_http_client->request->set_form_field( name = <form>-name value = <form>-value ).
    ENDLOOP.

    CALL METHOD lo_http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    ASSERT sy-subrc = 0.

    CALL METHOD lo_http_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    ASSERT sy-subrc = 0.

    data: headers type TIHTTPNVP.

    lo_http_client->response->get_header_fields( CHANGING fields = headers ).
    ev_response = lo_http_client->response->get_data( ).
  endmethod.
ENDCLASS.