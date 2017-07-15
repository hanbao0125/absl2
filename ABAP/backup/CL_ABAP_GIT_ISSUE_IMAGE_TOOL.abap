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

  constants CV_API_URL type STRING value 'https://jerrylist.cfapps.eu10.hana.ondemand.com' ##NO_TEXT.

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_IMAGE_REFERENCE
    importing
      !IV_ISSUE_SOURCE_CODE type STRING
    returning
      value(RT_IMAGE) type TT_IMAGE_REFERENCE .
  class-methods GET_IMAGE_REF_VIA_JS_SERVICE
    importing
      !IV_ISSUE_SOURCE_CODE type STRING
    returning
      value(RT_IMAGE) type TT_IMAGE_REFERENCE .
protected section.
private section.

  class-data SV_IMAGE_PATTERN type STRING value '(!\[.*\]\(.*\))' ##NO_TEXT.
  class-data SO_CLIENT type ref to IF_HTTP_CLIENT .
ENDCLASS.



CLASS CL_ABAP_GIT_ISSUE_IMAGE_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_IMAGE_TOOL=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD class_constructor.
    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = cv_api_url
        proxy_host         = 'proxy.wdf.sap.corp'
        proxy_service      = '8080'
      IMPORTING
        client             = so_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    IF sy-subrc <> 0.
      WRITE:/ 'Error when creating client'.
      RETURN.
    ENDIF.

  ENDMETHOD.


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
*    IF lv_count > 1.
*      DO lv_count - 1 TIMES.
*        lv_reg_pattern = lv_reg_pattern && '.*' && sv_image_pattern.
*      ENDDO.
*    ENDIF.
    TRY.
        FIND REGEX lv_reg_pattern
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


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method CL_ABAP_GIT_ISSUE_IMAGE_TOOL=>GET_IMAGE_REF_VIA_JS_SERVICE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ISSUE_SOURCE_CODE           TYPE        STRING
* | [<-()] RT_IMAGE                       TYPE        TT_IMAGE_REFERENCE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_image_ref_via_js_service.
    DATA: lv_sysubrc LIKE sy-subrc,
          lv_message TYPE string,
          ls_data LIKE LINE OF rt_image.
    so_client->request->set_method( 'POST' ).
    so_client->request->set_content_type('application/x-www-form-urlencoded').
    so_client->request->set_form_field( name = 'markdown_source' value = iv_issue_source_code ).
    CALL METHOD so_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    IF sy-subrc <> 0.
      CALL METHOD so_client->get_last_error
        IMPORTING
          code    = lv_sysubrc
          message = lv_message.

      so_client->close( ).
      WRITE:/ 'Error:', lv_message.
      RETURN.
    ENDIF.

    CALL METHOD so_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    IF sy-subrc <> 0.
      CALL METHOD so_client->get_last_error
        IMPORTING
          code    = lv_sysubrc
          message = lv_message.

      so_client->close( ).
      WRITE:/ 'Error:', lv_message.
      RETURN.
    ENDIF.

    lv_message = so_client->response->get_cdata( ).

    CALL METHOD cl_abap_git_issue_tool=>parse_json_to_internal_table
      EXPORTING
        iv_json = lv_message
      IMPORTING
        et_node = DATA(node)
        ev_node_number = data(lv_num).

    so_client->close( ).

    DO lv_num TIMES.
       CLEAR: ls_data.
       LOOP AT node ASSIGNING FIELD-SYMBOL(<node>) WHERE index = sy-index.
          CASE <node>-attribute.
             WHEN 'localFile'.
                ls_data-image_name = <node>-value.
             WHEN 'fileUrl'.
                ls_data-image_url = <node>-value.
          ENDCASE.
       ENDLOOP.
       APPEND ls_data TO rt_image.
    ENDDO.
  ENDMETHOD.
ENDCLASS.