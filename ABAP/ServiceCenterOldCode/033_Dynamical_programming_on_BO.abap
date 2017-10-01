*&---------------------------------------------------------------------*
*& Report  ZBO_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbo_test.
TYPE-POOLS: slis.
TYPES:
    BEGIN OF ty_data,
         uid(16) TYPE x,
         node_id TYPE sesf_bo_node_id,
         id(60) TYPE c,
         identity_role_id(256) TYPE c,
    END OF ty_data,
    BEGIN OF ty_id_root,
          BEGIN OF uuid,
             content(16) TYPE x,
           END OF uuid,
          node_id TYPE sesf_bo_node_id,
            BEGIN OF id,
            content(60) TYPE c,
            END OF id,
    END OF ty_id_root,
   BEGIN OF ty_identity_role_id,
        controller  TYPE  prxctrltab,
      identity_role_id  TYPE  apc_v_identity_role_id,
   END OF ty_identity_role_id.


DATA lo_lcp_change_document TYPE REF TO if_esf_lcp .
DATA lo_lcp_facade TYPE REF TO if_esf_lcp_facade .
DATA lo_lcp_identity TYPE REF TO if_esf_lcp .

DATA:  co_bo_identity TYPE string VALUE 'IDENTITY',
       lt_node_id                  TYPE sesf_bo_node_id_tab,
      ls_query_options            TYPE sesf_query_options,
      lrt_id_root                 TYPE REF TO data,
      lrt_id_role_assignment      TYPE REF TO data,
      lrt_id_role_assign_restrict TYPE REF TO data,
      ex                          TYPE REF TO cx_root,
      lt_messages                 TYPE if_esf_types=>ty_messages,
      lt_link                     TYPE sesf_association_link_tab,
      ls_link                     TYPE sesf_association_link,
      ls_data     TYPE ty_data,
      e_t_msg TYPE  rs_t_msg,
      BEGIN OF ls_move,
        BEGIN OF uuid,
             content(16) TYPE x,
         END OF uuid,
      END OF ls_move.

DATA:
        ls_id_root TYPE ty_id_root,
        lt_data TYPE STANDARD TABLE OF ty_data,
        lv_data TYPE ty_identity_role_id,
        fieldcatalog TYPE slis_fieldcat_alv,
        lt_fieldcata TYPE slis_t_fieldcat_alv.


FIELD-SYMBOLS:
      <ft_id_role_assignment>           TYPE INDEX TABLE,
      <ft_it_role> TYPE any,
      <ft_id_root>                      TYPE INDEX TABLE,
      <fs_id_root>                      TYPE any,
      <ft_id_role_assign_restrict>      TYPE INDEX TABLE,
      <fs_range>                        TYPE rsdri_s_range,
      <fs_move>                         TYPE ty_identity_role_id.


START-OF-SELECTION.

*Get Identity data
  ls_query_options-maximum_rows = 200.
  TRY.
      lo_lcp_facade             = cl_esf_lcp_factory=>get_lcp_transaction_handler( ).
      lo_lcp_identity           = lo_lcp_facade->get_lcp( in_bo_name = co_bo_identity ).
      lrt_id_root = lo_lcp_facade->get_bo_node_table_container(
         in_bo_name      = co_bo_identity
         in_bo_node_name = 'ROOT'
         ).
      ASSIGN lrt_id_root->* TO <ft_id_root>.

      lrt_id_role_assignment = lo_lcp_facade->get_bo_node_table_container(
        in_bo_name      = co_bo_identity
        in_bo_node_name = 'ROLE_ASSIGNMENT'
        ).
      ASSIGN lrt_id_role_assignment->* TO <ft_id_role_assignment>.

*    lrt_id_role_assign_restrict = lo_lcp_facade->get_bo_node_table_container(
*      in_bo_name      = co_bo_identity
*      in_bo_node_name = 'ROLE_ASSIGNMENT_RESTRICT'
*      ).
*    ASSIGN lrt_id_role_assign_restrict->* TO <ft_id_role_assign_restrict>.

      CALL METHOD lo_lcp_identity->query
        EXPORTING
          in_bo_node_name    = 'ROOT'
          in_query_name      = 'SELECT_ALL'
*         in_filter_node_ids = in_filter_node_ids
          in_query_options   = ls_query_options
          in_fill_data       = abap_true
        IMPORTING
          out_node_ids       = lt_node_id
          out_data           = <ft_id_root>
          out_messages       = lt_messages.
      CLEAR lt_data.
      LOOP AT <ft_id_root> ASSIGNING <fs_id_root>.
        TRY.
            MOVE-CORRESPONDING <fs_id_root> TO ls_id_root.
