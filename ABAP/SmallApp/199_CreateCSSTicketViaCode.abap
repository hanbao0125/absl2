*&---------------------------------------------------------------------*
*& Include APESICC_CSN_HANDLING
*&---------------------------------------------------------------------*
* Version 1.5

TYPES:
BEGIN OF ts_long_text,
line TYPE c LENGTH 72,
END OF ts_long_text,

BEGIN OF ts_csn_ticket_create,
csinsta TYPE c LENGTH 10,
mnumm TYPE n LENGTH 10,
myear TYPE n LENGTH 4,
service TYPE c LENGTH 3,
servicetyp TYPE c LENGTH 1,
servrel TYPE c LENGTH 10, " system ID
bcsystem TYPE c LENGTH 10, " release
servmandt TYPE c LENGTH 10,
attr11 TYPE c LENGTH 10,
attr28 TYPE c LENGTH 10, " test sequence
attr17 TYPE c LENGTH 10, " client
attr21 TYPE c LENGTH 10, " info field
aktion TYPE c LENGTH 10,
prioa TYPE c LENGTH 1, " priority
sprsl TYPE lang, " AKH component
comp TYPE c LENGTH 20,
ktext TYPE c LENGTH 60, " ticket short text
created_by_uid TYPE c LENGTH 12,
created_by_name TYPE c LENGTH 35,
created_by_sapna TYPE c LENGTH 12,
erftstmp TYPE n LENGTH 14,
erftzr TYPE c LENGTH 6,
changed_by_uid TYPE c LENGTH 12,
changed_by_name TYPE c LENGTH 35,
changed_by_sapna TYPE c LENGTH 12,
aetstmp TYPE n LENGTH 14,
aetzr TYPE c LENGTH 6,
processor_uid TYPE c LENGTH 12, " processor
processor_sapna TYPE c LENGTH 12,
processor_name TYPE c LENGTH 35,
status TYPE c LENGTH 1,
status_txt TYPE c LENGTH 60,
attr104 TYPE c LENGTH 20,
attr18 TYPE c LENGTH 10,
attr19 TYPE c LENGTH 10,
text_log TYPE c LENGTH 1,
tt_bcsx16 TYPE STANDARD TABLE OF ts_long_text WITH DEFAULT KEY,
END OF ts_csn_ticket_create,

BEGIN OF ts_csn_description,
initiator TYPE c LENGTH 1,
myear TYPE n LENGTH 4,
mnumm TYPE n LENGTH 10,
csinsta TYPE c LENGTH 10,
version TYPE c LENGTH 1,
status TYPE c LENGTH 1,
process_time TYPE n LENGTH 5,
voluntary TYPE c LENGTH 1,
detec_activity TYPE c LENGTH 1, "detection activity, E = Unit Test
main_impact TYPE c LENGTH 1,
evaluation TYPE c LENGTH 1,
source_reason TYPE c LENGTH 1,
sequence TYPE c LENGTH 20,
c_project_guid TYPE c LENGTH 32,
severity TYPE c LENGTH 1,
defect_type TYPE c LENGTH 1,
origin TYPE c LENGTH 1,
source_release TYPE c LENGTH 1,
category_05 TYPE c LENGTH 1,
category_06 TYPE c LENGTH 1,
category_07 TYPE c LENGTH 1,
category_08 TYPE c LENGTH 1,
category_09 TYPE c LENGTH 1,
category_10 TYPE c LENGTH 1,
creat_user TYPE c LENGTH 12,
creat_date TYPE dats,
creat_time TYPE tims,
change_user TYPE c LENGTH 12,
change_date TYPE dats,
change_time TYPE tims,
description TYPE c LENGTH 100,
prod_rel TYPE c LENGTH 23,
prog_guid TYPE c LENGTH 32,
END OF ts_csn_description,

BEGIN OF ts_csn_key,
csn_number TYPE c LENGTH 10,
csn_year TYPE n LENGTH 4,
csn_installation TYPE c LENGTH 10,
END OF ts_csn_key,

tv_csn_rcode TYPE sysubrc,
tv_csn_error_text TYPE c LENGTH 255,
tv_csn_reporter TYPE syuname,

tv_csn_filter_name TYPE c LENGTH 30.


