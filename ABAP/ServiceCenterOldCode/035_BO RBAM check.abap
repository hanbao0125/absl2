*&---------------------------------------------------------------------*
*& Report  ZBO_RBAM_CHECK
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zbo.
PARAMETERS:
p_user   TYPE rbam_user_logon_id                    DEFAULT sy-uname,
p_opna   TYPE rbam_esf_operation_s-pname OBLIGATORY DEFAULT 'Retrieve'         LOWER CASE,
p_opty   TYPE rbam_esf_operation_s-type  OBLIGATORY DEFAULT 'InterfacePattern' LOWER CASE,
p_bo     TYPE rbam_esf_bo_pname          OBLIGATORY DEFAULT 'TASK',
p_node   TYPE rbam_esf_bo_node_pname     OBLIGATORY DEFAULT 'ROOT',
p_nodeid TYPE sesf_bo_node_id.

DATA:
  ls_oper TYPE rbam_esf_operation_s,
  lt_node TYPE sesf_bo_node_id_tab,
  ls_user TYPE rbam_granted_user_s,
  lt_user TYPE rbam_granted_user_t,
  lv_auth TYPE rbam_bool,
  lt_auth TYPE rbam_bool_t,
  lr_cx   TYPE REF TO cx_rbamrt,
  lv_msg  TYPE string.


ls_oper-pname = p_opna.
ls_oper-type  = p_opty.

TRY.
    IF p_user IS INITIAL.
      lt_user =
        cl_rbam_authorization_check=>get_granted_users_bo_node(
          if_bo_name      = p_bo
          if_bo_node_name = p_node
          is_operation    = ls_oper
        ).
      WRITE: / p_bo, p_node, ls_oper-type, ls_oper-pname.
      LOOP AT lt_user INTO ls_user.
        WRITE: / ls_user-user, ls_user-instance_based.
      ENDLOOP.
    ELSEIF p_nodeid IS INITIAL.
      lv_auth =
        cl_rbam_authorization_check=>authorization_check_bo_node(
          if_bo_name      = p_bo
          if_bo_node_name = p_node
          is_operation    = ls_oper
          if_user         = p_user
        ).
      WRITE: / p_user, p_bo, p_node, ls_oper-type, ls_oper-pname, ': (', lv_auth, ')'.
    ELSE.
      APPEND p_nodeid TO lt_node.
      lt_auth =
        cl_rbam_authorization_check=>authorization_check_bo_node_id(
          if_bo_name      = p_bo
          if_bo_node_name = p_node
          is_operation    = ls_oper
          if_user         = p_user
          it_bo_node_ids  = lt_node
        ).
      READ TABLE lt_auth INDEX 1 INTO lv_auth.
      WRITE: / p_user, p_bo, p_node, p_nodeid, ls_oper-type, ls_oper-pname, ': (', lv_auth, ')'.
    ENDIF.

  CATCH cx_rbamrt INTO lr_cx.
    lv_msg = lr_cx->get_text( ).
    WRITE: / p_user, p_bo, p_node, p_nodeid, ls_oper-type, ls_oper-pname, ':', / lv_msg.

ENDTRY.