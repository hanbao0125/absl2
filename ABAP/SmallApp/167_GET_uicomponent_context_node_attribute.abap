*&---------------------------------------------------------------------*
*& Report ZGET_UI_CONTEXT_NODE_ATTR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zget_ui_context_node_attr.

PARAMETERS: comp TYPE string OBLIGATORY DEFAULT 'PRD01QR',
            cs   TYPE string OBLIGATORY DEFAULT ''.

DATA(lo_model) = cl_bsp_wd_appl_model=>get_appl_model(
      EXPORTING  iv_bsp_appl = CONV #( comp )
                  iv_model_type      = 'CL_BSP_WD_APPL_MODEL_DDIC' ).
DATA(lt_attr) = lo_model->get_context_node_attr( iv_context_node_class  = CONV #( cs ) ).

BREAK-POINT.