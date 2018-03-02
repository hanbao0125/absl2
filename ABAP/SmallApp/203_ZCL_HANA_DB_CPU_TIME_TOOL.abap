class ZCL_HANA_DB_CPU_TIME_TOOL definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
  class-methods GET_CURRENT_TIME
    returning
      value(RV_TIME) type DECFLOAT34 .
protected section.
private section.

  class-data SO_CONNECTION type ref to CL_SQL_CONNECTION .
  class-data SV_STATEMENT type STRING .
  TYPES: BEGIN OF typ_s_hostcpu,
           host TYPE char100,
           cpu  TYPE decfloat34,
         END OF typ_s_hostcpu,
         typ_t_hostcpu TYPE STANDARD TABLE OF typ_s_hostcpu WITH DEFAULT KEY.

ENDCLASS.



CLASS ZCL_HANA_DB_CPU_TIME_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HANA_DB_CPU_TIME_TOOL=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CLASS_CONSTRUCTOR.
    so_connection = cl_sql_connection=>get_connection(  ).
    sv_statement = 'select host, sum(process_cpu_time) from m_service_statistics where service_name = ''indexserver'' and detail <> ''standby'' group by host order by host'.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HANA_DB_CPU_TIME_TOOL=>GET_CURRENT_TIME
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_TIME                        TYPE        DECFLOAT34
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_CURRENT_TIME.
    data: lt_hostcpu       TYPE typ_t_hostcpu,
          lr_data TYPE REF to data.
    TRY.
      DATA(r_stmt) = so_connection->create_statement( ).
      DATA(r_res) = r_stmt->execute_query( sv_statement ).
      GET REFERENCE OF lt_hostcpu[] INTO lr_data.
      r_res->set_param_table( lr_data ).
      r_res->next_package( ).
      r_res->close( ).
      READ TABLE lt_hostcpu ASSIGNING FIELD-SYMBOL(<cpu>) index 1.
      check sy-subrc = 0.
      rv_time = <cpu>-cpu.
    CATCH cx_root INTO DATA(cx_root).
      WRITE:/ cx_root->get_text( ).
      RETURN.
  ENDTRY.
  endmethod.
ENDCLASS.