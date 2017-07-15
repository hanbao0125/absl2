class CL_ABAP_GIT_ISSUE_IMAGE_TOOL definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_image_reference,
           image_name TYPE string,
           image_url TYPE string,
         END OF ty_image_reference .
  types:
    tt_image_reference TYPE TABLE OF ty_image_reference with key image_name .

  class-methods GET_IMAGE_REFERENCE
    importing
      !IV_ISSUE_SOURCE_CODE type STRING
    returning
      value(RT_IMAGE) type TT_IMAGE_REFERENCE .
protected section.
private section.

  class-data SV_IMAGE_PATTERN type STRING value '(!\[.*\]\(.*\))' ##NO_TEXT.
ENDCLASS.



CLASS CL_ABAP_GIT_ISSUE_IMAGE_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_IMAGE_TOOL=>GET_IMAGE_REFERENCE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ISSUE_SOURCE_CODE           TYPE        STRING
* | [<-()] RT_IMAGE                       TYPE        TT_IMAGE_REFERENCE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_image_reference.
    DATA: lv_reg_pattern TYPE string,
          lt_result_tab  TYPE match_result_tab.

    FIND ALL OCCURRENCES OF '![' IN iv_issue_source_code MATCH COUNT DATA(lv_count).
    CHECK lv_count > 0.
    lv_reg_pattern = sv_image_pattern.
    IF lv_count > 1.
      DO lv_count - 1 TIMES.
        lv_reg_pattern = lv_reg_pattern && '.*' && sv_image_pattern.
      ENDDO.
    ENDIF.
    TRY.
        FIND ALL OCCURRENCES OF REGEX lv_reg_pattern
             IN iv_issue_source_code
             RESULTS lt_result_tab.
      CATCH cx_root INTO DATA(cx_root).
        WRITE:/ cx_root->get_text( ).
        RETURN.
    ENDTRY.
    READ TABLE lt_result_tab ASSIGNING FIELD-SYMBOL(<result>) INDEX 1.
    CHECK sy-subrc = 0.

    LOOP AT <result>-submatches ASSIGNING FIELD-SYMBOL(<match>).
      WRITE:/ 'Match...........'.
      WRITE:/ iv_issue_source_code+<match>-offset(<match>-length).
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.