*&---------------------------------------------------------------------*
*& Report  /SF0A0001/BCE_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/BCE_TEST message-id /bce/msg.


type-pools:
  abap.


constants:
  c_node_dt_cont        type /bce/dte_node_id value '/DOC/C_DT_CONT' ,
  c_node_dt_lvar        type /bce/dte_node_id value 'A1S_CD_TMPL_L___/DOC/C_DT_LVAR' ,
  c_node_dt_schema      type /bce/dte_node_id value 'A1S_CD_TMPL_DT__/DOC/C_DT_SC_2',

  c_schema_hdr          type /bce/dte_schema_id value 'A1S_CD_TMPL_DT',
  c_schema_lvar         type /bce/dte_schema_id value 'A1S_CD_TMPL_L',
  c_schema_group        type /bce/dte_schema_id value 'A1S_CD_TMPL_G',
  c_schema_cont         type /bce/dte_schema_id value '/DOC/C_DT_CONT',


  c_field_binary_data   type /bce/dte_field_name value 'BINARY_DATA',
  c_field_language      type /bce/dte_field_name value 'LANGUAGE',

  c_swc_a1s_bcc         type dlvunit value 'A1S_BCC' ,
  c_swc_a1s_bccg        type dlvunit value 'A1S_BCCG' ,

  c_bcset_type_contentset type /bce/dte_bcset_type value space.



data:
  gs_bcset_range             type /bce/s_dte_bcset_range,
  gt_bcset_range             type /bce/t_dte_bcset_range,
  "gs_node_range              TYPE /bce/s_dte_node_range,
  "gt_node_range              TYPE /bce/t_dte_node_range,
  gs_schema_range            type /bce/s_dte_schema_range,
  gt_schema_range            type /bce/t_dte_schema_range,
  gs_package_range           type /bce/s_dte_package_selection,
  gt_package_range           type /bce/t_dte_package_selection,
  gt_bcset_list              type /bce/t_dte_bcset_list.


data:
  gv_return_code             type sy-subrc,
  go_msg_handler             type ref to /bce/if_dte_msg_hldr.


field-symbols:
  <fs_msg>                   type /bce/s_dte_msg,
  <fs_bcset_list>            type /bce/s_dte_bcset_list.



selection-screen begin of block s01 with frame title text-s01.

select-options:
  bcset     for gs_bcset_range-low,
  schema    for gs_schema_range-low,
  "node      FOR gs_node_range-low,
  devclass  for gs_package_range-low.

selection-screen end of block s01.



initialization.
  clear schema.
  schema-sign   = 'I'.
  schema-option = 'EQ'.
  schema-low    = c_schema_hdr.
  insert schema into table schema.
  schema-low    = c_schema_lvar.
  insert schema into table schema.
  schema-low    = c_schema_group.
  insert schema into table schema.
  schema-low    = c_schema_cont.
  insert schema into table schema.



start-of-selection.

* 0 Init message handler
  go_msg_handler = /bce/cl_dte_msg_hdlr=>get_message_handler( ) .


* 1. Select BC Sets
*    If no BC Set IDs are specified, then ignore the select option.
  clear gt_bcset_range.
  loop at bcset.
    clear gs_bcset_range.
    move-corresponding bcset to gs_bcset_range.
    append gs_bcset_range to gt_bcset_range.
  endloop.

  clear gt_schema_range.
  loop at schema.
    clear gs_schema_range.
    move-corresponding schema to gs_schema_range.
    append gs_schema_range to gt_schema_range.
  endloop.

