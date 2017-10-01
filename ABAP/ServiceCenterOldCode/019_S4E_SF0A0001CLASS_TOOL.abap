class name: SF0A0001CLASS_TOOL
backup date: 2009-04-02

class /SF0A0001/CLASS_TOOL definition
  public
  final
  create public .

public section.

  type-pools SEOC .
  type-pools SEOK .
  type-pools SEOO .

  types:
    ty_intf_list  type table of seoclsname .
  types:
    BEGIN OF attr_info,
         CLSNAME TYPE  SEOCLSNAME,
         CMPNAME TYPE SEOCMPNAME,
         DESCRIPT TYPE SEODESCR,
         EXPOSURE TYPE SEOEXPOSE,
         ATTDECLTYP TYPE SEOATTDECL,
         ATTRDONLY TYPE SEORDONLY,
         TYPTYPE TYPE SEOTYPTYPE,
         TYPE TYPE RS38L_TYP,
         ATTVALUE TYPE SEOVALUE,
   END OF ATTR_INFO .
  types:
    BEGIN OF ty_meth_def,
          name TYPE seocmpname,
          decl_type TYPE seomtddecl,
          visibility TYPE seoexpose,
          type TYPE seomtdtype,
          evnthdlr_for_class TYPE seoclsname,
          evnt_name TYPE string,
          descr TYPE string,
          is_final TYPE seofinal,
          is_abstract TYPE seoabstrct,
    END OF ty_meth_def .
  types:
    BEGIN OF ty_param,
      name TYPE seocmpname,
      decl_type TYPE seopardecl,
      data_type TYPE string,
      typing TYPE seotyptype,
      is_optional TYPE seooptionl,
      def_value TYPE seovalue,
      descr TYPE string,
    END OF ty_param .
  types:
    ty_param_list type table of ty_param .
  types:
    ty_meth_exceps type  table of seoclsname .
  types:
    begin of ty_event_def,
       name type seocmpname,
       decl_type type  SEOEVTDECL,
       visibility type seoexpose,
       description  type string,
    end of ty_event_def .
  types:
    begin of ty_Type,
      name  type seocmpname,
      descript type string,
      state type seoclass ,
      visibility type seoexpose,
      typing type seotyptype,
      source type  seo_section_source,
      end of ty_type .
  types:
    ty_method_list type table of seocmpname .

  data NAME type SEOCLSKEY .

  methods ACTIVATE_CLASS.
  methods ADD_INHERITENCE
    changing
      !INH_DATA type VSEOEXTEND .
  methods CONSTRUCTOR
    importing
      !CL_NAME type SEOCLSNAME .
  methods GET_NAME
    returning
      value(NAME) type SEOCLSNAME .
  methods LOCK.
  methods ADD_METHOD
    importing
      !METH_DEF_DETAILS type TY_METH_DEF
      !METH_PARAMS type TY_PARAM_LIST optional
      !METH_SOURCE type SEO_SECTION_SOURCE
      !METH_EXCEPTIONS type TY_METH_EXCEPS optional.
  methods SAVE .
  methods UNLOCK .
  methods DELETE_INTF_IMPS .

private section.


  data IT_METHODS_SOURCE type SEO_METHOD_SOURCE_TABLE .
  data NATIVE_MTHD_GEN type SEOFLAG .
  data METH_LIST_DELETE type TY_METHOD_LIST .

METHOD activate_class.
  DATA lv_cls_name TYPE trobj_name..
  DATA lv_dummy    TYPE string.
  lv_cls_name = name.

*  CALL FUNCTION 'RS_WORKING_OBJECT_ACTIVATE'
*    EXPORTING
*      object                     = seok_r3tr_class
*      obj_name                   = lv_cls_name
*      force_activation           = 'X'
**     ACTIVATE_ONLY_THIS_OBJECT  =
**     OBJECT_SAVED               =
**     DICTIONARY_ONLY            = ' '
**     P_WB_MANAGER               =
**   EXPORTING
**     P_CALLER_PROGRAM           =
**   IMPORTING
**     BIND_ERROR_WINDOW          =
**   TABLES
**     OBJECTS                    =
*   EXCEPTIONS
*     OBJECT_NOT_IN_WORKING_AREA = 1
*     EXECUTION_ERROR            = 2
*     CANCELLED                  = 3
*     INSERT_INTO_CORR_ERROR     = 4
*     OTHERS                     = 5
*    .
  CALL FUNCTION 'CLAS_OBJECT_ACTIVATE'
    EXPORTING
      object_name = lv_cls_name
    EXCEPTIONS
      failed      = 1
      OTHERS      = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.

  ENDIF.
ENDMETHOD.

method ADD_INHERITENCE.
  DATA lv_dummy TYPE string.
  CALL FUNCTION 'SEO_INHERITANC_CREATE_F_DATA'
EXPORTING
   SAVE                  = SEOX_FALSE
  CHANGING
    INHERITANCE           = inh_data
