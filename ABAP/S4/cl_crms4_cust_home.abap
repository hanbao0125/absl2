class CL_CRMS4_CUST_HOME definition
  public
  create public .

public section.

  class-methods GET_RANDOM_CUSTOMIZING_VALUE
    importing
      !IV_TABNAME type TABNAME
    exporting
      value(EV_VALUE) type ANY .
protected section.
PRIVATE SECTION.

  TYPES    BEGIN OF ty_cust_prng.
  TYPES      tabname  TYPE tabname.
  TYPES      prng     TYPE REF TO cl_abap_random_int.
  TYPES      keyfield TYPE fieldname.
  TYPES      error    TYPE abap_bool.
  TYPES    END   OF ty_cust_prng.

  TYPES    ty_cust_prng_t TYPE STANDARD TABLE OF ty_cust_prng.

  CLASS-DATA gt_cust_prng TYPE ty_cust_prng_t .
ENDCLASS.



CLASS CL_CRMS4_CUST_HOME IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_CRMS4_CUST_HOME=>GET_RANDOM_CUSTOMIZING_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TABNAME                     TYPE        TABNAME
* | [<---] EV_VALUE                       TYPE        ANY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_random_customizing_value.

    DATA lr_cust_tab  TYPE REF TO data.
    DATA ls_cust_prng TYPE ty_cust_prng.
    DATA ls_dd03p     TYPE dd03p.
    DATA lt_dd03p     TYPE STANDARD TABLE OF dd03p.
    DATA lv_count     TYPE sydbcnt.
    DATA lv_fieldname TYPE fieldname.
    DATA lv_index     TYPE i.
    DATA lv_keyfields TYPE i.
    DATA lv_lines     TYPE i.

    FIELD-SYMBOLS <ls_table_line> TYPE any.
    FIELD-SYMBOLS <lt_table> TYPE table.
    FIELD-SYMBOLS <lv_keyfield> TYPE any.

    CLEAR ev_value.

    READ TABLE gt_cust_prng
      INTO ls_cust_prng
      WITH KEY tabname = iv_tabname.
    IF sy-subrc NE 0.
      CLEAR ls_cust_prng.
      ls_cust_prng-tabname = iv_tabname.
      CLEAR lt_dd03p.
      CLEAR lv_keyfields.
      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          name      = iv_tabname
        TABLES
          dd03p_tab = lt_dd03p
        EXCEPTIONS
          OTHERS    = 1.
      IF sy-subrc EQ 0.
        LOOP AT lt_dd03p INTO ls_dd03p
          WHERE keyflag = 'X'
          AND   rollname NE 'MANDT'.
          lv_keyfields = lv_keyfields + 1.
          lv_fieldname = ls_dd03p-fieldname.
        ENDLOOP.
        IF lv_keyfields GT 1.
          ls_cust_prng-error = 'X'.
        ELSE.
          SELECT COUNT( * ) FROM (iv_tabname) INTO lv_lines.
          IF lv_lines EQ 0.
            ls_cust_prng-error = 'X'.
          ELSE.
            ls_cust_prng-prng     = cl_abap_random_int=>create( min = 1 max = lv_lines ).
            ls_cust_prng-keyfield = lv_fieldname.
          ENDIF.
        ENDIF.
      ELSE.
        ls_cust_prng-error = abap_true.
      ENDIF.
      INSERT ls_cust_prng INTO TABLE gt_cust_prng.
    ENDIF.

    CHECK ls_cust_prng-error EQ abap_false.

    CREATE DATA lr_cust_tab TYPE STANDARD TABLE OF (iv_tabname).
    ASSIGN lr_cust_tab->* TO <lt_table>.
    SELECT * FROM (iv_tabname) INTO TABLE <lt_table>
      ORDER BY PRIMARY KEY.

    lv_index = ls_cust_prng-prng->get_next( ).
    READ TABLE <lt_table>
      ASSIGNING <ls_table_line>
      INDEX lv_index.
    ASSIGN COMPONENT ls_cust_prng-keyfield OF STRUCTURE <ls_table_line> TO <lv_keyfield>.
    IF sy-subrc EQ 0.
      ev_value = <lv_keyfield>.
    ENDIF.

  ENDMETHOD.
ENDCLASS.