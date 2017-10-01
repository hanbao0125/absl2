class name: SF0A0001MAIL_ADAPTER
backup date: 2009-04-02

private section.
*"* private components of class /SF0A0001/MAIL_ADAPTER
*"* do not include other source files here!!!

  class-data LV_TEST type I .

class /SF0A0001/MAIL_ADAPTER definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/MAIL_ADAPTER
*"* do not include other source files here!!!

  interfaces IF_INBOUND_EXIT_BCS .

  class-data INSTANCE type ref to /SF0A0001/MAIL_ADAPTER .

method IF_INBOUND_EXIT_BCS~CREATE_INSTANCE.

  IF instance IS INITIAL.
     CREATE OBJECT instance.
  ENDIF.
  ro_ref = instance.
endmethod.

method IF_INBOUND_EXIT_BCS~PROCESS_INBOUND.
  DATA: ex TYPE REF TO cx_root,
        document TYPE ref to if_document_bcs.

  BREAK-POINT.
  try.
    document = io_sreq->get_document( ).
    DATA: ls_entry TYPE /SF0A0001/PO,
        lv_guid TYPE SYSUUID_X16.

    CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_x16
        RECEIVING
          uuid = lv_guid.

    ls_entry-guid = lv_guid.
    ls_entry-username = sy-uname.
    ls_entry-nodeid = '1111111'.
    ls_entry-po_id = '111111'.
    ls_entry-sender_mail = 'test@sap.com'.
    ls_entry-receiver_mail = 'test@sap.com'.
    ls_entry-senddate = sy-datum.
    ls_entry-sendtime = sy-timlo.

    INSERT INTO /SF0A0001/PO VALUES ls_entry.
    BREAK-POINT.
  catch cx_root INTO ex.
  endtry.
endmethod.