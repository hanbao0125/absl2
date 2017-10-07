REPORT  /ext/value_tab_tool.
* ----------------------------------------------------------------------------------------
* Variables
* ----------------------------------------------------------------------------------------
DATA: lv_dom_name       TYPE char32,
      lv_dtel_name      TYPE char32,
      lv_dbtab1_name    TYPE char32,
      lv_dbtab2_name    TYPE char32,
      lv_view_name      TYPE char32,
      lv_fugr_name      TYPE char32,
      lv_maintview_name TYPE char32,
      lv_text           TYPE bapi_msg.
DATA: lv_guid           TYPE sysuuid-c,
      lv_mandt_guid     TYPE sysuuid-c,
      lv_codevalue_guid TYPE sysuuid-c,
      lv_language_guid  TYPE sysuuid-c,
      lv_parent_guid    TYPE sysuuid-c,
      lv_parent_guid2   TYPE sysuuid-c,
      lv_parent_guid3   TYPE sysuuid-c.
DATA: lv_ddobjname      TYPE ddobjname.
DATA: lv_gotstate       TYPE ddgotstate.
DATA: ls_dd02v          TYPE dd02v.
DATA: lv_objname        TYPE sobj_name.
DATA: lv_table          TYPE dfies-lfieldname.
DATA: lv_exists         TYPE xfeld VALUE 'X'.
DATA: lv_fieldvalue     TYPE char255.
* ----------------------------------------------------------------------------------------
* internal tables and structures
* ----------------------------------------------------------------------------------------
DATA: lt_new_object         TYPE comt_gox_def_header,
      ls_new_object         TYPE coms_gox_def_header.
DATA: lt_old_object         TYPE comt_gox_def_header,
      ls_old_object         TYPE coms_gox_def_header.
DATA: ls_new_object_details TYPE coms_gox_table_entry_fields,
      ls_new_object_text    TYPE coms_gox_def_text.
DATA: lt_returntab          TYPE bapirettab,
      lt_resulttab          TYPE bapirettab,
      ls_return             TYPE bapiret2,
      ls_result             TYPE bapiret2.
DATA: lt_transport          TYPE comt_gox_trans_object,
      ls_transport          TYPE coms_gox_trans_object.
DATA: ls_tadir              TYPE tadir.
* ----------------------------------------------------------------------------------------
* Input-Screen with matchcodes
* ----------------------------------------------------------------------------------------
SELECTION-SCREEN: BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
PARAMETER: p_table TYPE char14 OBLIGATORY MATCHCODE OBJECT dd_bastab_for_view.
PARAMETER: p_fldlen TYPE num2 OBLIGATORY.
PARAMETER: p_devcl TYPE devclass OBLIGATORY MATCHCODE OBJECT devclass.
PARAMETER: p_transp TYPE tr_trkorr MATCHCODE OBJECT seef_mig_trkorr.
SELECTION-SCREEN: END OF BLOCK a1.
* ----------------------------------------------------------------------------------------
* Testing for already existing table and table/parts with error-message
* ----------------------------------------------------------------------------------------
AT SELECTION-SCREEN.
  IF p_fldlen > 30.
    MESSAGE text-003 TYPE 'E'.
  ENDIF.
  IF p_fldlen < 1.
    MESSAGE text-004 TYPE 'E'.
  ENDIF.
  IF p_devcl <> '$TMP' AND p_transp IS INITIAL.
    MESSAGE text-023 TYPE 'E'.
  ENDIF.
* ----------------------------------------------------------------------------------------
* Existence-Checks (are there any objects already existing)
* ----------------------------------------------------------------------------------------
* Is Domain already existing
  CONCATENATE p_table '_DOM' INTO lv_dom_name.
  lv_ddobjname = lv_dom_name.
  CALL FUNCTION 'DDIF_DOMA_GET' "#EC FB_OLDED
    EXPORTING
      name     = lv_ddobjname
      state    = ''
      langu    = sy-langu
    IMPORTING
      gotstate = lv_gotstate.
  IF NOT lv_gotstate IS INITIAL.
    CLEAR lv_gotstate.
    MESSAGE text-008 TYPE 'E'.
    LEAVE TO SCREEN 1000.
  ELSE.
    lv_exists = space.
  ENDIF.
