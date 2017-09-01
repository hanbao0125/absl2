DATA: itab LIKE thenv OCCURS 0 WITH HEADER LINE.

CALL FUNCTION 'TH_ENVIRONMENT'
  TABLES
    environment = itab.

LOOP AT itab.
  WRITE itab-line .
ENDLOOP.