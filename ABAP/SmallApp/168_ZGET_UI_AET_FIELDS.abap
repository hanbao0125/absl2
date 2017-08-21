*&---------------------------------------------------------------------*
*& Report ZGET_UI_CONTEXT_NODE_ATTR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zget_ui_aet_fields.

PARAMETERS: comp TYPE string OBLIGATORY DEFAULT 'BT116H_SRVO',
            cs   TYPE string OBLIGATORY DEFAULT 'CL_BT116H_S_DETAILS_CN00'.

DATA(lo_model) = cl_bsp_wd_appl_model=>get_appl_model(
      EXPORTING  iv_bsp_appl = CONV #( comp )
                  iv_model_type      = 'CL_BSP_WD_APPL_MODEL_DDIC' ).

data(lt_result) = cl_axt_uif_access=>get_ext_attributes(
 iv_bol_object = 'BTAdminH'
 iv_is_table = abap_false ).

BREAK-POINT.
*DATA(lt_attr) = lo_model->get_context_node_attr( iv_context_node_class  = CONV #( cs )
*  iv_mark_ext_attributes = 'X' ).
*
*LOOP AT lt_attr ASSIGNING FIELD-SYMBOL(<attr>).
*  WRITE:/ <attr>.
*ENDLOOP.