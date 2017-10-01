class name:SF0A0001BADI_TR_TOOL
backup date:2009-04-02

class /SF0A0001/BADI_TR_TOOL definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/BADI_TR_TOOL
*"* do not include other source files here!!!

  class-data LV_FOR_COPY type I .

  class-methods CREATE_TR
    importing
      !IM_STRKORR type E070-STRKORR optional
      !IM_TR_DESC type E07T-AS4TEXT
      !IM_TR_TYPE type E070-TRFUNCTION
      !IM_TR_TARGET type E070-TARSYSTEM
    exporting
      !EX_TR_NO type TRKORR .
  class-methods RELEASE_TR
    importing
      !IM_TR_NO type TRKORR .

method CREATE_TR.
  CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
    EXPORTING
      WI_STRKORR        = im_strkorr
      wi_kurztext       = im_tr_desc
      wi_trfunction     = im_tr_type
      iv_tarsystem      = im_tr_target
    IMPORTING
      we_trkorr         = ex_tr_no
    EXCEPTIONS
      number_range_full = 1
      invalid_input     = 2
      no_authorization  = 3
      OTHERS            = 4.

CASE sy-subrc.

  WHEN 1.
    MESSAGE 'NUMBER_RANGE_FULL' TYPE 'E' DISPLAY LIKE 'E'. RETURN.
  WHEN 2.
    MESSAGE 'UNALLOWED_TRFUNCTION' TYPE 'E' DISPLAY LIKE 'E'. RETURN.
  WHEN 3.
    MESSAGE 'NO_AUTHORIZATION' TYPE 'E' DISPLAY LIKE 'E'. RETURN.
  WHEN 4.
    MESSAGE 'CREATE_TRANSPORT_ERROR' TYPE 'E' DISPLAY LIKE 'E'. RETURN.
ENDCASE.
endmethod.

method RELEASE_TR.
  CALL FUNCTION 'TR_RELEASE_REQUEST'
    EXPORTING
      IV_TRKORR                   = im_tr_no
      IV_DIALOG                   = ''
      IV_AS_BACKGROUND_JOB        = ''
      IV_DISPLAY_EXPORT_LOG       = 'X'
    EXCEPTIONS
      CTS_INITIALIZATION_FAILURE  = 1
      ENQUEUE_FAILED              = 2
      NO_AUTHORIZATION            = 3
      INVALID_REQUEST             = 4
      REQUEST_ALREADY_RELEASED    = 5
      REPEAT_TOO_EARLY            = 6
      ERROR_IN_EXPORT_METHODS     = 7
      OBJECT_CHECK_ERROR          = 8
      DOCU_MISSING                = 9
      DB_ACCESS_ERROR             = 10
      ACTION_ABORTED_BY_USER      = 11
      EXPORT_FAILED               = 12.

  CASE sy-subrc.
    WHEN 1.
      MESSAGE 'CTS_INITIALIZATION_FAILURE!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 2.
      MESSAGE 'ENQUEUE_FAILED!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 3.
      MESSAGE 'NO_AUTHORIZATION!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 4.
      MESSAGE 'INVALID_REQUEST !'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 5.
      MESSAGE 'REQUEST_ALREADY_RELEASED!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 6.
      MESSAGE 'REPEAT_TOO_EARLY!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 7.
      MESSAGE 'ERROR_IN_EXPORT_METHODS!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 8.
      MESSAGE 'OBJECT_CHECK_ERROR!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 9.
      MESSAGE 'DOCU_MISSING!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 10.
      MESSAGE 'DB_ACCESS_ERROR !'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 11.
      MESSAGE 'ACTION_ABORTED_BY_USER!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
    WHEN 12.
      MESSAGE 'EXPORT_FAILED!'  TYPE 'E' DISPLAY LIKE 'E'. RETURN.
  ENDCASE.
endmethod.