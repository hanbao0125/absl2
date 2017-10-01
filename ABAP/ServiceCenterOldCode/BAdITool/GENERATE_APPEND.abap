METHOD generate_append.

  DATA:
        lv_append_struct_name TYPE ddobjname,
        lv_position TYPE tabfdpos,
        lv_activation_result TYPE sy-subrc,

        ls_header TYPE dd02v,
        ls_field TYPE dd03p,

        lt_fields TYPE dd03ptab.

  FIELD-SYMBOLS:
        <ls_append_field> TYPE LINE OF tt_append_fields.

  lv_append_struct_name = iv_append_struct_name.

*  Define Header
  ls_header-tabname = lv_append_struct_name.       "Name of append structure
  ls_header-tabclass = gc_tabclass-append.         "Subtype of structure
  ls_header-sqltab = iv_enhanced_struct_name.      "Name of enhanced structure
  ls_header-ddlanguage = sy-langu.                 "Language
  ls_header-mainflag = sy-langu.                   "Language
  ls_header-exclass = 1.                           "This append structure cannot be enhanced
  ls_header-ddtext = gc_description.               "Description

* Define Fields
  lv_position = 0.
  LOOP AT it_fields ASSIGNING <ls_append_field>.
    lv_position = lv_position + 1.

    ls_field-position = lv_position.
    ls_field-tabname = lv_append_struct_name.
    ls_field-fieldname = <ls_append_field>-field_name.

    IF <ls_append_field>-type_category = /SFT/if_ddic_adapter=>gc_struc_comp_type-predef_data_type. "predefined data type
      ls_field-datatype = <ls_append_field>-predef_data_type.
      ls_field-leng = <ls_append_field>-predef_data_type_len.
      ls_field-decimals = <ls_append_field>-predef_data_type_decimal.

    ELSE.                    "For example: data element
      ls_field-rollname = <ls_append_field>-data_elem_type.
    ENDIF.

    APPEND ls_field TO lt_fields.
  ENDLOOP.

* Create Append Structure
  CALL FUNCTION 'DDIF_TABL_PUT'
    EXPORTING
      name              = lv_append_struct_name
      dd02v_wa          = ls_header
*     DD09L_WA          = ' '
    TABLES
      dd03p_tab         = lt_fields
*     DD05M_TAB         =
*     DD08V_TAB         =
*     DD35V_TAB         =
*     DD36M_TAB         =
    EXCEPTIONS
      tabl_not_found    = 1
      name_inconsistent = 2
      tabl_inconsistent = 3
      put_failure       = 4
      put_refused       = 5
      OTHERS            = 6.
  IF sy-subrc <> 0.

    RAISE EXCEPTION TYPE /SFT/cx_ddic_adapter
      EXPORTING
        textid      = /SFT/cx_ddic_adapter=>append_creation_failed
*       previous    =
*       object_type =
        object_name = lv_append_struct_name
*       namespace   =
*       request     =
      .

  ENDIF.


* Activate Append Structure
* Note: In the function module 'DDIF_TABL_ACTIVATE', its undelrying enhanced structure and
* the 'parent' structure of the underlying enhanced structure will be re-activated too automatically.
  IF iv_activate = abap_true.
    CALL FUNCTION 'DDIF_TABL_ACTIVATE'
      EXPORTING
        name        = lv_append_struct_name
*       AUTH_CHK    = 'X'
*       PRID        = -1
*       EXCOMMIT    = 'X'
      IMPORTING
        rc          = lv_activation_result "0: activated successfully; 4: activated with warnings; >4: cannot be activated
      EXCEPTIONS
        not_found   = 1
        put_failure = 2
        OTHERS      = 3.
    IF ( sy-subrc <> 0 ) OR ( lv_activation_result <> 0 AND lv_activation_result <> 4 ).
      RAISE EXCEPTION TYPE /SFT/cx_ddic_adapter
        EXPORTING
          textid      = /SFT/cx_ddic_adapter=>append_activation_failed
*         previous    =
*         object_type =
          object_name = lv_append_struct_name
*         namespace   =
*         request     =
        .

    ENDIF.

  ENDIF.
ENDMETHOD.
