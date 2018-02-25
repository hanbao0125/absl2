*---------------------------------------------------------------------*
*       CLASS lcl_debugger_script DEFINITION

CLASS lcl_debugger_script DEFINITION
  INHERITING FROM  cl_fs_utilities_script.

  PUBLIC SECTION.

    DATA:
      bp_id    TYPE i,
      rex_root TYPE REF TO cx_root,
      TEXT     TYPE STRING.

    METHODS:

       get_scriptname REDEFINITION,
       init           REDEFINITION,
       script         REDEFINITION,

       handle_import,

       handle_if_mainflag,

       handle_sys_params,

       add_pattern_breakpoint
         IMPORTING
             i_mainprog TYPE csequence
             i_include  TYPE csequence
             i_pattern  TYPE csequence.

ENDCLASS.                    "lcl_debugger_script DEFINITION

CLASS lcl_debugger_script IMPLEMENTATION.

  METHOD init.

    DATA:
      l_str_bp    TYPE tpda_bp_persistent.

    super->init( ).

    CLEAR l_str_bp.
    l_str_bp-statementsta   = 'IMPORT'.
    l_str_bp-flagactive     = 'X'.

    TRY.
        me->bp_id = cl_tpda_script_bp_services=>set_bp_statement( l_str_bp-statementsta ).

      CATCH cx_tpda_sys_bp_veridelayed.
      CATCH cx_root INTO me->rex_root.

        me->text = me->rex_root->get_text( ).

    ENDTRY.

    add_pattern_breakpoint(
       i_mainprog  = 'SAPLWB_DATA_BROWSER'
       i_include   = 'LWB_DATA_BROWSERU06'
       i_pattern   =  '*IF*DD02L-MAINFLAG*'  ).

    add_pattern_breakpoint(
       i_mainprog  = 'SAPLWB_DATA_BROWSER'
       i_include   = 'LWB_DATA_BROWSERU06'
       i_pattern   =  '*perform*sys_params_check*'  ).

  ENDMETHOD.                    "init

  method get_scriptname.

    r_name = 'FS_SCRIPT_SE16'.

  ENDMETHOD.


  METHOD handle_import.

    DATA:
      l_ref_elem_descr  TYPE REF TO cl_tpda_script_elemdescr.

    TRY.

        debugger_controller->debug_step(
              cl_tpda_script_debugger_ctrl=>debug_step_into ).

      CATCH cx_tpda_scr_rtctrl_status.
*** ignore
      CATCH cx_root INTO  me->rex_root.

        me->text = me->rex_root->get_text( ).

    ENDTRY.

    TRY.

        l_ref_elem_descr ?= cl_tpda_script_data_descr=>factory( 'DD02L-MAINFLAG' ).

        IF l_ref_elem_descr->value( ) NE 'X'.

          l_ref_elem_descr->change( p_new_value = 'X' ).

        ENDIF.

        l_ref_elem_descr ?= cl_tpda_script_data_descr=>factory( 'GLOBAL_AUTH' ).

        IF l_ref_elem_descr->value( ) NE 'UPDA'.

          l_ref_elem_descr->change( p_new_value = 'UPDA' ).

        ENDIF.

        l_ref_elem_descr ?= cl_tpda_script_data_descr=>factory( 'DD02L-VIEWGRANT' ).

        IF l_ref_elem_descr->value( ) EQ 'R'.

          l_ref_elem_descr->change( p_new_value = '' ).

        ENDIF.

      CATCH cx_root INTO me->rex_root.

        me->text = me->rex_root->get_text( ).

    ENDTRY.

  ENDMETHOD.

  METHOD handle_if_mainflag.

    DATA:
      l_ref_elem_descr  TYPE REF TO cl_tpda_script_elemdescr.

    TRY.

        l_ref_elem_descr ?= cl_tpda_script_data_descr=>factory( 'DD02L-MAINFLAG' ).
        CHECK l_ref_elem_descr IS NOT INITIAL.

        IF l_ref_elem_descr->value( ) NE 'X'.

          l_ref_elem_descr->change( p_new_value = 'X' ).

        ENDIF.

      CATCH cx_root INTO me->rex_root.

        me->text = me->rex_root->get_text( ).

    ENDTRY.

  ENDMETHOD.

  METHOD handle_sys_params.

     DATA:
      l_ref_elem_descr  TYPE REF TO cl_tpda_script_elemdescr.

      TRY.

        debugger_controller->debug_step(
              cl_tpda_script_debugger_ctrl=>debug_step_over ).

      CATCH cx_tpda_scr_rtctrl_status.
*** ignore
      CATCH cx_root INTO  me->rex_root.

        me->text = me->rex_root->get_text( ).

    ENDTRY.

     l_ref_elem_descr ?= cl_tpda_script_data_descr=>factory( 'GLOBAL_AUTH' ).

        IF l_ref_elem_descr->value( ) NE 'UPDA'.

          l_ref_elem_descr->change( p_new_value = 'UPDA' ).

        ENDIF.


  ENDMETHOD.

  METHOD script.

    DATA:
       l_ref_cls       TYPE REF TO if_oo_class_incl_naming,
       l_tab_prog      TYPE TABLE OF sy-repid,
       l_group         TYPE rs38l-area,
       l_tab_bp        TYPE tpda_bp_persistent_it,
       l_str_bp        TYPE tpda_bp_persistent,
       l_str_pos       TYPE tpda_src_info,
       l_code          TYPE c LENGTH 255,
       l_tab_code      LIKE TABLE OF l_code.

    TRY.

        l_tab_bp = cl_tpda_script_bp_services=>get_reached_script_bps( ).
        READ TABLE l_tab_bp INTO l_str_bp INDEX 1.

        IF l_str_bp-statementsta   = 'IMPORT'.

          handle_import( ).
          RETURN.

        ENDIF.

        if l_str_bp-INCLNAMESRC = 'LWB_DATA_BROWSERU06' and (
           l_str_bp-lineSRC ge 30 and l_str_bp-linESRC le 50 ).
          handle_sys_params( ).
          return.
        endif.

        handle_if_mainflag( ).

      CATCH cx_tpda_scr_rtctrl_status.

      CATCH cx_root INTO me->rex_root.

        me->text = me->rex_root->get_text( ).

    ENDTRY.

  ENDMETHOD.                    "script

  METHOD add_pattern_breakpoint.

    DATA:
      l_str_bp    TYPE tpda_scr_bp_srcline,
      l_code      TYPE c LENGTH 120,
      l_tab_code  LIKE TABLE OF l_code,
      l_prog      TYPE programm.

    l_str_bp-progname = i_mainprog.
    l_str_bp-inclname = i_include.
    READ REPORT l_str_bp-inclname INTO l_tab_code.


    LOOP AT l_tab_code INTO l_code.

      TRANSLATE l_code TO UPPER CASE.                     "#EC SYNTCHAR
      CONDENSE l_code.

      IF l_code CP i_pattern.


        l_str_bp-line     = sy-tabix.                       "401.

        TRY.

            cl_tpda_script_bp_services=>set_bp_source( l_str_bp ).

          CATCH cx_tpda_sys_bp_veridelayed.
          CATCH cx_root INTO me->rex_root.

            me->text = me->rex_root->get_text( ).
            BREAK-POINT.

        ENDTRY.

        EXIT.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.                    "lcl_debugger_script IMPLEMENTATION