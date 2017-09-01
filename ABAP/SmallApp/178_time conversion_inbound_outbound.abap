CALL METHOD cl_gdt_conversion=>date_time_outbound
        EXPORTING
          im_value_short = lv_cfc_ts
        IMPORTING
          ex_value       = lv_cfc_UTC.

input:20081203055940
output:2008-12-03T05:59:40Z