*  CLEAR gt_node_range.
*  LOOP AT node.
*    CLEAR gs_node_range.
*    MOVE-CORRESPONDING node TO gs_node_range.
*    APPEND gs_node_range TO gt_node_range.
*  ENDLOOP.

  clear gt_package_range.
  loop at devclass.
    clear gs_package_range.
    move-corresponding devclass to gs_package_range.
    append gs_package_range to gt_package_range.
  endloop.

  call function '/BCE/FM_DTE_BC_SET_ENQUIRY'
    exporting
      status_active                  = abap_true
      status_inactive                = abap_false
      is_mandatory                   = abap_true
      not_mandatory                  = abap_true
      include_content_sets           = abap_true
      include_context_sets           = abap_false
      include_meta_sets              = abap_false
      package_seloption              = gt_package_range
*     APPL_COMP_SELOPTION            =
*     SOFTW_COMP_SELOPTION           =
      bcset_range                    = gt_bcset_range
*     ONLY_MY_INACTIVE               =
*     TOP_LEVEL_ONLY                 =
*     LAST_CHANGED_TIMESTAMP         =
*     USED_BCSET_ALL_SELOPTION       =
*     USED_BCSET_DIRECT_SELOPTION    =
*     USEDBY_BCSET_ALL_SELOPTION     =
*     USEDBY_BCSET_DIRECT_SELOPTION  =
      used_schema_seloption          = gt_schema_range
*     USED_SCHEMA_SELOPTION_IMPLICIT =
*     used_node_seloption            = gt_node_range
*     USED_NODE_SELOPTION_IMPLICIT   =
*     SHORT_TEXT_RANGE               =
*     CREATED_BY_RANGE               =
*     CHANGED_BY_RANGE               =
*     CHANGED_ON_RANGE               =
    importing
      bcset_list                     = gt_bcset_list.




* 2. Check BC Sets
  loop at gt_bcset_list assigning <fs_bcset_list>.

    perform check_bcset
      using
        go_msg_handler
        <fs_bcset_list>
      changing
        gv_return_code.

  endloop.

* 3. Show messages
  go_msg_handler->display( ).







*&---------------------------------------------------------------------*
*&      Form  check_bcset
*&---------------------------------------------------------------------*
form check_bcset  using    io_msg_handler type ref to /bce/if_dte_msg_hldr
                           is_bcset_list  type /bce/s_dte_bcset_list
                  changing ev_retcode     type sysubrc.

  data:
    lv_error              type boole_d,
    lv_dummy              type string,
    lv_unknown            type boole_d,
    lv_returncode         type sysubrc,
    lt_messages           type /bce/t_dte_msg,
    lv_value              type string,
    ls_bcset              type /bce/s_dte_bcset.

  field-symbols:
    <s_node_cnt_dt_lvar>  type /bce/s_dte_c_node_content,
    <s_node_cnt_dt_cont>  type /bce/s_dte_c_node_content,
    <s_row_lvar>          type /bce/s_dte_c_row,
    <s_row_cont>          type /bce/s_dte_c_row,
    <s_cell>              type /bce/s_dte_c_cell.


  clear ev_retcode.


* Check BC Set type
  if is_bcset_list-bcset_type <> c_bcset_type_contentset.
    ev_retcode = 4.
    message w000(/bce/msg) with is_bcset_list-bcset_id 'is not a content set.'(m23) into lv_dummy .
    io_msg_handler->add_sy_message( ) .
    exit.
  endif.


* Read the BC Set
  call function '/BCE/FM_DTE_BC_SET_READ'
    exporting
      bcset_id       = is_bcset_list-bcset_id
      status_active  = abap_true
      flag_update    = abap_false
    importing
      content_tab    = ls_bcset
      id_unknown     = lv_unknown
      e_return       = lt_messages
      ev_return_code = lv_returncode.
  if lv_returncode <> 0 or lv_unknown = abap_true.
    message e000(/bce/msg) with is_bcset_list-bcset_id 'cannot be read.'(m21) into lv_dummy .
    io_msg_handler->add_sy_message( ) .
    io_msg_handler->add_messages( it_messages_ext = lt_messages ).
    exit.
  endif.

* Check the content of the template BC Set

