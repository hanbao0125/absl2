*&---------------------------------------------------------------------*
*& Report  /SF0A0001/DEPLOY_BCSETS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  /SF0A0001/DEPLOY_BCSETS.


PARAMETERS: p_swc TYPE dlvunit OBLIGATORY.

DATA:
      it_tdevc TYPE TABLE OF tdevc WITH HEADER LINE,
      it_tadir TYPE TABLE OF tadir WITH HEADER LINE,
      it_arbo  TYPE TABLE OF /bcse/dte_arbo WITH HEADER LINE,
      it_bcset TYPE TABLE OF /bce/dte_bcset WITH HEADER LINE,
      it_arasc TYPE TABLE OF /bcse/dte_arasc WITH HEADER LINE,
      wa_cccategory TYPE cccategory,
      lv_aw_count TYPE i,
      lv_wsid TYPE /bcse/dte_workspace_id,
      wa_rspar TYPE rsparams,
      it_rspar TYPE TABLE OF rsparams,
      lv_tmp TYPE string,
      lv_msg TYPE string.

FREE it_tdevc.
SELECT *
  FROM tdevc
  INTO TABLE it_tdevc
  WHERE dlvunit = p_swc AND dlvunit LIKE 'SF%'.
IF it_tdevc[] IS INITIAL.
  CONCATENATE 'Can''t find any package in software component' ` ` p_swc '.' INTO lv_msg.
  MESSAGE lv_msg TYPE 'A'.
  RETURN.
ENDIF.
SORT it_tdevc BY devclass.

FREE it_tadir.
SELECT *
  FROM tadir
  INTO TABLE it_tadir
  FOR ALL ENTRIES IN it_tdevc
  WHERE pgmid = 'R3TR' AND ( object = 'SEBO' OR object = 'BCST' ) AND devclass = it_tdevc-devclass.

FREE it_arbo.
FREE it_bcset.
IF it_tadir[] IS NOT INITIAL.
  SELECT *
    FROM /bcse/dte_arbo
    INTO TABLE it_arbo
    FOR ALL ENTRIES IN it_tadir
    WHERE optid = it_tadir-obj_name(40) AND active = 'X'.
  SELECT *
    FROM /bce/dte_bcset
    INTO TABLE it_bcset
    FOR ALL ENTRIES IN it_tadir
    WHERE bcset_id = it_tadir-obj_name(30) AND status = 'X'.
ENDIF.

wa_cccategory = 'C'.
SELECT SINGLE cccategory
  FROM t000
  INTO wa_cccategory
  WHERE mandt = sy-mandt.

IF it_arbo[] IS INITIAL.
  CONCATENATE 'No BO in software component' ` ` p_swc '.' INTO lv_msg.
  IF wa_cccategory = 'C'.
    MESSAGE lv_msg TYPE 'I'.
  ELSE.
    MESSAGE lv_msg TYPE 'A'.
    RETURN.
  ENDIF.
ENDIF.
IF it_bcset[] IS INITIAL.
  CONCATENATE 'No BCSet in software component' ` ` p_swc '.' INTO lv_msg.
  MESSAGE lv_msg TYPE 'A'.
  RETURN.
ENDIF.

CLEAR lv_msg.
IF it_arbo[] IS NOT INITIAL.
  LOOP AT it_arbo.
    FREE it_arasc.
    SELECT *
      FROM /bcse/dte_arasc
      INTO TABLE it_arasc
      WHERE id = it_arbo-optid AND active = 'X' AND deleted = ''.
    IF it_arasc[] IS INITIAL.
      CONCATENATE 'BO' ` ` it_arbo-optid(30) ` ` 'is not assigned to any BCSet.' INTO lv_tmp.
      CONCATENATE lv_msg lv_tmp INTO lv_msg.
      CONTINUE.
    ENDIF.
    LOOP AT it_arasc.
      READ TABLE it_bcset WITH KEY bcset_id = it_arasc-contentid.
      IF sy-subrc <> 0.
        CONCATENATE 'BCSet' ` ` it_arasc-contentid ` ` 'is assigned to BO' ` ` it_arasc-id(30) ', but it is not in SWC' ` ` p_swc ', or don''t existed.' INTO lv_tmp.
        CONCATENATE lv_msg lv_tmp INTO lv_msg.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  LOOP AT it_bcset.
    FREE it_arasc.
    SELECT *
      FROM /bcse/dte_arasc
      INTO TABLE it_arasc
      WHERE contentid = it_bcset-bcset_id AND active = 'X' AND deleted = ''.
    IF it_arasc[] IS INITIAL.
      CONCATENATE 'BCSet' ` ` it_bcset-bcset_id ` ` 'is not assigned to any BO.' INTO lv_tmp.
      CONCATENATE lv_msg lv_tmp INTO lv_msg.
      CONTINUE.
    ENDIF.
    LOOP AT it_arasc.
      READ TABLE it_arbo WITH KEY optid = it_arasc-id.
      IF sy-subrc <> 0.
        CONCATENATE 'BO' ` ` it_arasc-id(30) ` ` 'is assigned to BCSet' ` ` it_arasc-contentid ', but it is not in SWC' ` ` p_swc ', or don''t existed.' INTO lv_tmp.
        CONCATENATE lv_msg lv_tmp INTO lv_msg.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDIF.
IF lv_msg IS NOT INITIAL.
  MESSAGE lv_msg TYPE 'A'.
  RETURN.
ENDIF.

SELECT COUNT(*)
  FROM /bcse/dte_awcmat
  INTO lv_aw_count
  WHERE tenant_status = 3.
IF lv_aw_count <> 1.
  lv_msg = lv_aw_count.
  CONCATENATE lv_msg 'workspaces with tenant, don''t use this program.' INTO lv_msg.
  MESSAGE lv_msg TYPE 'A'.
  RETURN.
ENDIF.

SELECT SINGLE awid
  FROM /bcse/dte_awcmat
  INTO lv_wsid
  WHERE tenant_status = 3.
ASSERT sy-subrc = 0.

FREE it_rspar.
wa_rspar-selname = 'BCSETID'.
wa_rspar-kind = 'S'.
wa_rspar-sign = 'I'.
wa_rspar-option = 'EQ'.
LOOP AT it_bcset.
  wa_rspar-low = it_bcset-bcset_id.
  APPEND wa_rspar TO it_rspar.
ENDLOOP.

SUBMIT zbce_deploy_template WITH wsid = lv_wsid WITH dpl_delt = 'X' WITH simu_dpl = '' WITH SELECTION-TABLE it_rspar AND RETURN.