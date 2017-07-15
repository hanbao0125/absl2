*&---------------------------------------------------------------------*
*& Report ZGIT_SEND_HTTP_POST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZGIT_SEND_HTTP_POST.

    DATA: lo_client TYPE REF TO if_http_client,
          lv_status  TYPE i,
          lv_message TYPE string,
          lv_sysubrc LIKE sy-subrc.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = 'https://jerrylist.cfapps.eu10.hana.ondemand.com'
        proxy_host         = 'proxy.wdf.sap.corp'
        proxy_service      = '8080'
      IMPORTING
        client             = lo_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    IF sy-subrc <> 0.
      WRITE:/ 'Error when creating client'.
      RETURN.
    ENDIF.

    CALL METHOD lo_client->request->set_method( 'POST' ).
    CALL METHOD lo_client->request->set_content_type('application/x-www-form-urlencoded').
    lo_client->request->set_form_field( name = 'markdown_source' value = 'Jerry' ).
    CALL METHOD lo_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    IF sy-subrc <> 0.
      CALL METHOD lo_client->get_last_error
        IMPORTING
          code    = lv_sysubrc
          message = lv_message.

      lo_client->close( ).
      WRITE:/ lv_message.
    ENDIF.

    CALL METHOD lo_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    IF sy-subrc <> 0.
      CALL METHOD lo_client->get_last_error
        IMPORTING
          code    = lv_sysubrc
          message = lv_message.

      lo_client->close( ).
      RAISE request_in_failed.
    ENDIF.

    CALL METHOD lo_client->response->get_status
      IMPORTING
        code   = lv_status
        reason = lv_message.

    lv_message = lo_client->response->get_cdata( ).


    WRITE:/ lv_message.
    lo_client->close( ).