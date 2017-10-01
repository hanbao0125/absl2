class name: SF0A0001PICTURE_UTILITY
backup date: 2009-04-02

class /SF0A0001/PICTURE_UTILITY definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/PICTURE_UTILITY
*"* do not include other source files here!!!

  class-data LV_TEST type I .

  class-methods DISPLAY .
  class-methods INIT
    importing
      !IN_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER
      !IN_PIC type ref to CL_GUI_PICTURE .
  class-methods UPLOAD
    importing
      !IN_PIC_LOCAL_PATH type STRING
      !IN_FILE_PATH type STRING .

private section.
*"* private components of class /SF0A0001/PICTURE_UTILITY
*"* do not include other source files here!!!

  class-data LR_CONTAINER type ref to CL_GUI_CUSTOM_CONTAINER .
  class-data LR_PIC type ref to CL_GUI_PICTURE .
  class-data LV_PATH type STRING value '/SAP/BC/FP/GRAPHICS/FPSAMPLES/EUMEL.BMP'. "#EC NOTEXT .

  class-methods RANDOM .

method DISPLAY.
  TYPES pic_line(1022) TYPE x.
  DATA: l_alignment TYPE i,
        pic_wa TYPE xstring,
        pic_tab TYPE TABLE OF pic_line,
        length TYPE i,
        mime_api TYPE REF TO if_mr_api,
        url(256) TYPE c.

  RANDOM( ).

  l_alignment = cl_gui_control=>align_at_left   +
                cl_gui_control=>align_at_right  +
                cl_gui_control=>align_at_top    +
                cl_gui_control=>align_at_bottom.

  CALL METHOD lr_pic->set_alignment
    EXPORTING
      alignment = l_alignment.

  CALL METHOD lr_pic->set_3d_border
    EXPORTING
      border = 1.

   mime_api = cl_mime_repository_api=>get_api( ).

   mime_api->get( EXPORTING i_url = /SF0A0001/PICTURE_UTILITY=>lv_path
                   IMPORTING e_content = pic_wa
                   EXCEPTIONS OTHERS = 4 ).

   IF sy-subrc = 4.
       MESSAGE e005(/SF0A0001/BADI_INSPE) WITH lv_path.
   ENDIF.

   CLEAR pic_tab.
   length = XSTRLEN( pic_wa ).
   WHILE length >= 1022.
      APPEND pic_wa(1022) TO pic_tab.
      SHIFT pic_wa BY 1022 PLACES LEFT IN BYTE MODE.
      length = XSTRLEN( pic_wa ).
   ENDWHILE.
   IF length > 0.
      APPEND pic_wa TO pic_tab.
   ENDIF.

   CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type    = 'IMAGE'
        subtype = 'GIF'
      TABLES
        data    = pic_tab
      CHANGING
        url     = url.

   CALL METHOD lr_pic->SET_DISPLAY_MODE
      EXPORTING
        DISPLAY_MODE = cl_gui_picture=>DISPLAY_MODE_STRETCH.

   CALL METHOD lr_pic->load_picture_from_url
      EXPORTING
        url    = url
      EXCEPTIONS
        OTHERS = 4.

   IF sy-subrc = 4.
      MESSAGE e006(/SF0A0001/BADI_INSPE) WITH url.
   ENDIF.
endmethod.

method INIT.

   lr_container = in_container.
   lr_pic = in_pic.

   CREATE OBJECT: lr_container EXPORTING container_name = 'PICTURE1',
                  lr_pic EXPORTING parent = lr_container.


endmethod.

method UPLOAD.

 CONSTANTS: c_linelen TYPE i VALUE 255.
 DATA: wa_data(c_linelen) TYPE x,
       it_data LIKE TABLE OF wa_data,
       lv_xstring TYPE xstring,
       lv_length TYPE i,
       mime_api TYPE REF TO if_mr_api.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = in_pic_local_path
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_length
    CHANGING
      data_tab                = it_data
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc <> 0.
    MESSAGE e007(/SF0A0001/BADI_INSPE) WITH sy-subrc.
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_length
    IMPORTING
      buffer       = lv_xstring
    TABLES
      binary_tab   = it_data
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE e008(/SF0A0001/BADI_INSPE) WITH sy-subrc.
  ENDIF.

  mime_api = cl_mime_repository_api=>get_api( ).

  CALL METHOD mime_api->PUT
    EXPORTING
      I_URL     = in_file_path
      I_CONTENT = lv_xstring.

endmethod.

method RANDOM.
  DATA: lt_table TYPE TABLE OF /SF0A0001/PIC,
        ls_entry TYPE /SF0A0001/PIC,
        lv_num TYPE i,
        gv_seed TYPE i,
        lr_rnd_per TYPE REF TO cl_abap_random_int,
        lv_index TYPE i,
        lv_guid TYPE SYSUUID_X16,
        ls_log TYPE /SF0A0001/PICLOG.

  CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_x16
        RECEIVING
          uuid = lv_guid.

  ls_log-GUID = lv_guid.
  ls_log-USERNAME = sy-uname.
  ls_log-RUNDATE = sy-datum.
  ls_log-RUNTIME = sy-timlo.

  SELECT * FROM /SF0A0001/PIC INTO TABLE lt_table.
  lv_num = lines( lt_table ).
  IF  lv_num <= 1.
     ls_log-selection = 0.
     INSERT INTO /SF0A0001/PICLOG VALUES ls_log.
     COMMIT WORK AND WAIT.
     RETURN.
  ENDIF.

  gv_seed = cl_abap_random=>seed( ).

  lr_rnd_per = cl_abap_random_int=>create( seed = gv_seed min = 1 max = lv_num ).

  lv_index = lr_rnd_per->get_next( ).

  READ TABLE lt_table INTO ls_entry INDEX lv_index.
  CHECK sy-subrc = 0.
  lv_path = ls_entry-path.
  ls_log-selection = lv_index.
  INSERT INTO /SF0A0001/PICLOG VALUES ls_log.
  COMMIT WORK AND WAIT.


endmethod.