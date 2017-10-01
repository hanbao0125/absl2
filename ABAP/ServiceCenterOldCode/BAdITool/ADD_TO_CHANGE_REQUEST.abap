method ADD_TO_CHANGE_REQUEST.

  DATA:
        ls_ko200         TYPE ko200.

* Check whether the user is allowed to edit the specific object
  ls_ko200-pgmid = gc_programid. "e.g. 'R3TR'
  ls_ko200-object = iv_type.     "e.g. 'TABL'
  ls_ko200-obj_name = iv_name.
  ls_ko200-devclass = iv_package.


  CALL FUNCTION 'TR_OBJECT_CHECK'
   EXPORTING
     WI_KO200                      = ls_ko200
*     IV_NO_STANDARD_EDITOR         = ' '
*     IV_NO_SHOW_OPTION             = ' '
*     IV_EXTERNALPS                 = ' '
*     IV_EXTERNALID                 = ' '
*     IV_NO_PS                      = ' '
*     IT_E071K_STR                  =
*     IT_OBJ_ENTRY                  =
*   IMPORTING
*     WE_ORDER                      =
*     WE_TASK                       =
*     WE_KO200                      =
*     WE_OBJECT_APPENDABLE          =
*     ES_TADIR                      =
*   TABLES
*     WT_E071K                      =
   EXCEPTIONS
     CANCEL_EDIT_OTHER_ERROR       = 1
     SHOW_ONLY_OTHER_ERROR         = 2
     OTHERS                        = 3
            .
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE /SFT/cx_ddic_adapter
      EXPORTING
        textid = /SFT/cx_ddic_adapter=>add_object_to_request_failed
*        previous =
        object_type = iv_type
        object_name = iv_name
        request = iv_request
        .

  ENDIF.


* Add object to the change request
CALL FUNCTION 'TR_OBJECT_INSERT'
 EXPORTING
   WI_ORDER                      = iv_request "Change request number (not task number)
   WI_KO200                      = ls_ko200
*   IV_NO_STANDARD_EDITOR         = ' '
*   IV_NO_SHOW_OPTION             = ' '
*   IV_EXTERNALPS                 = ' '
*   IV_EXTERNALID                 = ' '
*   IV_NO_PS                      = ' '
*   IV_OLD_CALL                   =
*   IT_E071K_STR                  =
*   IT_OBJ_ENTRY                  =
 IMPORTING
*   WE_ORDER                      =
*   WE_TASK                       =
*   WE_KO200                      =
   ES_TADIR                      = rs_tadir
* TABLES
*   WT_E071K                      =
 EXCEPTIONS
   CANCEL_EDIT_OTHER_ERROR       = 1
   SHOW_ONLY_OTHER_ERROR         = 2
   OTHERS                        = 3
          .
IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /SFT/cx_ddic_adapter
      EXPORTING
        textid = /SFT/cx_ddic_adapter=>add_object_to_request_failed
*        previous =
        object_type = iv_type
        object_name = iv_name
        request = iv_request
        .

ENDIF.


endmethod.