* Is Dataelement already existing
  CONCATENATE p_table '_DT' INTO lv_dtel_name.
  lv_ddobjname = lv_dtel_name.
  CALL FUNCTION 'DDIF_DTEL_GET' "#EC FB_OLDED
    EXPORTING
      name     = lv_ddobjname
      state    = 'A'
      langu    = sy-langu
    IMPORTING
      gotstate = lv_gotstate.
  IF NOT lv_gotstate IS INITIAL.
    CLEAR lv_gotstate.
    MESSAGE text-013 TYPE 'E'.
    LEAVE TO SCREEN 1000.
  ELSE.
    lv_exists = space.
  ENDIF.
* Is Text-Table already existing
  CONCATENATE p_table '_T' INTO lv_dbtab2_name.
  lv_ddobjname = lv_dbtab2_name.
  CALL FUNCTION 'DDIF_TABL_GET' "#EC FB_OLDED
    EXPORTING
      name     = lv_ddobjname
      state    = 'A'
      langu    = sy-langu
    IMPORTING
      gotstate = lv_gotstate.
  IF NOT lv_gotstate IS INITIAL.
    CLEAR lv_gotstate.
    MESSAGE text-021 TYPE 'E'.
    LEAVE TO SCREEN 1000.
  ELSE.
    lv_exists = space.
  ENDIF.
* Is Name-Table already existing
  lv_dbtab1_name = p_table.
  lv_ddobjname = lv_dbtab1_name.
  CALL FUNCTION 'DDIF_TABL_GET' "#EC FB_OLDED
    EXPORTING
      name     = lv_ddobjname
      state    = 'A'
      langu    = sy-langu
    IMPORTING
      gotstate = lv_gotstate.
  IF NOT lv_gotstate IS INITIAL.
    CLEAR lv_gotstate.
    MESSAGE text-020 TYPE 'E'.
    LEAVE TO SCREEN 1000.
  ELSE.
    lv_exists = space.
  ENDIF.
** Is View already existing
*  CONCATENATE p_table '_V' INTO lv_view_name.
*  lv_ddobjname = lv_view_name.
*  CALL FUNCTION 'DDIF_VIEW_GET'
*    EXPORTING
*      name     = lv_ddobjname
*      state    = 'A'
*      langu    = sy-langu
*    IMPORTING
*      gotstate = lv_gotstate.
*  IF NOT lv_gotstate IS INITIAL.
*    CLEAR lv_gotstate.
*    MESSAGE text-022 TYPE 'E'.
*    LEAVE TO SCREEN 1000.
*  ELSE.
*    lv_exists = space.
*  ENDIF.
*
** Is Function-Group already existing
*  CONCATENATE p_table '_FUGR' INTO lv_fugr_name.
*  lv_objname = lv_fugr_name.
*  SELECT SINGLE * FROM tadir INTO ls_tadir
*       WHERE pgmid = 'R3TR'
*         AND object = 'FUGR'
*         AND obj_name = lv_objname.
*  IF sy-subrc = 0.
*    MESSAGE text-024 TYPE 'E'.
*    LEAVE TO SCREEN 1000.
*  ELSE.
*    lv_exists = space.
*  ENDIF.
START-OF-SELECTION.
* ----------------------------------------------------------------------------------------
  CHECK lv_exists = space.
* ----------------------------------------------------------------------------------------
* Create Domain
* ----------------------------------------------------------------------------------------
  REFRESH: lt_new_object,
           ls_new_object-details,
           lt_old_object.
  CLEAR: ls_new_object_details.
  ls_new_object-object_type = 'DOMAIN'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  ls_new_object-object_name = lv_dom_name.
  ls_new_object_details-fieldname = 'DATATYPE'.
  ls_new_object_details-fieldvalue = 'CHAR'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'LENG'.
  ls_new_object_details-fieldvalue = p_fldlen.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
  CLEAR ls_return.
  REFRESH lt_returntab.
  CALL FUNCTION 'GOX_GEN_DOMA_STD'
    EXPORTING
      iv_object_name = lv_dom_name
      it_object_new  = lt_new_object
      it_object_old  = lt_old_object
      iv_devclass    = p_devcl
      iv_request_wb  = p_transp
      iv_part_gen    = ''
    IMPORTING
      et_bapireturn  = lt_returntab.
  IF NOT lt_returntab IS INITIAL.
    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      MESSAGE ls_return-message TYPE ls_return-type.
      LEAVE TO SCREEN 1000.
    ELSE.
      CONCATENATE text-005 lv_dom_name text-007 p_fldlen INTO lv_text SEPARATED BY space.
      ls_result-message = lv_text.
      ls_result-type = 'I'.
      APPEND ls_result TO lt_resulttab.
      CLEAR ls_result.
    ENDIF.
  ELSE.
    CONCATENATE text-005 lv_dom_name text-007 p_fldlen INTO lv_text SEPARATED BY space.
    ls_result-message = lv_text.
    ls_result-type = 'I'.
    APPEND ls_result TO lt_resulttab.
    CLEAR ls_result.
  ENDIF.