*   REDEFINITIONS         =*
EXCEPTIONS
   EXISTING              = 1
   IS_COMPRISING         = 2
   IS_IMPLEMENTING       = 3
   RECURSION             = 4
   NOT_CREATED           = 5
   DB_ERROR              = 6
   OTHERS                = 7.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 INTO lv_dummy.
    return.
  ENDIF.
endmethod.

METHOD add_method.
  DATA: meth TYPE vseomethod,
        param TYPE vseoparam,
        meth_param TYPE ty_param,
        meth_src TYPE seo_method_source,
        mtdkey TYPE seocpdkey,
        lv_dummy TYPE string.

* populate method definition
  meth-clsname = name.
  meth-cmpname = meth_def_details-name.
  meth-descript = meth_def_details-descr.
  meth-state =  seoc_state_implemented.
  meth-exposure = meth_def_details-visibility.
  meth-mtddecltyp = meth_def_details-decl_type.
  meth-mtdfinal = meth_def_details-is_final.
  meth-mtdabstrct = meth_def_details-is_abstract.

* create method

  CALL FUNCTION 'SEO_METHOD_CREATE_F_DATA'
    EXPORTING
      save         = seox_false
    CHANGING
      method       = meth
    EXCEPTIONS
      existing     = 1
      is_event     = 2
      is_type      = 3
      is_attribute = 4
      not_created  = 5
      db_error     = 6
      OTHERS       = 7.

  IF sy-subrc = 1 .
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
    "nothing to do method already exists
    RETURN.
  ELSEIF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.

  ENDIF.

  LOOP AT meth_params INTO meth_param.
    CLEAR param.
* populate parameters
    param-clsname = name.
    param-cmpname = meth_def_details-name.
    param-sconame = meth_param-name.
    param-cmptype = seoo_cmptype_method.
    param-pardecltyp = meth_param-decl_type.
    param-typtype = meth_param-typing.
    param-type = meth_param-data_type.
    param-paroptionl = meth_param-is_optional.
    param-parvalue = meth_param-def_value.
    param-descript = meth_param-descr.

* create parameters
    CALL FUNCTION 'SEO_PARAMETER_CREATE_F_DATA'
      EXPORTING
        save      = seox_false
      CHANGING
        parameter = param
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.

    ENDIF.

  ENDLOOP.

* create exceptions
  DATA excep_name TYPE seoclsname.
  DATA meth_excep TYPE vseoexcep.
  LOOP AT meth_exceptions INTO excep_name.
    meth_excep-cmpname = meth_def_details-name.
    meth_excep-clsname = name.
    meth_excep-sconame = excep_name.

    CALL FUNCTION 'SEO_EXCEPTION_CREATE_F_DATA'
*       EXPORTING
*         SAVE                         = SEOX_TRUE
*         SUPPRESS_LOG_ENTRY           = SEOX_FALSE
      CHANGING
        excep                        = meth_excep
     EXCEPTIONS
       existing                     = 1
       is_parameter                 = 2
       not_created                  = 3
       db_error                     = 4
       component_not_existing       = 5
       OTHERS                       = 6
              .
    IF sy-subrc <> 0.

    ENDIF.

  ENDLOOP.


  meth_src-source = meth_source.
* meth_src-redefine = '?'.

  IF native_mthd_gen = 'X'.
* adding the method source the native way
*
* add method source to the class buffer
* when saving the class the method sources are inserted to the database
    meth_src-cpdname = meth_def_details-name.
    APPEND meth_src TO it_methods_source.
  ELSE.
* adding the implementation using the API
    mtdkey-clsname = name.
    mtdkey-cpdname = meth_def_details-name.
    CALL FUNCTION 'SEO_METHOD_GENERATE_INCLUDE'
      EXPORTING
        mtdkey                  = mtdkey
        force                   = seox_true
        redefine                = meth_src-redefine
        implementation_expanded = meth_src-source
        suppress_index_update   = seox_false
        suppress_corr           = 'X'
      EXCEPTIONS
        OTHERS                  = 1.
    IF sy-subrc <> 0.

    ENDIF.
  ENDIF.

ENDMETHOD.

METHOD constructor.
  me->name = cl_name.
  TRANSLATE me->name TO UPPER CASE .
ENDMETHOD.

METHOD delete_intf_imps.
  DATA ls_cls_key TYPE seoclskey.
  DATA lt_imp_list TYPE seor_implementing_keys.
  DATA lt_imp_comp_list TYPE seor_implementing_keys.
  DATA ls_imp_key TYPE seor_implementing_key.
  DATA lv_dummy TYPE string.
  ls_cls_key-clsname = name.

  CALL FUNCTION 'SEO_CLASS_ALL_IMPLEMENTG_GET'
    EXPORTING
      clskey       = ls_cls_key
*     VERSION      = SEOC_VERSION_INACTIVE
*     STATE        = '1'
    IMPORTING
      set          = lt_imp_list
    EXCEPTIONS
      not_existing = 1
      is_interface = 2
      model_only   = 3
      OTHERS       = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.
  ENDIF.
  SORT lt_imp_list DESCENDING.

  LOOP  AT lt_imp_list INTO ls_imp_key.


    CALL FUNCTION 'SEO_IMPLEMENTG_DELETE_W_DEPS'
      EXPORTING
        impkey              = ls_imp_key
        save                = seox_false
