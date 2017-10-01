  METHOD change_method_code.

    DATA: ls_mtdkey TYPE seocpdkey,
          lv_source_code TYPE rswsourcet,
          lv_dummy TYPE string.

    ls_mtdkey-clsname = mv_class_key.
    ls_mtdkey-cpdname = iv_method_name.
    lv_source_code = it_source_code.

    CALL FUNCTION 'SEO_METHOD_GENERATE_INCLUDE'
      EXPORTING
        mtdkey                         = ls_mtdkey
*       VERSION                        = SEOC_VERSION_ACTIVE
        force                          = seox_true
*       REDEFINE                       = SEOX_FALSE
*       SUPPRESS_CORR                  = SEOX_FALSE
        implementation_expanded        = lv_source_code
*       IMPLEMENTATION                 =
*       SUPPRESS_MTDKEY_CHECK          = SEOX_FALSE
*       EDITOR_LOCK                    = SEOX_FALSE
*       GENERATED                      = SEOX_FALSE
*       CORRNR                         =
*       WITHOUT_METHOD_FRAME           = SEOX_FALSE
*       WITH_SUPER_CALL                = SEOX_FALSE
*       SUPPRESS_INDEX_UPDATE          = SEOX_FALSE
*       EXTEND                         = SEOX_FALSE
*       ENHANCEMENT                    = ' '
*       SUPPRESS_MODIFICATION_SUPPORT  = SEOX_FALSE
      EXCEPTIONS
        not_existing                   = 1
        model_only                     = 2
        include_existing               = 3
        method_imp_not_generated       = 4
        method_imp_not_initialised     = 5
        _internal_class_not_existing   = 6
        _internal_method_overflow      = 7
        cancelled                      = 8
        method_is_abstract_implemented = 9
        method_is_final_implemented    = 10
        internal_error_insert_report   = 11
        OTHERS                         = 12.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
      RAISE EXCEPTION TYPE /SFT/cx_class_handling.
    ENDIF.



  ENDMETHOD.
