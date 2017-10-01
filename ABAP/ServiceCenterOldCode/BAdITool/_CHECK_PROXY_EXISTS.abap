METHOD _check_proxy_exists.

  CLEAR ev_exists.

  TRY.
      es_ifr_id = cl_proxy_query=>get_proxy_by_abap_name(
         object	= IV_OBJECT_TYPE
         obj_name = iv_object_name ).
      IF es_ifr_id IS NOT INITIAL.
        ev_exists = abap_true.
      ENDIF.

    CATCH cx_proxy_gen_error .
  ENDTRY.

ENDMETHOD.