*            WRITE: / ls_id_root-id.
            CLEAR: lt_node_id,
                   <ft_id_role_assignment>,
                   ls_data,
                   lt_link.
            CLEAR: lt_node_id.
            MOVE-CORRESPONDING ls_id_root TO ls_data.
            MOVE-CORRESPONDING ls_id_root TO ls_move.
            ls_data-uid = ls_move-uuid-content.
            APPEND ls_id_root-node_id TO lt_node_id.

            CALL METHOD lo_lcp_identity->retrieve_by_association
              EXPORTING
                in_bo_node_name     = 'ROOT'
                in_association_name = 'ROLE_ASSIGNMENT'
                in_node_ids         = lt_node_id
                in_fill_data        = 'X'
              IMPORTING
                out_data            = <ft_id_role_assignment>
                out_links           = lt_link
                out_messages        = lt_messages.
            LOOP AT <ft_id_role_assignment> ASSIGNING <ft_it_role>.
              MOVE-CORRESPONDING <ft_it_role> TO lv_data .
              ls_data-identity_role_id = lv_data-identity_role_id-content.
              INSERT ls_data INTO TABLE lt_data.
            ENDLOOP.

          CATCH cx_esf_core_service cx_esf_message_handler INTO ex.
            CALL FUNCTION 'RS_EXCEPTION_TO_MESSAGE'
              EXPORTING
                i_r_exception = ex
              CHANGING
                c_t_msg       = e_t_msg.
        ENDTRY.
*      APPEND ls_id_root to lt_data.
      ENDLOOP.


      CLEAR  fieldcatalog.
      fieldcatalog-fieldname   = 'UID'.
      fieldcatalog-seltext_m   = 'UUID'.
      fieldcatalog-col_pos     = 2.
      fieldcatalog-outputlen   = 30.
*      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.

      CLEAR fieldcatalog.
      fieldcatalog-fieldname   = 'NODE_ID'.
      fieldcatalog-seltext_m   = 'Root node ID'.
      fieldcatalog-col_pos     = 0.
      fieldcatalog-outputlen   = 30.
*      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.

      CLEAR  fieldcatalog.
      fieldcatalog-fieldname   = 'ID'.
      fieldcatalog-seltext_m   = 'Identity ID'.
      fieldcatalog-col_pos     = 1.
      fieldcatalog-outputlen   = 30.
*      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.

      CLEAR  fieldcatalog.
      fieldcatalog-fieldname   = 'IDENTITY_ROLE_ID'.
      fieldcatalog-seltext_m   = 'IDENTITY_ROLE_ID'.
      fieldcatalog-col_pos     = 3.
      fieldcatalog-outputlen   = 30.
      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.
      CLEAR  fieldcatalog.


      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
*       I_INTERFACE_CHECK                 = ' '
*       I_BYPASSING_BUFFER                = ' '
*       I_BUFFER_ACTIVE                   = ' '
*       I_CALLBACK_PROGRAM                = ' '
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME                  =
*       I_BACKGROUND_ID                   = ' '
*       I_GRID_TITLE                      =
*       I_GRID_SETTINGS                   =
*       IS_LAYOUT                         =
          it_fieldcat                       = lt_fieldcata
*       IT_EXCLUDING                      =
*       IT_SPECIAL_GROUPS                 =
*       IT_SORT                           =
*       IT_FILTER                         =
*       IS_SEL_HIDE                       =
*       I_DEFAULT                         = 'X'
*       I_SAVE                            = ' '
*       IS_VARIANT                        =
*       IT_EVENTS                         =
*       IT_EVENT_EXIT                     =
*       IS_PRINT                          =
*       IS_REPREP_ID                      =
*       I_SCREEN_START_COLUMN             = 0
*       I_SCREEN_START_LINE               = 0
*       I_SCREEN_END_COLUMN               = 0
*       I_SCREEN_END_LINE                 = 0
*       I_HTML_HEIGHT_TOP                 = 0
*       I_HTML_HEIGHT_END                 = 0
*       IT_ALV_GRAPHICS                   =
*       IT_HYPERLINK                      =
*       IT_ADD_FIELDCAT                   =
*       IT_EXCEPT_QINFO                   =
*       IR_SALV_FULLSCREEN_ADAPTER        =
*     IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
        TABLES
          t_outtab                          = lt_data
*     EXCEPTIONS
*       PROGRAM_ERROR                     = 1
*       OTHERS                            = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    CATCH cx_esf_core_service cx_esf_message_handler INTO ex.
      CALL FUNCTION 'RS_EXCEPTION_TO_MESSAGE'
        EXPORTING
          i_r_exception = ex
        CHANGING
          c_t_msg       = e_t_msg.
      RAISE error.
  ENDTRY.