TYPES:
BEGIN OF ts_csn_filter,
mandt TYPE mandt,
filtn TYPE n LENGTH 10,
filtg TYPE c LENGTH 10,
filtb TYPE tv_csn_filter_name,
datum TYPE datum,
uzeit TYPE uzeit,
uname TYPE uname,
aedat TYPE sydatum,
aetim TYPE char04,
aenam TYPE uname,
stand TYPE flag,
deflt TYPE flag,
END OF ts_csn_filter,

BEGIN OF ts_csn_ticket,
csinsta TYPE c LENGTH 10,
mnumm TYPE n LENGTH 10,
myear TYPE n LENGTH 4,
prio TYPE c LENGTH 1,
priostxt TYPE text20,
statusstxt TYPE text20,
ktext TYPE c LENGTH 60,
status TYPE c LENGTH 1,
themkext TYPE c LENGTH 20,
eskgrnd TYPE c LENGTH 1,
esktext TYPE text20,
erfdatum TYPE datum,
erfzeit TYPE tims,
firma TYPE c LENGTH 30,
adrnr TYPE c LENGTH 10,
susid TYPE c LENGTH 12,
sapna TYPE c LENGTH 12,
vorna TYPE c LENGTH 30,
nachn TYPE c LENGTH 30,
tel01 TYPE c LENGTH 10,
aedatum TYPE sydatum,
aezeit TYPE tims,
source TYPE c LENGTH 10,
projectid TYPE c LENGTH 32,
mptdatum TYPE sydatum,
mptzeit TYPE tims,
irtdatum TYPE sydatum,
irtzeit TYPE tims,
corsystem TYPE char10,
correlease TYPE char10,
irtstatus TYPE char1,
irtpercent TYPE char10,
kndid TYPE c LENGTH 10,
instid TYPE c LENGTH 10,
END OF ts_csn_ticket,
tt_csn_ticket TYPE STANDARD TABLE OF ts_csn_ticket.

TYPES:
BEGIN OF ts_css_status,
spras TYPE sylangu,
service TYPE char3,
servicetyp TYPE char1,
status TYPE char1,
s_text TYPE text20,
l_text TYPE text60,
stat_order TYPE numc2,
END OF ts_css_status.

DATA:
gt_css_status TYPE ts_css_status OCCURS 0 WITH HEADER LINE,
lv_status_read TYPE abap_bool.

*&---------------------------------------------------------------------*
*& Form csn_ticket_create
*&---------------------------------------------------------------------*
FORM csn_ticket_create USING iv_destination TYPE rfcdest
is_csn_ticket TYPE ts_csn_ticket_create
is_csn_description TYPE ts_csn_description
iv_reporter TYPE tv_csn_reporter
CHANGING ev_rcode TYPE tv_csn_rcode
ev_error_text TYPE tv_csn_error_text
ev_csn_installation TYPE ts_csn_key-csn_installation
ev_csn_number TYPE ts_csn_key-csn_number
ev_csn_year TYPE ts_csn_key-csn_year.

CLEAR:
ev_rcode,
ev_error_text,
ev_csn_installation,
ev_csn_number,
ev_csn_year.

*Detection activity (is_csn_description-detec_activity)
* A Specification review
* B Design review
* C Implementation/Codin
* D Code review / inspec
* E Unit test
* F MIT
* G AT /SIT
* H Quickchecks
* I Production / Assembl
* J Supp. package test
* K Incidental/Demo
* L Productive use
* M Ramp-Up related
* Z None/Workflow

* create CSN via RFC without dialog
CALL FUNCTION 'BCSJ_3_B_RFC_MESSAGE_NEW'
DESTINATION iv_destination
EXPORTING
is_msg = is_csn_ticket
is_dcr = is_csn_description
iv_uname = iv_reporter
IMPORTING
ev_rcode = ev_rcode
ev_rcode_txt = ev_error_text
ev_csinsta = ev_csn_installation
ev_mnumm = ev_csn_number
ev_myear = ev_csn_year.

IF ev_csn_number = '0000000000'.
CLEAR ev_csn_number.
ENDIF.
* TABLES
* APPX_HEADER STRUCTURE BCSN_APPX2 OPTIONAL
* APPX_DATA_BIN STRUCTURE SOLIX OPTIONAL


ENDFORM. "csn_ticket_create


