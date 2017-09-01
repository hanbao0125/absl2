REPORT rswbo011 .

DATA: gv_released   TYPE trboolean         VALUE ' '.

PARAMETERS: request  TYPE trkorr       obligatory,
            wobjchk  AS   CHECKBOX,    "without objects' check
            wlocking AS   CHECKBOX.    "without locking

*----------------------------------------------------------------------*
START-OF-SELECTION.

  IF sy-batch <> 'X'. MESSAGE e070(to). ENDIF.

  PERFORM release_request           USING request
                                          wobjchk
                                          wlocking
                                          gv_released.
  PERFORM send_info_popup           USING request
                                          wobjchk
                                          gv_released.
  PERFORM list_messages.

*&---------------------------------------------------------------------*
*&      Form  RELEASE_REQUEST
*&---------------------------------------------------------------------*
FORM release_request  USING    pv_trkorr                TYPE trkorr
                               pv_without_objects_check TYPE trboolean
                               pv_without_locking       TYPE trboolean
                               pv_released              TYPE trboolean.
  DATA: lv_msgid                 LIKE sy-msgid,
        lv_msgno                 LIKE sy-msgno,
        lv_msgv1                 LIKE sy-msgv1,
        lv_msgv2                 LIKE sy-msgv2,
        lv_msgv3                 LIKE sy-msgv3,
        lv_msgv4                 LIKE sy-msgv4,
        lv_without_objects_check TYPE trboolean,
        lv_without_locking       TYPE trboolean.

  lv_without_objects_check = pv_without_objects_check.
  lv_without_locking       = pv_without_locking.


  CLEAR pv_released.

  CALL FUNCTION 'ENQUEUE_E_TRKORR'
       EXPORTING
            trkorr = pv_trkorr
       EXCEPTIONS
            OTHERS = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  CALL FUNCTION 'TRINT_RELEASE_REQUEST'
       EXPORTING
            iv_trkorr                = pv_trkorr
            iv_dialog                = ' '
            iv_without_objects_check = lv_without_objects_check
            iv_without_locking       = lv_without_locking
       EXCEPTIONS
            error_in_export_methods  = 1
            OTHERS                   = 2.
  CASE sy-subrc.
    WHEN 0. pv_released = 'X'.
    WHEN 1.
      lv_msgid = sy-msgid. lv_msgno = sy-msgno. lv_msgv1 = sy-msgv1.
      lv_msgv2 = sy-msgv2. lv_msgv3 = sy-msgv3. lv_msgv4 = sy-msgv4.
      PERFORM read_memory.
      MESSAGE ID lv_msgid TYPE 'S' NUMBER lv_msgno
              WITH lv_msgv1 lv_msgv2 lv_msgv3 lv_msgv4.
    WHEN 2.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.

  CALL FUNCTION 'DEQUEUE_E_TRKORR'
       EXPORTING
            trkorr = pv_trkorr.
ENDFORM.                               " RELEASE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  SEND_INFO_POPUP
*&---------------------------------------------------------------------*
FORM send_info_popup      USING pv_trkorr                TYPE trkorr
                                pv_without_objects_check TYPE trboolean
                                pv_released              TYPE trboolean.

  DATA: lt_receivers  LIKE soos7      OCCURS 0 WITH HEADER LINE,
        ls_message    LIKE sotxtinfo,
        lv_title      LIKE soep-title.


  CLEAR: ls_message.

* choose correct message for info popup
  IF pv_without_objects_check = ' '.
    ls_message-msgid = 'TO'.
    IF pv_released = 'X'.
      ls_message-msgno = '066'.
    ELSE.
      ls_message-msgno = '064'.
    ENDIF.
  ELSE.
    ls_message-msgid = 'TR'.

    IF pv_released = 'X'.
      ls_message-msgno = '783'.
      ls_message-msgv1 = pv_trkorr.
    ELSE.
      ls_message-msgno = '784'.
      ls_message-msgv1 = 'RELEASE OF &'.
      REPLACE '&' WITH pv_trkorr INTO ls_message-msgv1.
    ENDIF.
  ENDIF.

  lv_title = text-001.
  REPLACE '&' WITH pv_trkorr INTO lv_title.

  lt_receivers-recnam = sy-uname.
  APPEND lt_receivers.

  CALL FUNCTION 'SO_EXPRESS_FLAG_SET'
       EXPORTING
            text_info   = ls_message
            inbox       = ' '
            popup_title = lv_title
       TABLES
            rec_tab     = lt_receivers
       EXCEPTIONS
            OTHERS      = 0.

ENDFORM.                               " SEND_INFO_POPUP

*&---------------------------------------------------------------------*
*&      Form  READ_MEMORY
*&---------------------------------------------------------------------*
FORM read_memory.
  DATA: lt_log                 LIKE trlogm       OCCURS 0,
        ls_log                 LIKE trlogm.

  CALL FUNCTION 'TRINT_READ_LOG_FROM_MEMORY'
       EXPORTING
            iv_logname_memory = 'APPEND_LOG'
       TABLES
            et_log            = lt_log
       EXCEPTIONS
            OTHERS            = 1.
  IF sy-subrc = 0.
    LOOP AT lt_log INTO ls_log.
      MESSAGE ID ls_log-ag TYPE 'S' NUMBER ls_log-msgnr
              WITH ls_log-var1 ls_log-var2 ls_log-var3 ls_log-var4.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " READ_MEMORY
*---------------------------------------------------------------------*
*       FORM list_messages                                            *
*---------------------------------------------------------------------*
FORM list_messages.
* list all messages that are used generically
  IF 1 = 2.
    MESSAGE s066(to). MESSAGE s064(to). MESSAGE s783(tr) WITH ''.
    MESSAGE s784(tr) WITH '' ''.
  ENDIF.
ENDFORM.