***--------following checked is added by LY for Enhanceability check of node A1S_CD_TMPL_DT__/DOC/C_DT_SC_2
  field-symbols:
 <s_node_cnt_dt_sc_2>  type /bce/s_dte_c_node_content .

  loop at ls_bcset-node_content assigning <s_node_cnt_dt_sc_2>.
    if <s_node_cnt_dt_sc_2>-shall_be_enhanceable eq abap_false .
      message e000(/bce/msg) with is_bcset_list-bcset_id 'sets enhanceability to false in node'(e32) <s_node_cnt_dt_sc_2>-node_id into lv_dummy.
      io_msg_handler->add_sy_message( ) .
      lv_error = abap_true .
    endif.
  endloop.
******* end of Enhanceability check






* Get the node content of the variant header
  read table ls_bcset-node_content assigning <s_node_cnt_dt_lvar>
    with key node_id = c_node_dt_lvar.
  if sy-subrc <> 0.
    message e000(/bce/msg) with is_bcset_list-bcset_id 'has no content for /DOC/C_DT_LVAR.'(e31) into lv_dummy .
    io_msg_handler->add_sy_message( ) .
    exit.
  endif.

  if <s_node_cnt_dt_lvar>-t_row is initial.
    message e000(/bce/msg) with is_bcset_list-bcset_id 'has no content for /DOC/C_DT_LVAR.'(e31) into lv_dummy .
    io_msg_handler->add_sy_message( ) .
    exit.
  endif.


* Get the node content of the variant data
  read table ls_bcset-node_content assigning <s_node_cnt_dt_cont>
    with key node_id = c_node_dt_cont.
  if sy-subrc <> 0.
    message e000(/bce/msg) with is_bcset_list-bcset_id 'has no content for /DOC/C_DT_CONT.'(e32) into lv_dummy .
    io_msg_handler->add_sy_message( ) .
    exit.
  endif.

  if <s_node_cnt_dt_cont>-t_row is initial.
    message e000(/bce/msg) with is_bcset_list-bcset_id 'has no content for /DOC/C_DT_CONT.'(e32) into lv_dummy .
    io_msg_handler->add_sy_message( ) .
    exit.
  endif.