*&---------------------------------------------------------------------*
*& Form csn_ticket_display
*&---------------------------------------------------------------------*
FORM csn_ticket_display
USING iv_destination TYPE rfcdest
iv_csn_installation TYPE ts_csn_key-csn_installation
iv_csn_number TYPE ts_csn_key-csn_number
iv_csn_year TYPE ts_csn_key-csn_year
CHANGING cv_csn_status TYPE string
cv_csn_status_code TYPE char1
cv_csn_priority TYPE string
cv_csn_processor TYPE string
cv_csn_component TYPE string
cv_csn_date TYPE sydatum
cv_csn_time TYPE syuzeit.

DATA:
BEGIN OF ls_status_info,
status TYPE char1,
statustext TYPE char20,
prio TYPE char1,
prio_text TYPE char20,
END OF ls_status_info.
DATA ls_message_hdr LIKE css_bcsm10.

CALL FUNCTION 'S_TWB_I_PROBLEM_MESSAGE_READ'
EXPORTING
* IV_INFO = ' '
iv_destination = iv_destination
iv_language = 'E'
* IV_SERVICE = '3'
* IV_SERVICETYPE = 'B'
iv_instance = iv_csn_installation
iv_problemno = iv_csn_number
iv_problemyear = iv_csn_year
* IV_CHANGE = ' '
IMPORTING
ev_status_info = ls_status_info
ev_message_hdr = ls_message_hdr
EXCEPTIONS
* ONLY_SAPSYSTEM_ALLOWED = 1
* SERVICE_SYSTEM_COMM_FAILURE = 2
* PROBLEM_NOT_FOUND = 3
* PARAMETER_MISSING = 4
* COMMUNICATION_ERROR = 5
OTHERS = 6.
IF sy-subrc = 0.
cv_csn_date = ls_message_hdr-aetstmp(8).
cv_csn_time = ls_message_hdr-aetstmp+8.
cv_csn_status = ls_status_info-statustext.
cv_csn_status_code = ls_status_info-status.
ENDIF.

ENDFORM. " DISPLAY_CSN_TICKET


*&---------------------------------------------------------------------*
*& Form csn_get_tickets_by_filter
*&---------------------------------------------------------------------*
FORM csn_get_tickets_by_filter USING iv_destination TYPE rfcdest
iv_filter_name TYPE tv_csn_filter_name
CHANGING et_csn_ticket TYPE tt_csn_ticket
ev_successful TYPE abap_bool.

DATA:
lt_filterheader TYPE TABLE OF ts_csn_filter,
ls_filterheader LIKE LINE OF lt_filterheader,
lv_rfc_msg TYPE char100.
FIELD-SYMBOLS:
<ls_csn_ticket> LIKE LINE OF et_csn_ticket.

CLEAR:
et_csn_ticket,
ev_successful.

CALL FUNCTION 'DEVDB_MYFILTERS_GET'
DESTINATION iv_destination
* EXPORTING
* IV_SERVICE = '3'
* IV_SERVICETYP = 'B'
TABLES
et_filterheader = lt_filterheader
EXCEPTIONS
communication_failure = 1 MESSAGE lv_rfc_msg
system_failure = 1 MESSAGE lv_rfc_msg
destination_not_found = 2
not_found = 3
OTHERS = 4.

IF sy-subrc = 1
OR sy-subrc = 2.
MESSAGE i000(s04) WITH 'Communication error:' lv_rfc_msg(50) lv_rfc_msg+50(50).
ev_successful = abap_false.
RETURN.
ELSEIF sy-subrc <> 0.
MESSAGE i000(s04) WITH 'Connection to CSN failed'.
ev_successful = abap_false.
RETURN.
ENDIF.

READ TABLE lt_filterheader INTO ls_filterheader
WITH KEY filtb = iv_filter_name.
IF sy-subrc <> 0.
MESSAGE i000(s04) WITH 'Speficy filter' iv_filter_name 'for internal messages in CSN'.
ev_successful = abap_false.
RETURN.
ENDIF.

CALL FUNCTION 'DEVDB_FILTERS_EXECUTE'
DESTINATION iv_destination
EXPORTING
* IV_SERVICE = '3'
* IV_SERVICETYP = 'B'
iv_filtn = ls_filterheader-filtn
* IV_LANGU = 'E'
TABLES
et_mess = et_csn_ticket
* et_errors = et_errors
EXCEPTIONS
communication_failure = 1 MESSAGE lv_rfc_msg
system_failure = 1 MESSAGE lv_rfc_msg
destination_not_found = 2
not_found = 3
OTHERS = 4.

