METHOD /sft/if_esr_adapter~get_abap_data_type_by_esr.

  DATA:
        lt_esr_keys TYPE cl_proxy_public_utils=>t_esr_keys,
        lt_proxy_keys TYPE cl_proxy_public_utils=>t_proxy_keys,

        ls_esr_key TYPE cl_proxy_public_utils=>t_esr_key.

  FIELD-SYMBOLS:
        <ls_proxy_key> TYPE cl_proxy_public_utils=>t_proxy_key.

  ls_esr_key-type = 'ifmtypedef'.
  ls_esr_key-name = iv_name.
  ls_esr_key-namespace = iv_namespace.
  APPEND ls_esr_key TO lt_esr_keys.
  cl_proxy_public_utils=>get_proxy_key_by_esr_key(
    EXPORTING
      esr_keys    = lt_esr_keys
*      gen_appl    =
*      get_package = SPACE
*      get_corrnum = SPACE
    IMPORTING
      proxy_keys  = lt_proxy_keys
         ).
  IF lt_proxy_keys IS INITIAL.
    RAISE EXCEPTION TYPE /sft/cx_esr_adapter
      EXPORTING
        textid                  = /sft/cx_esr_adapter=>abap_data_type_not_found
        esr_data_type           = iv_name
        esr_data_type_namespace = iv_namespace.

  ENDIF.
  READ TABLE lt_proxy_keys INDEX 1 ASSIGNING <ls_proxy_key>.
  rv_proxy_name = <ls_proxy_key>-abap_key-obj_name.

ENDMETHOD.