* Content checks
* 1. Each Template Variant BC Set shall contain at least one record in the node content of /DOC/C_DT_CONT.
*    Already done in previous step.
* 2. For each row in /DOC/C_DT_CONT there must be a corresponding row in /DOC/C_DT_LVAR.
* 3. For each row in /DOC/C_DT_CONT the field BINARY_DATA must not be empty.
* 4. For each row in /DOC/C_DT_CONT the LANGUAGE must be equal to the master language.
* 5. For each row in /DOC/C_DT_LVAR the LANGUAGE must be equal to the master language.

  lv_error = abap_false.
  loop at <s_node_cnt_dt_cont>-t_row assigning <s_row_cont>.

    "check FK relationship to /DOC/C_DT_LVAR
    read table <s_node_cnt_dt_cont>-t_row assigning <s_row_lvar>
      with key sorting_key = <s_row_cont>-sorting_key.
    if sy-subrc <> 0.
      lv_error = abap_true.
      message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
      message e000(/bce/msg) with 'No header data for variant'(e42) <s_row_cont>-sorting_key into lv_dummy .
      io_msg_handler->add_sy_message( ) .
    endif.

    "check binary data
    read table <s_row_cont>-t_cell assigning <s_cell>
      with key field_name = c_field_binary_data.
    if sy-subrc <> 0.
      "Field is de-selected
      lv_error = abap_true.
      message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
      message e000(/bce/msg) with 'Field BIANRY_DATA is de-selected'(e43) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
    elseif <s_cell>-value is initial.
      "Value is empty
      lv_error = abap_true.
      message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
      message e000(/bce/msg) with 'Field BINARY_DATA has empty data.'(e44) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
    endif.

    "check language
    read table <s_row_cont>-t_cell assigning <s_cell>
      with key field_name = c_field_language.
    if sy-subrc <> 0.
      "Field is de-selected
      lv_error = abap_true.
      message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
      message e000(/bce/msg) with 'Field LANGUAGE is de-selected'(e45) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
    elseif <s_cell>-value is initial.
      "Value is empty
      lv_error = abap_true.
      message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
      message e000(/bce/msg) with 'Field LANGUAGE is initial.'(e46) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
    else.
      lv_value = <s_cell>-value.

      if lv_value <> ls_bcset-orig_language.
        lv_error = abap_true.
        message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
        io_msg_handler->add_sy_message( ) .
        message e000(/bce/msg) with 'Value of field LANGUAGE does not match to master language of BC Set'(e47) into lv_dummy .
        io_msg_handler->add_sy_message( ) .
      endif.

      if <s_row_lvar> is assigned.
        read table <s_row_lvar>-t_cell assigning <s_cell>
          with key field_name = c_field_language.
        if sy-subrc = 0.
          if <s_cell>-value <> lv_value.
            lv_error = abap_true.
            message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_CONT.'(e41) into lv_dummy .
            io_msg_handler->add_sy_message( ) .
            message e000(/bce/msg) with 'Value of field LANGUAGE does not match to language of corresponding Variant Header'(e48) into lv_dummy .
            io_msg_handler->add_sy_message( ) .
          endif.
        endif.
      endif.

    endif.








  endloop.


  loop at <s_node_cnt_dt_lvar>-t_row assigning <s_row_lvar>.

    "check language of variant header
    read table <s_row_lvar>-t_cell assigning <s_cell>
      with key field_name = c_field_language.
    if sy-subrc <> 0.
      lv_error = abap_true.
      message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_LVAR.'(e51) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
      message e000(/bce/msg) with 'Field LANGUAGE is deselected'(e52) into lv_dummy .
      io_msg_handler->add_sy_message( ) .
    else.
      if <s_cell>-value <> ls_bcset-orig_language.
        lv_error = abap_true.
        message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_LVAR.'(e51) into lv_dummy .
        io_msg_handler->add_sy_message( ) .
        message e000(/bce/msg) with 'Value of field LANGUAGE does not match to master language of BC Set'(e57) into lv_dummy .
        io_msg_handler->add_sy_message( ) .
      endif.
    endif.



***--------following checked is added by LY for changeable check for the fields LCHG_DATE_TIME and UPDATED_BY of the node A1S_CD_TMPL_L___/DOC/C_DT_LVAR

    read table <s_row_lvar>-t_cell assigning <s_cell>
      with key field_name = 'LCHG_DATE_TIME'.


    if sy-subrc eq 0 .
      if <s_cell>-shall_be_changeable <>  abap_true .
        lv_error = abap_true.
        message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_LVAR.' into lv_dummy .
        io_msg_handler->add_sy_message( ) .
        message e000(/bce/msg) with 'changeable of field LCHG_DATE_TIME is set to False' into lv_dummy .
        io_msg_handler->add_sy_message( ) .
      endif.
    endif .

    read table <s_row_lvar>-t_cell assigning <s_cell>
      with key field_name = 'UPDATED_BY'.


    if sy-subrc eq 0 .
      if <s_cell>-shall_be_changeable <>  abap_true .
        lv_error = abap_true.
        message e000(/bce/msg) with is_bcset_list-bcset_id 'has invalid content for /DOC/C_DT_LVAR.' into lv_dummy .
        io_msg_handler->add_sy_message( ) .
        message e000(/bce/msg) with 'changeable of field UPDATED_BY is set to False'(e57) into lv_dummy .
        io_msg_handler->add_sy_message( ) .
      endif.
    endif .
******* end of Enhanceability check




  endloop.



  if lv_error = abap_true.
    exit.
  endif.


* Success message
  message i000(/bce/msg) with is_bcset_list-bcset_id 'is consistent.'(m21) into lv_dummy .
  io_msg_handler->add_sy_message( ) .


endform.                    " check_bcset