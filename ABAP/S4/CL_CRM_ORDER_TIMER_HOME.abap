class CL_CRM_ORDER_TIMER_HOME definition
  public
  final
  create public .

public section.

  class-methods START .
  class-methods STOP
    importing
      !IV_TEXT type STRING .
  class-methods LOG
    importing
      !IV_UUID type RAW16
      !IV_DURATION type INT4
      !IV_CURRENT_INDEX type INT4
      !IV_TOTAL_SIZE type INT4 .
  class-methods GET_UUID
    returning
      value(RV_UUID) type RAW16 .
protected section.
private section.

  class-data MV_START type INT8 .
ENDCLASS.



CLASS CL_CRM_ORDER_TIMER_HOME IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_CRM_ORDER_TIMER_HOME=>GET_UUID
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_UUID                        TYPE        RAW16
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_UUID.
  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_16 = rv_uuid.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_CRM_ORDER_TIMER_HOME=>LOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_UUID                        TYPE        RAW16
* | [--->] IV_DURATION                    TYPE        INT4
* | [--->] IV_CURRENT_INDEX               TYPE        INT4
* | [--->] IV_TOTAL_SIZE                  TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method LOG.
    data: ls_log type crms4d_1o_create.

    ls_log = value #( uuid = iv_uuid current_index = iv_current_index
     total_pack_num = iv_total_size duration = iv_duration
     creation_date = sy-datum creation_time = sy-timlo ).

    INSERT crms4d_1o_create FROM ls_log.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_CRM_ORDER_TIMER_HOME=>START
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method START.
    GET RUN TIME FIELD mv_start.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_CRM_ORDER_TIMER_HOME=>STOP
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEXT                        TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method STOP.
    DATA: lv_end TYPE int8.

    GET RUN TIME FIELD lv_end.

    lv_end = lv_end - mv_start.

    CLEAR: mv_start.

    WRITE:/ |{ iv_text }: { lv_end } unit: microsecond| COLOR COL_GROUP.

  endmethod.
ENDCLASS.