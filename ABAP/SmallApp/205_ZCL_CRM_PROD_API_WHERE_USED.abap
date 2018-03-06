class ZCL_CRM_PROD_API_WHERE_USED definition
  public
  final
  create public .

public section.

  methods RUN
    importing
      !IV_FUNC_NAME type EU_CRO_OBJ .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CRM_PROD_API_WHERE_USED IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_PROD_API_WHERE_USED->RUN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_FUNC_NAME                   TYPE        EU_CRO_OBJ
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD run.
    TYPES: BEGIN OF ty_line,
             object    TYPE tadir-obj_name, "RSFINDLST-object,
             program   TYPE rsfindlst-program,
             package   TYPE tadir-devclass,
             app_comp  TYPE tdevc-dlvunit,
             soft_comp TYPE df14l-ps_posid,
           END OF ty_line.

    TYPES: tt_line TYPE STANDARD TABLE OF ty_line WITH KEY object program.

    TYPES: BEGIN OF ty_location,
             devclass TYPE tdevc-devclass,
             dlvunit  TYPE df14l-ps_posid,
             ps_posid TYPE tdevc-dlvunit,
           END OF ty_location.

    TYPES: tt_location TYPE STANDARD TABLE OF ty_location WITH KEY devclass.
    DATA: lt_findstring TYPE TABLE OF rsfind,
          ls            LIKE LINE OF lt_findstring.
    DATA: it_answer    TYPE aab_where_used_tab,
          lt_result    TYPE tt_line,
          lt_tadir     TYPE STANDARD TABLE OF tadir,
          lt_include   TYPE STANDARD TABLE OF d010inc,
          ls_include   TYPE d010inc,
          ls_class     TYPE tadir,
          lt_info_func TYPE STANDARD TABLE OF info_func,
          lt_location  TYPE tt_location.

    ls-object = iv_func_name.
    APPEND ls TO lt_findstring.
    CALL FUNCTION 'RS_EU_CROSSREF'
      EXPORTING
        i_find_obj_cls           = 'FF'
        no_dialog                = 'X'
      TABLES
        i_findstrings            = lt_findstring
        o_founds                 = it_answer
      EXCEPTIONS
        not_executed             = 1
        not_found                = 2
        illegal_object           = 3
        no_cross_for_this_object = 4
        batch                    = 5
        batchjob_error           = 6
        wrong_type               = 7
        object_not_exist         = 8
        OTHERS                   = 9.

    MOVE-CORRESPONDING it_answer TO lt_result.
    CHECK lt_result IS NOT INITIAL.

    SELECT a~devclass a~dlvunit b~ps_posid FROM tdevc AS a INNER JOIN
       df14l AS b ON a~component = b~fctr_id INTO TABLE lt_location.
    SELECT obj_name devclass component INTO CORRESPONDING FIELDS OF TABLE lt_tadir
        FROM tadir FOR ALL ENTRIES IN lt_result WHERE obj_name = lt_result-object.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<result>).
      READ TABLE lt_tadir ASSIGNING FIELD-SYMBOL(<package>)
       WITH KEY obj_name = <result>-object.
      IF sy-subrc = 0.
        <result>-package = <package>-devclass.
      ELSEIF <result>-object CS '=' OR <result>-object CS 'CM0'.
        SPLIT <result>-object AT '=' INTO TABLE DATA(lt_split).
        IF lines( lt_split ) = 1.
          SPLIT <result>-object AT 'CM0' INTO TABLE lt_split.
        ENDIF.
        READ TABLE lt_split ASSIGNING FIELD-SYMBOL(<class>) INDEX 1.
        ASSERT sy-subrc = 0.
        SELECT SINGLE * INTO ls_class FROM tadir WHERE pgmid = 'R3TR'
           AND object = 'CLAS' AND obj_name = <class>.
        ASSERT sy-subrc = 0.
        <result>-package = ls_class-devclass.
      ELSE.
        SELECT SINGLE * INTO ls_include FROM d010inc
           WHERE include = <result>-object.
        IF sy-subrc = 0.
          SELECT * INTO TABLE lt_info_func FROM info_func
             WHERE pname = ls_include-master.
          READ TABLE lt_info_func ASSIGNING FIELD-SYMBOL(<index1>) INDEX 1.
          IF sy-subrc = 0.
            <result>-package = <index1>-devclass.
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE lt_location ASSIGNING FIELD-SYMBOL(<location>) WITH KEY
         devclass = <result>-package.
      IF sy-subrc = 0.
         <result>-app_comp = <location>-ps_posid.
         <result>-soft_comp = <location>-dlvunit.
      ENDIF.
    ENDLOOP.

    BREAK-POINT.
  ENDMETHOD.
ENDCLASS.