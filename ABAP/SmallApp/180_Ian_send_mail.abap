*&---------------------------------------------------------------------*
*& Report  ZBO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZBO.
DATA: lv_title          TYPE so_obj_des,
      send_request   TYPE REF TO CL_BCS,
      document         TYPE REF TO CL_DOCUMENT_BCS,
      conlengths        TYPE so_obj_len,
      html                  TYPE STANDARD TABLE OF w3html,
      wa_html           TYPE w3html,
      sender_id         TYPE REF TO IF_SENDER_BCS,
      recipient           TYPE REF TO IF_RECIPIENT_BCS,
      sent_to_all       TYPE os_boolean,
      bcs_exception  TYPE REF TO cx_bcs,
      bcs_message   TYPE string.

lv_title = 'This is the title'.
wa_html-line = '<html><body>'.
APPEND wa_html TO html.
...
wa_html-line = '</body></html>'.
APPEND wa_html TO html.

TRY.
    CLEAR send_request.
    send_request = cl_bcs=>create_persistent( ).

    CLEAR document .
    document =  cl_document_bcs=>create_document(
                    i_type =    'HTM'
                    i_text =     html
                    i_length =  conlengths
                    i_subject = lv_title ).
*   Add document to send request
    CALL METHOD send_request->set_document( document ).

*   Construct sender and receiver
    CLEAR: sender_id , recipient .
    sender_id = cl_cam_address_bcs=>create_internet_address( 'abc@zh.cn' ).
    recipient = cl_cam_address_bcs=>create_internet_address( 'jerry.wang@sap.com' ).

*   Set sender
    CALL METHOD send_request->set_sender
      EXPORTING
        i_sender = sender_id.

*   Add recipient with its respective attributes to send request
    CALL METHOD send_request->add_recipient
      EXPORTING
        i_recipient = recipient
        i_express   = 'X'.

*   Set E-mail sending options
    CALL METHOD send_request->set_status_attributes
      EXPORTING
        i_requested_status = 'E'
        i_status_mail      = 'E'.
    CALL METHOD send_request->set_send_immediately( 'X' ).

*   Send document
    CALL METHOD send_request->send(
     EXPORTING
       i_with_error_screen = 'X'
     RECEIVING
       result = sent_to_all ).

    IF sent_to_all = 'X'.
      MESSAGE 'Mail sent successfully ' TYPE 'S'.
    ENDIF.
    COMMIT WORK.

  CATCH cx_bcs INTO bcs_exception.
    bcs_message = bcs_exception->get_text( ).
    MESSAGE bcs_exception TYPE 'E'.
    EXIT.
ENDTRY.