* ----------------------------------------------------------------------------------------
* Create Data-Element
* ----------------------------------------------------------------------------------------
  REFRESH: lt_new_object,
           ls_new_object-details,
           lt_old_object.
  CLEAR: ls_new_object_details.
  ls_new_object-object_type = 'DATA_ELEMENT'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  ls_new_object-object_name = lv_dtel_name.
  ls_new_object_details-fieldname = 'ROLLNAME'.
  ls_new_object_details-fieldvalue = lv_dom_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'DOMNAME'.
  ls_new_object_details-fieldvalue = lv_dom_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'DDLANGUAGE'.
  ls_new_object_details-fieldvalue = sy-langu.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'AUTHCLASS'.
  ls_new_object_details-fieldvalue = '10'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
  CLEAR ls_return.
  REFRESH lt_returntab.
  CALL FUNCTION 'GOX_GEN_DTEL_STD'
    EXPORTING
      iv_object_name = lv_dtel_name
      it_object_new  = lt_new_object
      it_object_old  = lt_old_object
      iv_devclass    = p_devcl
      iv_request_wb  = p_transp
      iv_part_gen    = ''
    IMPORTING
      et_bapireturn  = lt_returntab.
  IF NOT lt_returntab IS INITIAL.
    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      MESSAGE ls_return-message TYPE ls_return-type.
      LEAVE TO SCREEN 1000.
    ELSE.
      CONCATENATE text-012 lv_dtel_name INTO lv_text SEPARATED BY space.
      ls_result-message = lv_text.
      ls_result-type = 'I'.
      APPEND ls_result TO lt_resulttab.
      CLEAR ls_result.
    ENDIF.
  ELSE.
    CONCATENATE text-012 lv_dtel_name INTO lv_text SEPARATED BY space.
    ls_result-message = lv_text.
    ls_result-type = 'I'.
    APPEND ls_result TO lt_resulttab.
    CLEAR ls_result.
  ENDIF.
* ----------------------------------------------------------------------------------------
* Create value table
* ----------------------------------------------------------------------------------------
  REFRESH: lt_new_object,
           ls_new_object-details,
           lt_old_object.
  CLEAR: ls_new_object_details.
* fill Details
* Header
  ls_new_object-object_type = 'TABLE'.
  ls_new_object-object_name = lv_dbtab1_name.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  lv_parent_guid = ls_new_object-key_guid.
  ls_new_object_details-fieldname = 'TABCLASS'.
  ls_new_object_details-fieldvalue = 'TRANSP'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'TABKAT'.
  ls_new_object_details-fieldvalue = '0'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'TABART'.
  ls_new_object_details-fieldvalue = 'APPL2'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'PUFFERUNG'.
  ls_new_object_details-fieldvalue = ' '.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CONTFLAG'.
  ls_new_object_details-fieldvalue = 'S'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'MAINFLAG'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'BUFFALLOW'.
  ls_new_object_details-fieldvalue = 'N'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'SCHFELDANZ'.
  ls_new_object_details-fieldvalue = '0'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
* Fields
* 1. Code value
  ls_new_object-object_type = 'TABLE_FIELD'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  ls_new_object-parent_key = lv_parent_guid.
  lv_parent_guid = lv_guid.
  ls_new_object-object_name = 'CODE_VALUE'.
  ls_new_object_details-fieldname = 'POSITION'.
  ls_new_object_details-fieldvalue = '1'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'KEYFLAG'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'NOTNULL'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'ROLLNAME'.
  ls_new_object_details-fieldvalue = lv_dtel_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
  CLEAR ls_return.
  REFRESH lt_returntab.
  CLEAR lv_parent_guid.
