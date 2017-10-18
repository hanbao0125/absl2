class ZCL_CRM_BDOC_SUPPRESS_TOOL definition
  public
  final
  create public .

public section.

  class-methods RUN
    importing
      !IT_OBJECT_LIST type CRMT_OBJECT_GUID_TAB .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CRM_BDOC_SUPPRESS_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CRM_BDOC_SUPPRESS_TOOL=>RUN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_OBJECT_LIST                 TYPE        CRMT_OBJECT_GUID_TAB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD run.
    CHECK sy-uname = 'WANGJER'.
    CHECK it_object_list IS NOT INITIAL.
    DATA lv_process_type    TYPE crmt_process_type.

    LOOP AT it_object_list ASSIGNING FIELD-SYMBOL(<guid>).
      CALL FUNCTION 'CRM_ORDERADM_H_READ_OW'
        EXPORTING
          iv_orderadm_h_guid     = <guid>
        IMPORTING
          ev_process_type        = lv_process_type
        EXCEPTIONS
          admin_header_not_found = 1
          OTHERS                 = 2.

      CHECK lv_process_type = 'ZSRV'.

      CALL FUNCTION 'CRM_ORDER_SET_NO_BDOC_SEND_OW'
        EXPORTING
          iv_guid = <guid>
          iv_flag = 'N'.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.