*&---------------------------------------------------------------------*
*& Report  ZBO_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbo_test.
TYPE-POOLS: slis.
TYPES:
    BEGIN OF ty_data,
         uid(16) TYPE x,
         node_id TYPE sesf_bo_node_id,
         id(60) TYPE c,
         identity_role_id(256) TYPE c,
    END OF ty_data,
    BEGIN OF ty_id_root,
          BEGIN OF uuid,
             content(16) TYPE x,
           END OF uuid,
          node_id TYPE sesf_bo_node_id,
            BEGIN OF id,
            content(60) TYPE c,
            END OF id,
    END OF ty_id_root,
   BEGIN OF ty_identity_role_id,
        controller  TYPE  prxctrltab,
      identity_role_id  TYPE  apc_v_identity_role_id,
   END OF ty_identity_role_id.


DATA lo_lcp_change_document TYPE REF TO if_esf_lcp .
DATA lo_lcp_facade TYPE REF TO if_esf_lcp_facade .
DATA lo_lcp_identity TYPE REF TO if_esf_lcp .

DATA:  co_bo_identity TYPE string VALUE 'APDL_OUTBOUND_DELIVERY',
       lt_node_id                  TYPE sesf_bo_node_id_tab,
      ls_query_options            TYPE sesf_query_options,
      lrt_id_root                 TYPE REF TO data,
      lrt_id_role_assignment      TYPE REF TO data,
      lrt_id_role_assign_restrict TYPE REF TO data,
      ex                          TYPE REF TO cx_root,
      lt_messages                 TYPE if_esf_types=>ty_messages,
      lt_link                     TYPE sesf_association_link_tab,
      ls_link                     TYPE sesf_association_link,
      ls_data     TYPE ty_data,
      e_t_msg TYPE  rs_t_msg,
      BEGIN OF ls_move,
        BEGIN OF uuid,
             content(16) TYPE x,
         END OF uuid,
      END OF ls_move.

DATA:
        ls_id_root TYPE ty_id_root,
        lt_data TYPE STANDARD TABLE OF ty_data,
        lv_data TYPE ty_identity_role_id,
        fieldcatalog TYPE slis_fieldcat_alv,
        lt_fieldcata TYPE slis_t_fieldcat_alv.


FIELD-SYMBOLS:
      <ft_id_role_assignment>           TYPE INDEX TABLE,
      <ft_it_role> TYPE any,
      <ft_id_root>                      TYPE INDEX TABLE,
      <fs_id_root>                      TYPE any,
      <ft_id_role_assign_restrict>      TYPE INDEX TABLE,
      <fs_range>                        TYPE rsdri_s_range,
      <fs_move>                         TYPE ty_identity_role_id.


START-OF-SELECTION.

*Get Identity data
  ls_query_options-maximum_rows = 200.
  TRY.
      lo_lcp_facade             = cl_esf_lcp_factory=>get_lcp_transaction_handler( ).
      lo_lcp_identity           = lo_lcp_facade->get_lcp( in_bo_name = co_bo_identity ).
      lrt_id_root = lo_lcp_facade->get_bo_node_table_container(
         in_bo_name      = co_bo_identity
         in_bo_node_name = 'ROOT'
         ).
      ASSIGN lrt_id_root->* TO <ft_id_root>.

      lrt_id_role_assignment = lo_lcp_facade->get_bo_node_table_container(
        in_bo_name      = co_bo_identity
        in_bo_node_name = 'PARTY'
        ).
      ASSIGN lrt_id_role_assignment->* TO <ft_id_role_assignment>.

*    lrt_id_role_assign_restrict = lo_lcp_facade->get_bo_node_table_container(
*      in_bo_name      = co_bo_identity
*      in_bo_node_name = 'ROLE_ASSIGNMENT_RESTRICT'
*      ).
*    ASSIGN lrt_id_role_assign_restrict->* TO <ft_id_role_assign_restrict>.

      CALL METHOD lo_lcp_identity->query
        EXPORTING
          in_bo_node_name    = 'ROOT'
          in_query_name      = 'SELECT_ALL'
*         in_filter_node_ids = in_filter_node_ids
          in_query_options   = ls_query_options
          in_fill_data       = abap_true
        IMPORTING
          out_node_ids       = lt_node_id
          out_data           = <ft_id_root>
          out_messages       = lt_messages.
      CLEAR lt_data.
      LOOP AT <ft_id_root> ASSIGNING <fs_id_root>.
        TRY.
            MOVE-CORRESPONDING <fs_id_root> TO ls_id_root.