* Call function
  lv_dbtab1_name = p_table.
  CALL FUNCTION 'GOX_GEN_TABLE_STD'
    EXPORTING
      iv_object_name = lv_dbtab1_name
      it_object_new  = lt_new_object
      it_object_old  = lt_old_object
      iv_devclass    = p_devcl
      iv_request_wb  = p_transp
      iv_part_gen    = ''
    IMPORTING
      et_bapireturn  = lt_returntab.
  IF NOT lt_returntab IS INITIAL.
    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      MESSAGE ls_return-message TYPE ls_return-type.
      LEAVE TO SCREEN 1000.
    ELSE.
      CONCATENATE text-014 lv_dbtab1_name INTO lv_text SEPARATED BY space.
      ls_result-message = lv_text.
      ls_result-type = 'I'.
      APPEND ls_result TO lt_resulttab.
      CLEAR ls_result.
    ENDIF.
  ELSE.
    CONCATENATE text-014 lv_dbtab1_name INTO lv_text SEPARATED BY space.
    ls_result-message = lv_text.
    ls_result-type = 'I'.
    APPEND ls_result TO lt_resulttab.
    CLEAR ls_result.
  ENDIF.
* Enable SE16 maintenance
  lv_ddobjname = lv_dbtab1_name.
  CALL FUNCTION 'DDIF_TABL_GET' "#EC FB_OLDED
    EXPORTING
      name          = lv_ddobjname
      state         = 'A'
      langu         = sy-langu
    IMPORTING
      dd02v_wa      = ls_dd02v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
  ENDIF.
  ls_dd02v-mainflag = 'X'.
  CALL FUNCTION 'DDIF_TABL_PUT' "#EC FB_OLDED
    EXPORTING
      name              = lv_ddobjname
      dd02v_wa          = ls_dd02v
    EXCEPTIONS
      tabl_not_found    = 1
      name_inconsistent = 2
      tabl_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      OTHERS            = 6.
  IF sy-subrc <> 0.
  ENDIF.
  CALL FUNCTION 'DDIF_TABL_ACTIVATE' "#EC FB_OLDED
    EXPORTING
      name     = lv_ddobjname
      auth_chk = ' '.
  IF sy-subrc <> 0.
  ENDIF.
* ----------------------------------------------------------------------------------------
* Create value text table
* ----------------------------------------------------------------------------------------
  REFRESH: lt_new_object,
           ls_new_object-details,
           lt_old_object.
  CLEAR ls_new_object_details.
* fill Details
* Header
  ls_new_object-object_type = 'TABLE'.
  ls_new_object-object_name = lv_dbtab2_name.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  lv_parent_guid = ls_new_object-key_guid.
  ls_new_object_details-fieldname = 'TABCLASS'.
  ls_new_object_details-fieldvalue = 'TRANSP'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'TABKAT'.
  ls_new_object_details-fieldvalue = '0'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'TABART'.
  ls_new_object_details-fieldvalue = 'APPL2'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'PUFFERUNG'.
  ls_new_object_details-fieldvalue = ' '.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CONTFLAG'.
  ls_new_object_details-fieldvalue = 'S'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'BUFFALLOW'.
  ls_new_object_details-fieldvalue = 'N'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'SCHFELDANZ'.
  ls_new_object_details-fieldvalue = '0'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
* Fields
* 1. Code value
  ls_new_object-object_type = 'TABLE_FIELD'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  lv_codevalue_guid = lv_guid.
  ls_new_object-parent_key = lv_parent_guid.
  ls_new_object-object_name = 'CODE_VALUE'.
  ls_new_object_details-fieldname = 'POSITION'.
  ls_new_object_details-fieldvalue = '1'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'KEYFLAG'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'NOTNULL'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'ROLLNAME'.
  ls_new_object_details-fieldvalue = lv_dtel_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CHECKTABLE'.
  ls_new_object_details-fieldvalue = lv_dbtab1_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'FRKART'.
  ls_new_object_details-fieldvalue = 'TEXT'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
* 2. Language
  ls_new_object-object_type = 'TABLE_FIELD'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  lv_language_guid = lv_guid.
  ls_new_object-parent_key = lv_parent_guid.
  ls_new_object-object_name = 'LANGUAGE'.
  ls_new_object_details-fieldname = 'POSITION'.
  ls_new_object_details-fieldvalue = '2'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'KEYFLAG'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'NOTNULL'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'LANGUFLAG'.
  ls_new_object_details-fieldvalue = 'X'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'ROLLNAME'.
  ls_new_object_details-fieldvalue = 'SPRAS'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CHECKTABLE'.
  ls_new_object_details-fieldvalue = 'T002'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'FRKART'.
  ls_new_object_details-fieldvalue = 'KEY'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
