*&---------------------------------------------------------------------*
*& Report  /SF0A0001/BADI_SCAN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/BADI_SCAN.


TYPE-POOLS seoo.
TYPE-POOLS seoc.
TYPE-POOLS seop.

PARAMETERS: class TYPE string DEFAULT '/SFA0000K/PREH_DELI'.
DATA t1 TYPE STANDARD TABLE OF string.
DATA t2 TYPE STANDARD TABLE OF STOKES.
DATA t3 TYPE STANDARD TABLE OF SSTMNT.
DATA itab4 TYPE STANDARD TABLE OF char10.
DATA line TYPE STOKES.
DATA lv_index TYPE i VALUE 1.

TYPES: seop_source_string TYPE rswsourcet.

DATA source_expand TYPE SEOP_SOURCE_STRING.
DATA method_key TYPE SEOCPDKEY.
DATA temp LIKE LINE OF source_expand.
DATA lv_bo_entry TYPE STOKES.
DATA lv_string TYPE string.
DATA lv_class TYPE SEOCLSKEY.
DATA lt_method TYPE SEOO_METHODS_R.
DATA ls_method LIKE LINE OF lt_method.

lv_class-CLSNAME = class.

CALL FUNCTION 'SEO_METHOD_READ_ALL'
    EXPORTING
       CIFKEY = lv_class
    IMPORTING
       methods = lt_method.

LOOP AT lt_method INTO ls_method.
  CLEAR: method_key,source_expand,t2,t3.
  method_key-CLSNAME = class.
  method_key-CPDNAME = ls_method-CMPname.
  CALL FUNCTION 'SEO_METHOD_GET_SOURCE'
    EXPORTING
      MTDKEY = method_key
    IMPORTING
      SOURCE_expanded = source_expand.

  SCAN ABAP-source source_expand TOKENS INTO t2 STATEMENTS INTO t3.
  lv_string = 'Scan Method: ' && ls_method-CMPname.
  WRITE:/ lv_string COLOR COL_KEY.
  SKIP 2.
  lv_index = 1.

  LOOP AT t2 INTO line.
    IF line-str CS 'GET_LCP'.
       READ TABLE source_expand INTO temp INDEX line-ROW.
       READ TABLE t2 INTO lv_bo_entry INDEX ( lv_index + 1 ).
       lv_string = 'LCP source code( line ' && lv_bo_entry-row && ' ): ' && temp.
       WRITE:/ lv_string COLOR COL_HEADING.
       lv_string = 'BO Node Name: ' && lv_bo_entry-str.
       WRITE:/ lv_string COLOR COL_TOTAL.
       SKIP 1.
    ENDIF.
    IF line-str CS 'IN_BO_NODE_NAME'.
       READ TABLE source_expand INTO temp INDEX line-ROW.
       READ TABLE t2 INTO lv_bo_entry INDEX ( lv_index + 2 ).
       lv_string = 'Association Source BO Node Name (line: ' && line-row && ' ): ' && lv_bo_entry-str.
       WRITE:/ lv_string COLOR COL_POSITIVE.
    ENDIF.
    IF line-str CS 'IN_ASSOCIATION_NAME'.
       READ TABLE source_expand INTO temp INDEX line-ROW.
       READ TABLE t2 INTO lv_bo_entry INDEX ( lv_index + 2 ).
       lv_string = 'Association Name: (line: ' && line-row && ' ): ' && lv_bo_entry-str.
       WRITE:/ lv_string COLOR COL_GROUP.
       SKIP 1.
    ENDIF.
    lv_index = lv_index + 1.
  ENDLOOP.
ENDLOOP.