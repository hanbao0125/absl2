* Created by Wang, Jerry, last modified on Aug 13, 2012
DATA:
    unit_factory       TYPE REF TO cl_aunit_factory,
    unit_task          TYPE REF TO if_aunit_task.
  CREATE OBJECT unit_factory.
  unit_task = unit_factory->create_task( ).
  unit_task->add_program( 'ZTEST_BSATXT' ).
  unit_task->run( ).