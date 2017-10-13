*&---------------------------------------------------------------------*
*& Report ZINT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZINT.

FORM add USING a TYPE int4 b TYPE int4 changing cv_result TYPE int4.
   DATA: n TYPE int4 value 0,
         c TYPE int4 value 0.

   DATA: i TYPE int4 value 1.
   DATA: boolean_a TYPE abap_bool,
         boolean_b TYPE abap_bool,
         _a TYPE int4,
         _b TYPE int4.

   DATA(wrapper_one) = zcl_integer=>value_of( 1 ).
   DATA(wrapper_c) = zcl_integer=>value_of( c ).

   DATA: aa TYPE int4,
         bb type int4.

   aa = a.
   bb = b.
   WHILE i < 1073741824.
      DATA(wrapper_a) = zcl_integer=>value_of( aa ).
      DATA(wrapper_b) = zcl_integer=>value_of( bb ).
      boolean_a = boolc( wrapper_a->and( wrapper_one )->get_raw_value( ) EQ 1 ).
      boolean_b = boolc( wrapper_b->and( wrapper_one )->get_raw_value( ) EQ 1 ).

      _a = COND int4( when boolean_a EQ abap_true then 1 ELSe 0 ).
      _b = COND int4( when boolean_b EQ abap_true then 1 ELSe 0 ).
      wrapper_a = zcl_integer=>value_of( _a ).
      wrapper_b = zcl_integer=>value_of( _b ).
      wrapper_c = zcl_integer=>value_of( c ).
      data(_n) = wrapper_a->xor( wrapper_b )->xor( wrapper_c ).
      data(b_or_c) = wrapper_b->or( wrapper_c ).
      data(b_and_c) = wrapper_b->and( wrapper_c ).
      data(_c) = wrapper_a->and( b_or_c )->or( b_and_c ).
      c = _c->get_raw_value( ).
      data(_n_i0_wrapper) = zcl_integer=>value_of( COND int4( when _n->get_raw_value( ) > 0 then i else 0 ) ).
      data(wrapper_n) = zcl_integer=>value_of( n ).
      n = wrapper_n->or( _n_i0_wrapper )->get_raw_value( ).

      wrapper_a = zcl_integer=>value_of( aa ).
      wrapper_a->shift_right( ).
      aa = wrapper_a->get_raw_value( ).

      wrapper_b = zcl_integer=>value_of( bb ).
      wrapper_b->shift_right( ).
      bb = wrapper_b->get_raw_value( ).

      cv_result = n.

      DATA(wrapper_i) = zcl_integer=>value_of( i ).
      wrapper_i->shift_left( ).

      i = wrapper_i->get_raw_value( ).

   ENDWHILE.

endform.

START-OF-SELECTION.
   data: i type int4.

   PERFORM add using 2023 3041 CHANGING i.

   WRITE: / i.
*function add(a,b){
*
*  for( var i = 1; i != 0; i = i << 1) {
*      var _a = (a & 1 ) == 1;
*      var _b = (b & 1 ) == 1;
*      var _n = (_a ^ _b ) ^ c;
*      c = _a &  (_b | c ) | ( _b & c );
*      n = n | (_n ? i : 0);
*      a = a >> 1;
*      b = b >> 1;
*  }
*  return n;
*}