* 3. Description
  ls_new_object-object_type = 'TABLE_FIELD'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  ls_new_object-parent_key = lv_parent_guid.
  ls_new_object-object_name = 'DESCRIPTION'.
  ls_new_object_details-fieldname = 'POSITION'.
  ls_new_object_details-fieldvalue = '3'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'ROLLNAME'.
  ls_new_object_details-fieldvalue = 'SAETEXT64'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
  CLEAR ls_return.
  REFRESH lt_returntab.
  CLEAR lv_parent_guid.
* Foreign Keys
* Code value
  ls_new_object-object_type = 'TABLE_FIELD_KEY'.
  ls_new_object-object_name = 'CODE_VALUE'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  ls_new_object-parent_key = lv_codevalue_guid. "For foreign key CODEVALUE needed
  ls_new_object_details-fieldname = 'FORTABLE'.
  ls_new_object_details-fieldvalue = lv_dbtab2_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'PRIMPOS'.
  ls_new_object_details-fieldvalue = '1'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CHECKTABLE'.
  ls_new_object_details-fieldvalue = lv_dbtab1_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CHECKFIELD'.
  ls_new_object_details-fieldvalue = 'CODEVALUE'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
* Language
  ls_new_object-object_type = 'TABLE_FIELD_KEY'.
  ls_new_object-object_name = 'LANGUAGE'.
  TRY.
      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
             ).
    CATCH cx_uuid_error .
  ENDTRY.
  ls_new_object-key_guid = lv_guid.
  ls_new_object-parent_key = lv_language_guid. "For foreign key LANGUAGE needed
  ls_new_object_details-fieldname = 'FORTABLE'.
  ls_new_object_details-fieldvalue = lv_dbtab2_name.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'PRIMPOS'.
  ls_new_object_details-fieldvalue = '2'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CHECKTABLE'.
  ls_new_object_details-fieldvalue = 'T002'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  ls_new_object_details-fieldname = 'CHECKFIELD'.
  ls_new_object_details-fieldvalue = 'LANGUAGE'.
  APPEND ls_new_object_details TO ls_new_object-details.
  CLEAR ls_new_object_details.
  APPEND ls_new_object TO lt_new_object.
  CLEAR ls_new_object.
* Call function
  CALL FUNCTION 'GOX_GEN_TABLE_STD'
    EXPORTING
      iv_object_name = lv_dbtab2_name
      it_object_new  = lt_new_object
      it_object_old  = lt_old_object
      iv_devclass    = p_devcl
      iv_request_wb  = p_transp
      iv_part_gen    = ''
    IMPORTING
      et_bapireturn  = lt_returntab.
  IF NOT lt_returntab IS INITIAL.
    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      MESSAGE ls_return-message TYPE ls_return-type.
      LEAVE TO SCREEN 1000.
    ELSE.
      CONCATENATE text-015 lv_dbtab2_name INTO lv_text SEPARATED BY space.
      ls_result-message = lv_text.
      ls_result-type = 'I'.
      APPEND ls_result TO lt_resulttab.
      CLEAR ls_result.
    ENDIF.
  ELSE.
    CONCATENATE text-015 lv_dbtab2_name INTO lv_text SEPARATED BY space.
    ls_result-message = lv_text.
    ls_result-type = 'I'.
    APPEND ls_result TO lt_resulttab.
    CLEAR ls_result.
  ENDIF.
* Enable SE16 maintenance
  lv_ddobjname = lv_dbtab2_name.
  CALL FUNCTION 'DDIF_TABL_GET' "#EC FB_OLDED
    EXPORTING
      name          = lv_ddobjname
      state         = 'A'
      langu         = sy-langu
    IMPORTING
      dd02v_wa      = ls_dd02v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
  ENDIF.
  ls_dd02v-mainflag = 'X'.
  CALL FUNCTION 'DDIF_TABL_PUT' "#EC FB_OLDED
    EXPORTING
      name              = lv_ddobjname
      dd02v_wa          = ls_dd02v
    EXCEPTIONS
      tabl_not_found    = 1
      name_inconsistent = 2
      tabl_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      OTHERS            = 6.
  IF sy-subrc <> 0.
  ENDIF.
  CALL FUNCTION 'DDIF_TABL_ACTIVATE' "#EC FB_OLDED
    EXPORTING
      name     = lv_ddobjname
      auth_chk = ' '.
  IF sy-subrc <> 0.
  ENDIF.
