class ZCL_CRM_SURVEY_TOOL definition
  public
  final
  create public .

public section.

  methods SUBMIT
    importing
      !IV_QUESTION1 type ABAP_BOOL
      !IV_QUESTION2 type ABAP_BOOL .
  PROTECTED SECTION.
private section.

  data MV_QUESTION_TEMPLATE type STRING .
  constants CV_QUESTION1_YES type STRING value 'survey/result/question1/answer1_placeholder=answer1_yes' ##NO_TEXT.
  constants CV_QUESTION2_YES type STRING value 'survey/result/question2/answer2_placeholder=answer2_yes' ##NO_TEXT.
  constants CV_GUID_PATTERN type STRING value '.*svyValueGuid(?:.*)value="(.*)">.*svyValueVersion.*' ##NO_TEXT.

  methods ASSEMBLE_REQUEST_BODY
    importing
      !IV_QUESTION1 type ABAP_BOOL
      !IV_QUESTION2 type ABAP_BOOL
      !IV_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_REQUEST_BODY) type STRING .
  methods GET_NEW_SURVEY_INSTANCE_GUID
    importing
      !IV_TEMPLATE type STRING
    returning
      value(RV_GUID) type CRMT_OBJECT_GUID .
  methods GET_REQUEST_PAYLOAD_HEADER
    importing
      !IV_VALUE_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_RESULT) type STRING .
  methods GET_SURVEY_TEMPLATE
    returning
      value(RV_TEMPLATE) type STRING .
ENDCLASS.



CLASS ZCL_CRM_SURVEY_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_SURVEY_TOOL->ASSEMBLE_REQUEST_BODY
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_QUESTION1                   TYPE        ABAP_BOOL
* | [--->] IV_QUESTION2                   TYPE        ABAP_BOOL
* | [--->] IV_GUID                        TYPE        CRMT_OBJECT_GUID
* | [<-()] RV_REQUEST_BODY                TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD assemble_request_body.
    rv_request_body = get_request_payload_header( iv_guid ).

    IF iv_question1 = abap_true AND iv_question2 = abap_true.
      rv_request_body = rv_request_body && cv_question1_yes && '&' && cv_question2_yes.
    ELSEIF iv_question1 = abap_true.
      rv_request_body = rv_request_body && cv_question1_yes.
    ELSEIF iv_question2 = abap_true.
      rv_request_body = rv_request_body && cv_question2_yes.
    ENDIF.

    rv_request_body = rv_request_body && '&onInputProcessing=SUBMIT'.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_SURVEY_TOOL->GET_NEW_SURVEY_INSTANCE_GUID
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TEMPLATE                    TYPE        STRING
* | [<-()] RV_GUID                        TYPE        CRMT_OBJECT_GUID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_new_survey_instance_guid.

    TRY.
        DATA(lo_regex) = NEW cl_abap_regex( pattern = cv_guid_pattern ).

        DATA(lo_matcher) = lo_regex->create_matcher( EXPORTING text = iv_template ).

        IF lo_matcher->match( ) <> abap_true.
          WRITE:/ 'fail in input scan!'.
          RETURN.
        ENDIF.

        DATA(lt_reg_match_result) = lo_matcher->find_all( ).

        READ TABLE lt_reg_match_result ASSIGNING FIELD-SYMBOL(<match>) INDEX 1.

        READ TABLE <match>-submatches ASSIGNING FIELD-SYMBOL(<sub>) INDEX 1.

        rv_guid = iv_template+<sub>-offset(<sub>-length).

      CATCH cx_root INTO DATA(cx_root).
        WRITE:/ cx_root->get_text( ).
        RETURN.
    ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_SURVEY_TOOL->GET_REQUEST_PAYLOAD_HEADER
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_VALUE_GUID                  TYPE        CRMT_OBJECT_GUID
* | [<-()] RV_RESULT                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_request_payload_header.
    rv_result = 'svyApplicationId=CRM_SURVEY_ACTIVITY&SurveyId=JERRY_TEST&svySurveyId=JERRY_TEST&svyVersion=0000000003&'
    && 'SchemaVersion=1&svySchemaVersion=1&svyLanguage=EN&conid=&svyValueGuid='
    && iv_value_guid && '&svyValueVersion=0000000001&svyMandatoryMessage='
    && 'Fill all mandatory fields before saving&'.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_CRM_SURVEY_TOOL->GET_SURVEY_TEMPLATE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_TEMPLATE                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_survey_template.
    DATA: vguid    TYPE crm_svy_db_sv_guid.
    DATA: vvers    TYPE crm_svy_db_svers.
    DATA: svy_content TYPE string.
    DATA: ret TYPE bapiret1.
    DATA: apppar   TYPE TABLE OF crm_svy_db_sv_pair.
    DATA: lv_x TYPE xstring.
    DATA lr_conv TYPE REF TO cl_abap_conv_in_ce.

    CALL FUNCTION 'CRM_SVY_SURVEY_GET'
      EXPORTING
        application_id     = 'CRM_SURVEY_ACTIVITY'
        survey_id          = 'JERRY_TEST'
        survey_version     = '0000000003'
        language           = 'E'
        media_type         = '01'
        parameter_xml      = 'CRM_SVY_BSP_SYSTEMPARAM.XML'
        values_guid        = vguid
        values_version     = vvers
      IMPORTING
        return             = ret
        content            = svy_content
      TABLES
        application_params = apppar.

    CALL FUNCTION 'CRM_SVY_DB_CONVERT_STRING2HEX'
      EXPORTING
        s = svy_content
      IMPORTING
        x = lv_x.

    CALL METHOD cl_abap_conv_in_ce=>create
      EXPORTING
        input = lv_x
      RECEIVING
        conv  = lr_conv.

    CALL METHOD lr_conv->read
      IMPORTING
        data = rv_template.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_CRM_SURVEY_TOOL->SUBMIT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_QUESTION1                   TYPE        ABAP_BOOL
* | [--->] IV_QUESTION2                   TYPE        ABAP_BOOL
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD submit.
    DATA: ret TYPE BAPIRET1.

* Step1: get Survey Template
    DATA(survey_template) = get_survey_template( ).

* Step2: create a new Survey instance guid

    DATA(survey_guid) = get_new_survey_instance_guid( survey_template ).

* Step3: assemble request body

    data(lv_request_body) = assemble_request_body( iv_question1 = iv_question1
                                                   iv_question2 = iv_question2
                                                   iv_guid      = survey_guid ).

* Step4: Submit survey
    CALL FUNCTION 'CRM_SVY_RESULT_DISPATCHER'
      EXPORTING
        survey_data = lv_request_body
      IMPORTING
        return      = ret.

    WRITE:/ |result: { ret-message } | COLOR COL_NEGATIVE.

    COMMIT WORK AND WAIT.

  ENDMETHOD.
ENDCLASS.