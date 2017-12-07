*&---------------------------------------------------------------------*
*& Report  ZFUN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZFUN.

PARAMETERS: command TYPE string LOWER CASE.

DATA: commtext(120) ,
      itab(255) OCCURS 10 WITH HEADER LINE.
commtext = command.
CALL 'SYSTEM' ID 'COMMAND' FIELD commtext ID 'TAB' FIELD itab[].

LOOP AT itab.
  WRITE itab.
ENDLOOP.

* enhanced 2017-12-7

*&---------------------------------------------------------------------*
*& Report ZLINUX
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlinux.
PARAMETERS: command TYPE string LOWER CASE DEFAULT 'ls -l //bas/CGC5/src/krn/abap/runt'.
DATA: commtext(120) ,
      itab(255)     OCCURS 10 WITH HEADER LINE,
      lv_folder     TYPE string.

START-OF-SELECTION.

  PERFORM init.
  CALL 'SYSTEM' ID 'COMMAND' FIELD commtext ID 'TAB' FIELD itab[].
  LOOP AT itab ASSIGNING FIELD-SYMBOL(<line>).

    FIND REGEX '^.*\.c|^.*\.cpp|^.*\.h' IN <line>.
    IF sy-subrc = 0.
      WRITE: / <line> COLOR COL_NEGATIVE.
      DATA(lv_line) = CONV char255( <line> ).
      HIDE lv_line.
    ELSE.
      WRITE: / <line>.
    ENDIF.
  ENDLOOP.

AT LINE-SELECTION.
   PERFORM display_source.

FORM display_source.
  SPLIT lv_line AT space INTO TABLE DATA(lt_file).
  DATA(index) = lines( lt_file ).
  DATA(lv_file_name) = lv_folder && '/' && lt_file[ index ].
  DATA(lv_op) = |cat { lv_file_name } |.
  SUBMIT zlinux WITH command EQ lv_op.
ENDFORM.

FORM init.
  commtext = command.
  SPLIT commtext AT space INTO TABLE DATA(lt_table).
  CHECK lines( lt_table ) = 3.
  lv_folder = lt_table[ 3 ].
ENDFORM.