*            WRITE: / ls_id_root-id.
            CLEAR: lt_node_id,
                   <ft_id_role_assignment>,
                   ls_data,
                   lt_link.
            CLEAR: lt_node_id.
            MOVE-CORRESPONDING ls_id_root TO ls_data.
            MOVE-CORRESPONDING ls_id_root TO ls_move.
            ls_data-uid = ls_move-uuid-content.
            APPEND ls_id_root-node_id TO lt_node_id.

            CALL METHOD lo_lcp_identity->retrieve_by_association
              EXPORTING
                in_bo_node_name     = 'ROOT'
                in_association_name = 'PARTY'
                in_node_ids         = lt_node_id
                in_fill_data        = 'X'
              IMPORTING
                out_data            = <ft_id_role_assignment>
                out_links           = lt_link
                out_messages        = lt_messages.
            LOOP AT <ft_id_role_assignment> ASSIGNING <ft_it_role>.
              MOVE-CORRESPONDING <ft_it_role> TO lv_data .
              ls_data-identity_role_id = lv_data-identity_role_id-content.
              INSERT ls_data INTO TABLE lt_data.
            ENDLOOP.

          CATCH cx_esf_core_service cx_esf_message_handler INTO ex.
            CALL FUNCTION 'RS_EXCEPTION_TO_MESSAGE'
              EXPORTING
                i_r_exception = ex
              CHANGING
                c_t_msg       = e_t_msg.
        ENDTRY.
*      APPEND ls_id_root to lt_data.
      ENDLOOP.


      CLEAR  fieldcatalog.
      fieldcatalog-fieldname   = 'UID'.
      fieldcatalog-seltext_m   = 'UUID'.
      fieldcatalog-col_pos     = 2.
      fieldcatalog-outputlen   = 30.
*      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.

      CLEAR fieldcatalog.
      fieldcatalog-fieldname   = 'NODE_ID'.
      fieldcatalog-seltext_m   = 'Root node ID'.
      fieldcatalog-col_pos     = 0.
      fieldcatalog-outputlen   = 30.
*      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.

      CLEAR  fieldcatalog.
      fieldcatalog-fieldname   = 'ID'.
      fieldcatalog-seltext_m   = 'Identity ID'.
      fieldcatalog-col_pos     = 1.
      fieldcatalog-outputlen   = 30.
*      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.

      CLEAR  fieldcatalog.
      fieldcatalog-fieldname   = 'IDENTITY_ROLE_ID'.
      fieldcatalog-seltext_m   = 'IDENTITY_ROLE_ID'.
      fieldcatalog-col_pos     = 3.
      fieldcatalog-outputlen   = 30.
      fieldcatalog-emphasize   = 'X'.
      APPEND fieldcatalog TO lt_fieldcata.
      CLEAR  fieldcatalog.


      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
*       I_INTERFACE_CHECK                 = ' '
*       I_BYPASSING_BUFFER                = ' '
*       I_BUFFER_ACTIVE                   = ' '
*       I_CALLBACK_PROGRAM                = ' '
*       I_CALLBACK_PF_STATUS_SET          = ' '
*       I_CALLBACK_USER_COMMAND           = ' '
*       I_CALLBACK_TOP_OF_PAGE            = ' '
*       I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*       I_CALLBACK_HTML_END_OF_LIST       = ' '
*       I_STRUCTURE_NAME                  =
*       I_BACKGROUND_ID                   = ' '
*       I_GRID_TITLE                      =
*       I_GRID_SETTINGS                   =
*       IS_LAYOUT                         =
          it_fieldcat                       = lt_fieldcata
*       IT_EXCLUDING                      =
*       IT_SPECIAL_GROUPS                 =
*       IT_SORT                           =
*       IT_FILTER                         =
*       IS_SEL_HIDE                       =
*       I_DEFAULT                         = 'X'
*       I_SAVE                            = ' '
*       IS_VARIANT                        =
*       IT_EVENTS                         =
*       IT_EVENT_EXIT                     =
*       IS_PRINT                          =
*       IS_REPREP_ID                      =
*       I_SCREEN_START_COLUMN             = 0
*       I_SCREEN_START_LINE               = 0
*       I_SCREEN_END_COLUMN               = 0
*       I_SCREEN_END_LINE                 = 0
*       I_HTML_HEIGHT_TOP                 = 0
*       I_HTML_HEIGHT_END                 = 0
*       IT_ALV_GRAPHICS                   =
*       IT_HYPERLINK                      =
*       IT_ADD_FIELDCAT                   =
*       IT_EXCEPT_QINFO                   =
*       IR_SALV_FULLSCREEN_ADAPTER        =
*     IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
        TABLES
          t_outtab                          = lt_data
*     EXCEPTIONS
*       PROGRAM_ERROR                     = 1
*       OTHERS                            = 2
                .
      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    CATCH cx_esf_core_service cx_esf_message_handler INTO ex.
      CALL FUNCTION 'RS_EXCEPTION_TO_MESSAGE'
        EXPORTING
          i_r_exception = ex
        CHANGING
          c_t_msg       = e_t_msg.
      RAISE error.
  ENDTRY.