** ----------------------------------------------------------------------------------------
** Create Maintenance-View for both tables above
** ----------------------------------------------------------------------------------------
** View for both Tables
** ----------------------------------------------------------------------------------------
*
*  REFRESH: lt_new_object,
*           ls_new_object-details,
*           lt_old_object.
*  CLEAR: ls_new_object_details.
** fill Details
** Header
*  ls_new_object-object_type = 'VIEW'.
*  ls_new_object-object_name = lv_view_name.
*  ls_new_object_text-language = sy-langu.
*  ls_new_object_text-description = lv_view_name.
*  APPEND ls_new_object_text TO ls_new_object-object_text.
*  CLEAR ls_new_object_text.
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
*  lv_parent_guid = lv_guid.
** Header-Details
*  ls_new_object_details-fieldname = 'AGGTYPE'.
*  ls_new_object_details-fieldvalue = 'V'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROOTTAB'.
*  ls_new_object_details-fieldvalue = lv_dbtab1_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'VIEWCLASS'.
*  ls_new_object_details-fieldvalue = 'C'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ACTFLAG'.
*  ls_new_object_details-fieldvalue = 'X'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'MASTERLANG'.
*  ls_new_object_details-fieldvalue = sy-langu.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  CLEAR ls_new_object.
*
** Join Relationships
** In a Maintenance View you only can join tables by the foreign keys
** For that you can see the join-records in table DD26S.
** Attention: By the Client is the Foreign-Key-Table the same than the Value-Table.
**            Also the fields FORFIELD and FORDIR have to be empty.
*  ls_new_object-object_type = 'VIEW_JOIN_RELATIONS'.
*  ls_new_object-object_name = '0001'.              "TABPOS will be filled with that
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
*  lv_parent_guid3 = lv_guid.
*  ls_new_object-parent_key = lv_parent_guid.
** Join Relationships Details
*  ls_new_object_details-fieldname = 'TABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab1_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FORTABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab1_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  CLEAR ls_new_object.
*  REFRESH ls_new_object-details.
*
*  ls_new_object-object_type = 'VIEW_JOIN_RELATIONS'.
*  ls_new_object-object_name = '0002'.              "TABPOS will be filled with that
*  ls_new_object-parent_key = lv_parent_guid.
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
*  ls_new_object-parent_key = lv_parent_guid.
*  ls_new_object_details-fieldname = 'TABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab2_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FORTABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab1_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FORFIELD'.
*  ls_new_object_details-fieldvalue = 'CODEVALUE'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FORDIR'.
*  ls_new_object_details-fieldvalue = 'I'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  CLEAR ls_new_object.
*  REFRESH ls_new_object-details.
*
** Fields
*  ls_new_object-object_type = 'VIEW_FIELDS'.
*
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
** Attention: Here the parent-key have to be the key_guid. Otherwise the function
** will fill a wrong table-name in the input-structure and the view will not be
** activated
*  ls_new_object-parent_key = lv_guid.
** field-details
** Client
*  ls_new_object-object_name = 'MANDT'.
*  ls_new_object_details-fieldname = 'OBJPOS'.
*  ls_new_object_details-fieldvalue = '1'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'TABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab1_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FIELDNAME'.
*  ls_new_object_details-fieldvalue = 'MANDT'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'VIEWFIELD'.
*  ls_new_object_details-fieldvalue = 'MANDT'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'KEYFLAG'.
*  ls_new_object_details-fieldvalue = 'X'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAME'.
*  ls_new_object_details-fieldvalue = 'MANDT'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAMEVI'.
*  ls_new_object_details-fieldvalue = 'MANDT'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  REFRESH ls_new_object-details.
** Codevalue
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
** Attention: Here the parent-key have to be the key_guid. Otherwise the function
** will fill a wrong table-name in the input-structure and the view will not be
** activated
*  ls_new_object-parent_key = lv_guid.
*  ls_new_object-object_name = 'CODEVALUE'.
*  ls_new_object_details-fieldname = 'OBJPOS'.
*  ls_new_object_details-fieldvalue = '2'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'VIEWFIELD'.
*  ls_new_object_details-fieldvalue = 'CODEVALUE'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'TABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab1_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FIELDNAME'.
*  ls_new_object_details-fieldvalue = 'CODEVALUE'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'KEYFLAG'.
*  ls_new_object_details-fieldvalue = 'X'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAME'.
*  ls_new_object_details-fieldvalue = lv_dtel_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAMEVI'.
*  ls_new_object_details-fieldvalue = lv_dtel_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  REFRESH ls_new_object-details.
*
** SPRAS
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
** Attention: Here the parent-key have to be the key_guid. Otherwise the function
** will fill a wrong table-name in the input-structure and the view will not be
** activated
*  ls_new_object-parent_key = lv_guid.
*  ls_new_object-object_name = 'SPRAS'.
*  ls_new_object_details-fieldname = 'OBJPOS'.
*  ls_new_object_details-fieldvalue = '3'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'VIEWFIELD'.
*  ls_new_object_details-fieldvalue = 'SPRAS'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'TABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab2_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FIELDNAME'.
*  ls_new_object_details-fieldvalue = 'SPRAS'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'KEYFLAG'.
*  ls_new_object_details-fieldvalue = 'X'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAME'.
*  ls_new_object_details-fieldvalue = 'SPRAS'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAMEVI'.
*  ls_new_object_details-fieldvalue = 'SPRAS'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  REFRESH ls_new_object-details.
*
** Description
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
** Attention: Here the parent-key have to be the key_guid. Otherwise the function
** will fill a wrong table-name in the input-structure and the view will not be
** activated
*  ls_new_object-parent_key = lv_guid.
*  ls_new_object-object_name = 'DESCRIPTION'.
*  ls_new_object_details-fieldname = 'OBJPOS'.
*  ls_new_object_details-fieldvalue = '4'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'VIEWFIELD'.
*  ls_new_object_details-fieldvalue = 'DESCRIPTION'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'TABNAME'.
*  ls_new_object_details-fieldvalue = lv_dbtab2_name.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FIELDNAME'.
*  ls_new_object_details-fieldvalue = 'DESCRIPTION'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAME'.
*  ls_new_object_details-fieldvalue = 'SAETEXT64'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'ROLLNAMEVI'.
*  ls_new_object_details-fieldvalue = 'SAETEXT64'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'KEYFLAG'.
*  ls_new_object_details-fieldvalue = ''.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*
*  APPEND ls_new_object TO lt_new_object.
*  CLEAR ls_new_object.
*  REFRESH ls_new_object-details.
*
** Call function
*  CLEAR ls_return.
*  REFRESH lt_returntab.
*  CALL FUNCTION 'GOX_GEN_VIEW_STD'
*    EXPORTING
*      iv_object_name = lv_view_name
*      it_object_new  = lt_new_object
*      it_object_old  = lt_old_object
*      iv_devclass    = p_devcl
*      iv_request_wb  = p_transp
*      iv_part_gen    = ''
*    IMPORTING
*      et_bapireturn  = lt_returntab.
*  IF NOT lt_returntab IS INITIAL.
*    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
*    IF sy-subrc = 0.
*      MESSAGE ls_return-message TYPE ls_return-type.
*      LEAVE TO SCREEN 1000.
*    ELSE.
*      CONCATENATE text-016 lv_view_name INTO lv_text SEPARATED BY space.
*      ls_result-message = lv_text.
*      ls_result-type = 'I'.
*      APPEND ls_result TO lt_resulttab.
*      CLEAR ls_result.
*    ENDIF.
*  ELSE.
*    CONCATENATE text-016 lv_view_name INTO lv_text SEPARATED BY space.
*    ls_result-message = lv_text.
*    ls_result-type = 'I'.
*    APPEND ls_result TO lt_resulttab.
*    CLEAR ls_result.
*  ENDIF.
** ----------------------------------------------------------------------------------------
** Create Function-Group
** ----------------------------------------------------------------------------------------
*
*  REFRESH: lt_new_object,
*           ls_new_object-details,
*           lt_old_object.
*
*  CLEAR: ls_new_object_details.
** fill Details
** Header
*  ls_new_object-object_type = 'FUNCTION_GROUP'.
*  ls_new_object-object_name = lv_fugr_name.
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
*  APPEND ls_new_object TO lt_new_object.
*  CLEAR ls_new_object.
** Call function
*  CLEAR ls_return.
*  REFRESH lt_returntab.
*  CALL FUNCTION 'GOX_GEN_FUNCTION_GROUP'
*    EXPORTING
*      iv_object_name = lv_fugr_name
*      it_object_new  = lt_new_object
*      it_object_old  = lt_old_object
*      iv_devclass    = p_devcl
*      iv_request_wb  = p_transp
*      iv_part_gen    = ''
*    IMPORTING
*      et_bapireturn  = lt_returntab.
*  IF NOT lt_returntab IS INITIAL.
*    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
*    IF sy-subrc = 0.
*      MESSAGE ls_return-message TYPE ls_return-type.
*      LEAVE TO SCREEN 1000.
*    ELSE.
*      CONCATENATE text-018 lv_fugr_name INTO lv_text SEPARATED BY space.
*      ls_result-message = lv_text.
*      ls_result-type = 'I'.
*      APPEND ls_result TO lt_resulttab.
*      CLEAR ls_result.
*    ENDIF.
*  ELSE.
*    CONCATENATE text-018 lv_fugr_name INTO lv_text SEPARATED BY space.
*    ls_result-message = lv_text.
*    ls_result-type = 'I'.
*    APPEND ls_result TO lt_resulttab.
*    CLEAR ls_result.
*  ENDIF.
*
** ----------------------------------------------------------------------------------------
** Bind the tables to the new function-group and create a transport-task for it (like SE54)
** ----------------------------------------------------------------------------------------
** ========================>>>> hier gehts weiter - C5049302
*  REFRESH: lt_new_object,
*           ls_new_object-details,
*           lt_old_object.
*  CLEAR: ls_new_object_details.
** Fill Details
** Header
*  ls_new_object-object_type = 'VIEWMAINT'.
*  ls_new_object-object_name = lv_view_name.
*  TRY.
*      lv_guid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32(
*             ).
*    CATCH cx_uuid_error .
*  ENDTRY.
*  ls_new_object-key_guid = lv_guid.
*  ls_new_object_details-fieldname = 'FUNCTIONSGROUP'.
*  ls_new_object_details-fieldvalue = lv_fugr_name..
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'LISTE'.
*  ls_new_object_details-fieldvalue = '501'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'TYPE'.
*  ls_new_object_details-fieldvalue = '1'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  ls_new_object_details-fieldname = 'FUGR_OWNER'.
*  ls_new_object_details-fieldvalue = 'X'.
*  APPEND ls_new_object_details TO ls_new_object-details.
*  CLEAR ls_new_object_details.
*  APPEND ls_new_object TO lt_new_object.
*  CLEAR ls_new_object.
*
** Call function
*  CLEAR ls_return.
*  REFRESH lt_returntab.
*  CALL FUNCTION 'GOX_GEN_VIEWMAINT'
*    EXPORTING
*      iv_object_name = lv_view_name
*      it_object_new  = lt_new_object
*      it_object_old  = lt_old_object
*      iv_devclass    = p_devcl
*      iv_request_wb  = p_transp
*      iv_part_gen    = ''
*    IMPORTING
*      et_bapireturn  = lt_returntab.
*  IF NOT lt_returntab IS INITIAL.
*    READ TABLE lt_returntab INTO ls_return WITH KEY type = 'E'.
*    IF sy-subrc = 0.
*      MESSAGE ls_return-message TYPE ls_return-type.
*      LEAVE TO SCREEN 1000.
*    ELSE.
*      CONCATENATE text-019 lv_view_name INTO lv_text SEPARATED BY space.
*      ls_result-message = lv_text.
*      ls_result-type = 'I'.
*      APPEND ls_result TO lt_resulttab.
*      CLEAR ls_result.
*    ENDIF.
*  ELSE.
*    CONCATENATE text-019 lv_view_name INTO lv_text SEPARATED BY space.
*    ls_result-message = lv_text.
*    ls_result-type = 'I'.
*    APPEND ls_result TO lt_resulttab.
*    CLEAR ls_result.
*  ENDIF.
*
** ----------------------------------------------------------------------------------------
** END-OF-PROGRAM.
** ----------------------------------------------------------------------------------------
* Read Results
  LOOP AT lt_resulttab INTO ls_result.
    WRITE: /1 ls_result-type, ls_result-message.
  ENDLOOP.
  WRITE: /1 text-006.