*       DELETE_WITH_ALIASES = SEOX_TRUE
      EXCEPTIONS
        not_existing        = 1
        is_inheritance      = 2
        is_comprising       = 3
        not_deleted         = 4
        db_error            = 5
        OTHERS              = 6.
    IF sy-subrc <> 0.
      APPEND ls_imp_key TO lt_imp_comp_list.

    ENDIF.


  ENDLOOP.

  LOOP  AT lt_imp_comp_list INTO ls_imp_key.


    CALL FUNCTION 'SEO_IMPLEMENTG_DELETE_W_DEPS'
      EXPORTING
        impkey              = ls_imp_key
        save                = seox_false
*       DELETE_WITH_ALIASES = SEOX_TRUE
      EXCEPTIONS
        not_existing        = 1
        is_inheritance      = 2
        is_comprising       = 3
        not_deleted         = 4
        db_error            = 5
        OTHERS              = 6.
    IF sy-subrc <> 0.
      APPEND ls_imp_key TO lt_imp_comp_list.

    ENDIF.


  ENDLOOP.


ENDMETHOD.

method GET_NAME.
  name = me->name.
endmethod.

METHOD lock.
  DATA access_mode TYPE seok_access_mode.
  DATA lv_dummy TYPE string.


  CALL FUNCTION 'SEO_CLASS_GET'
    EXPORTING
      clskey       = name
      version      = seoc_version_inactive
      state        = '0'
    EXCEPTIONS
      not_existing = 1
      deleted      = 2
      is_interface = 3
      model_only   = 4
      OTHERS       = 5.
  IF sy-subrc <> 0.
    CALL FUNCTION 'SEO_CLASS_GET'
      EXPORTING
        clskey       = name
        version      = seoc_version_active
        state        = '0'
      EXCEPTIONS
        not_existing = 1
        deleted      = 2
        is_interface = 3
        model_only   = 4
        OTHERS       = 5.
    IF sy-subrc <> 0.

      access_mode = seok_access_insert.
    ELSE.

      access_mode = seok_access_modify.
    ENDIF.
  ELSE.


    access_mode = seok_access_modify.

  ENDIF.


  CALL FUNCTION 'SEO_CLIF_ACCESS_PERMISSION'
    EXPORTING
      cifkey                        = name
      clstype                       = seoc_clstype_class
      mode                          = access_mode
      wbiamode                      = seok_ia_default
      authority_check               = seox_true
      master_langu                  = sy-langu
      suppress_langu_check          = seox_true
*     suppress_modification_support = suppress_modification_support
*     genflag                       = genflag
*     devclass_gen                  = devclass
    EXCEPTIONS
      no_access                     = 1
      OTHERS                        = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.


  ENDIF.


ENDMETHOD.

METHOD save.
  DATA lv_cls_name TYPE trobj_name.
  DATA lv_dummy TYPE string.

  CALL FUNCTION 'SEO_CLIF_SAVE_ALL'
    EXPORTING
      cifkey                        = name
*     NO_SECTIONS                   = SEOX_FALSE
*     SECTIONS_ONLY                 = SEOX_FALSE
*     SUPPRESS_CORR                 = SEOX_FALSE
*     SUPPRESS_REFACTORING_ENTRIES  = SEOX_FALSE
      suppress_method_generation    = seox_true " --> Remark vom Thomas: Otherwise the example will fail
*     SUPPRESS_PUBSEC_GENERATION    = SEOX_FALSE
*     SUPPRESS_PROSEC_GENERATION    = SEOX_FALSE
*     SUPPRESS_PRISEC_GENERATION    = SEOX_FALSE
*     SUPPRESS_DOCU_DELETE          = SEOX_FALSE
*     SUPPRESS_MODIFICATION_SUPPORT = SEOX_FALSE
*     DISABLE_MODIFICATION_SUPPORT  = SEOX_FALSE
      generate_if_methods_initial   = seox_true
*     LINE_SIZE                     = 255
*     SUPPRESS_COMMIT               = SEOX_FALSE
*   IMPORTING
*     ERROR_OCCURRED                =
*     PUBLIC_SAVED                  =
*     PRIVATE_SAVED                 =
*     PROTECTED_SAVED               =
*   CHANGING
*     CORRNR                        =
*     DEVCLASS                      =
*     GENFLAG                       =
   EXCEPTIONS
     NOT_EXISTING                  = 1
     NOTHING_TO_DO                 = 2
     ACCESS_ERROR                  = 3
     DB_ERROR                      = 4
     ERROR_IN_CODE_GENERATION      = 5
     OTHERS                        = 6
    .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_dummy.

  ENDIF.

ENDMETHOD.

method UNLOCK.

  CALL FUNCTION 'SEO_CLIF_ACCESS_PERMISSION'
    EXPORTING
      cifkey   = name
      clstype  = seoc_clstype_class
      mode     = seok_access_free
      wbiamode = seok_ia_default
      EXCEPTIONS
      OTHERS   = 1.
endmethod.