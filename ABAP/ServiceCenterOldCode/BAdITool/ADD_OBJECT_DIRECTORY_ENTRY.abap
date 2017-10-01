METHOD ADD_OBJECT_DIRECTORY_ENTRY.


  DATA: lv_dummy_string TYPE string,
        lv_object_name TYPE sobj_name,
        lv_namespace TYPE namespace,
        lv_srcsystem type TADIR-srcsystem,

        ls_namespace_property TYPE trnspace.

  lv_object_name = iv_name.
  lv_srcsystem = sy-sysid.

*  Get namespace and check whether namespace exists
  IF iv_name CP '/*/*'.

    SPLIT lv_object_name AT '/' INTO lv_dummy_string lv_namespace lv_dummy_string.
    lv_namespace = '/' && lv_namespace && '/'.

    CALL FUNCTION 'TR_READ_NAMESPACE'
      EXPORTING
        iv_namespace           = lv_namespace
      IMPORTING
        es_trnspace            = ls_namespace_property
      EXCEPTIONS
        namespace_not_existing = 1
        OTHERS                 = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /SFT/cx_ddic_adapter
        EXPORTING
          textid      = /SFT/cx_ddic_adapter=>namespace_is_inconsistent
*         previous    =
*         object_type =
*         object_name =
          namespace   = lv_namespace.


    ENDIF.


  ENDIF.

* Create Object Directory Entry
  CALL FUNCTION 'TR_TADIR_INTERFACE'
    EXPORTING
*   WI_DELETE_TADIR_ENTRY                = ' '
*   WI_REMOVE_REPAIR_FLAG                = ' '
*   WI_SET_REPAIR_FLAG                   = ' '
      wi_test_modus                        = abap_false
      wi_tadir_pgmid                       = gc_programid   "e.g. 'R3TR'
      wi_tadir_object                      = iv_type        "e.g. 'TABL'
      wi_tadir_obj_name                    = lv_object_name
*     wi_tadir_korrnum                      =
     WI_TADIR_SRCSYSTEM                   = lv_srcsystem
     wi_tadir_author                      = sy-uname
     wi_tadir_devclass                    = iv_package
     wi_tadir_masterlang                  = sy-langu
*   WI_TADIR_CPROJECT                    = ' '
*   WI_TADIR_VERSID                      = ' '
*   WI_REMOVE_GENFLAG                    = ' '
     wi_set_genflag                       =  ls_namespace_property-gen_only
*   WI_READ_ONLY                         = ' '
*   IV_SET_EDTFLAG                       = ' '
*   IV_TRANSL_TECH_TEXT                  = ' '
*   IV_DELFLAG                           = ' '
*   IV_NO_PAK_CHECK                      = ' '
*   IV_OBJ_STABILITY                     = ' '
* IMPORTING
*   NEW_GTADIR_ENTRY                     =
*   NEW_TADIR_ENTRY                      =
   EXCEPTIONS
     tadir_entry_not_existing             = 1
     tadir_entry_ill_type                 = 2
     no_systemname                        = 3
     no_systemtype                        = 4
     original_system_conflict             = 5
     object_reserved_for_devclass         = 6
     object_exists_global                 = 7
     object_exists_local                  = 8
     object_is_distributed                = 9
     obj_specification_not_unique         = 10
     no_authorization_to_delete           = 11
     devclass_not_existing                = 12
     simultanious_set_remove_repair       = 13
     order_missing                        = 14
     no_modification_of_head_syst         = 15
     pgmid_object_not_allowed             = 16
     masterlanguage_not_specified         = 17
     devclass_not_specified               = 18
     specify_owner_unique                 = 19
     loc_priv_objs_no_repair              = 20
     gtadir_not_reached                   = 21
     object_locked_for_order              = 22
     change_of_class_not_allowed          = 23
     no_change_from_sap_to_tmp            = 24
     OTHERS                               = 25
            .
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE /SFT/cx_ddic_adapter
      EXPORTING
        textid      = /SFT/cx_ddic_adapter=>object_directory_update_failed
*       previous    =
        object_type = iv_type
        object_name = lv_object_name(30).

  ENDIF.

ENDMETHOD.