LOOP AT et_csn_ticket ASSIGNING <ls_csn_ticket>.

*### missing: client not know to filter messages by SY-MANDT

*### workaround: status code not filled
** status as returned by FM S_TWB_I_PROBLEM_MESSAGE_READ => use them for this program
* 1 New
* 2 In Process
* 3 Completed
* 5 Author Action
* 6 Partner Action
* 7 Completed for Author
* 8 Confirmed
** status of this call
* 1 Not sent to SAP
* 3 SAP proposed solut.
* 5 Customer action
* 6 Partner action
* 7 Completed for author
* 8 Confirmed
* C Sent to SAP
* M To SAP Partner
* N Partner-Cust. Action
* O Forwarded to VAR
* P To Partner
* S In Processing by SAP
* W In process by cust.
* Z Confirmed autom.
* F Completed

CASE <ls_csn_ticket>-statusstxt.
WHEN 'New'.
<ls_csn_ticket>-status = '1'.
WHEN 'In Process'.
<ls_csn_ticket>-status = '2'.
WHEN 'Completed'.
<ls_csn_ticket>-status = '3'.
WHEN 'Author Action'.
<ls_csn_ticket>-status = '5'.
WHEN 'Completed for Author'.
<ls_csn_ticket>-status = '7'.
WHEN 'Confirmed'.
<ls_csn_ticket>-status = '8'.
WHEN 'Confirmed autom.'.
<ls_csn_ticket>-status = '8'.
WHEN OTHERS.
CLEAR <ls_csn_ticket>-status.
ENDCASE.

ENDLOOP.

ev_successful = abap_true.

ENDFORM. "csn_get_tickets_by_filter

**&---------------------------------------------------------------------*
**& Form CREATE_CSN_TICKET
**&---------------------------------------------------------------------*
*FORM create_csn_ticket_old
* USING iv_check_id TYPE string
* iv_root_cause_type TYPE string
* iv_name TYPE string
* iv_short_text TYPE string
* CHANGING cv_csn_installation TYPE ty_gs_list-csn_installation
* cv_csn_number TYPE ty_gs_list-csn_number
* cv_csn_year TYPE ty_gs_list-csn_year.
*
* DATA ls_bo_header TYPE cl_tool_proxy_bo_metadata=>ty_gs_bo_header.
* DATA lv_frange TYPE css_bcsm10-themkext.
* DATA lv_short_text TYPE text60.
** DATA lv_username LIKE usr01-bname.
* DATA lv_instance LIKE css_bcsm10-csinsta.
* DATA lv_problemno LIKE css_bcsm10-mnumm.
* DATA lv_problemyear LIKE css_bcsm10-myear.
* DATA ls_bcsm10 LIKE css_bcsm10.
*
* CHECK iv_root_cause_type = 'BO'.
*
* CALL METHOD cl_tool_proxy_bo_metadata=>get_bo_metadata
* EXPORTING
* iv_bo_name = iv_name
* IMPORTING
* es_bo_header = ls_bo_header.
*
* lv_frange = ls_bo_header-component_id.
* lv_short_text = iv_short_text.
*
* CALL FUNCTION 'S_TWB_I_PROBLEM_MESSAGE_CREATE'
* EXPORTING
* iv_destination = p_dest
* iv_frange = lv_frange
* iv_username = 'D032794'
* iv_shorttext = lv_short_text
* iv_priority = '2'
* iv_system = sy-sysid
* iv_client = sy-mandt
** IV_SERVICE = '3'
** IV_SERVICETYPE = 'B'
* IMPORTING
* ev_instance = lv_instance
* ev_problemno = lv_problemno
* ev_problemyear = lv_problemyear
* ev_bcsm10 = ls_bcsm10
** TABLES
** TEMPLATE =
* EXCEPTIONS
** ONLY_SAPSYSTEM_ALLOWED = 1
** SERVICE_SYSTEM_COMM_FAILURE = 2
** USER_NOT_FOUND = 3
** RECEIVER_NOT_FOUND = 4
** NO_TEXT_FOR_MESSAGE = 5
** USER_CANCEL = 6
** COMMUNICATION_ERROR = 7
* OTHERS = 8
* .
* IF sy-subrc = 0.
* cv_csn_installation = lv_instance.
* cv_csn_number = lv_problemno.
* cv_csn_year = lv_problemyear.
* ENDIF.
*
*ENDFORM. " CREATE_CSN_TICKET