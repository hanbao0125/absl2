class name : SF0A0001PO_CHANGE
backup date: 2009-04-02

class /SF0A0001/PO_CHANGE definition
  public
  final
  create public .

public section.
*"* public components of class /SF0A0001/PO_CHANGE
*"* do not include other source files here!!!

  interfaces /DOC/IF_OM_BADI_GET_FORMDATA .
  interfaces IF_BADI_INTERFACE .

  class-data LV_TEST type I .

private section.
*"* private components of class /SF0A0001/PO_CHANGE
*"* do not include other source files here!!!

  data MV_SENDER_EMAIL type STRING .
  data MV_RECEIVER_MAIL type STRING .
  data MV_PO_ID type CHAR35 .
  data MV_ROOT_NODE_ID type SESF_BO_NODE_ID .
  interface /SRMAP/IF_FNDX_PD_TEMPLATE load .
  data MT_ROOT_PARTY_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_PARTY .
  data MT_ROOT_NODE_ID type SESF_BO_NODE_ID_TAB .
  data MT_ROOT_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ROOT .
  data MT_ROOT_LTX_NODES type /SRMAP/CL_FND_PAF_HELPER=>TT_DO_LTX_NODES .
  data MT_ROOT_LOCATION_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_LOCATION .
  data MT_ROOT_DELIV_TERMS_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_DELIVERY_TERMS .
  data MT_ROOT_CASHDISCOUNT_NODES type IF_FOPXF_CDT=>TT_ROOT .
  data MT_ROOT_BTD_REFERENCE type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_BTD_REFERENCE .
  data MT_ROOT_ATT_NODES type /SRMAP/CL_FND_PAF_HELPER=>TT_DO_ATT_NODES .
  data MT_PRODUCT_STANDARD_IDS type /SRMAP/CL_FND_PAF_HELPER=>TT_MD_PRODUCT_IDS .
  data MT_PCO_SO_REFERENCE_NODES type /SRMAP/T_FND_LINK_REF_BO_NODE .
  data MT_PARTY_IDS type /SRMAP/CL_FND_PAF_HELPER=>TT_MD_PARTY_IDS .
  data MT_PARTY_CONTACT_PARTY type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_PARTY_CONTACT_PARTY .
  data MT_LOCATION_STANDARD_IDS type /SRMAP/CL_FND_PAF_HELPER=>TT_MD_LOCATION_IDS .
  data MT_ITEM_SCHEDULE_LINES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM_SCHEDULE_LINE .
  data MT_ITEM_PRODUCT_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM_PRODUCT .
  data MT_ITEM_PARTY_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM_PARTY .
  data MT_ITEM_PARTY_IDS type /SRMAP/CL_FND_PAF_HELPER=>TT_MD_PARTY_IDS .
  data MT_ITEM_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM .
  data MT_ITEM_LTX_NODES type /SRMAP/CL_FND_PAF_HELPER=>TT_DO_LTX_NODES .
  data MT_ITEM_LOC_STANDARD_ID type /SRMAP/CL_FND_PAF_HELPER=>TT_MD_LOCATION_IDS .
  data MT_ITEM_LOCATION_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM_LOCATION .
  data MT_ITEM_ID type SESF_BO_NODE_ID_TAB .
  data MT_ITEM_DELIV_TERMS_NODES type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM_DELIVERY_TERMS .
  data MT_ITEM_BTD_REFERENCE type /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ITEM_BTD_REFERENCE .
  data MT_ITEM_ATT_NODES type /SRMAP/CL_FND_PAF_HELPER=>TT_DO_ATT_NODES .
  data MT_ADDR_NODES type /SRMAP/CL_FND_PAF_HELPER=>TT_DO_ADDR_NODES .
  data MR_PO_MSG type ref to /SRMAP/LPURX_F_PO_REQUEST .
  data MR_LCP_FACADE type ref to IF_ESF_LCP_FACADE .
  data MR_LCP type ref to IF_ESF_LCP .
  data LV_ERROR_MESSAGE type STRING .
  data MV_PARTY_LCP type ref to IF_ESF_LCP .

  methods DO_POST .
  methods GENERATE_PDF
    importing
      !IN_MESSAGE_TYPE type ANY
    exporting
      !OUT_PDF type XSTRING .
  methods GET_DATA .
  methods GET_RECEIVER_EMAIL .
  methods GET_SENDER_MAIL .
  methods INIT
    importing
      !IN_BO_INSTANCE_TAB type /DOC/OM_TT_BO_INS .
  methods LOG .
  methods MAP_BO2MSG .
  methods SEND_MAIL
    importing
      !IM_PDF_DATA type XSTRING .

method /DOC/IF_OM_BADI_GET_FORMDATA~GET_FORM_DATA.
  DATA:
        out_lcp TYPE REF TO if_esf_lcp,
        lt_root_node TYPE sesf_bo_node_id_tab,
        lt_data TYPE /SRMAP/IF_FNDX_PD_TEMPLATE=>TT_ROOT,
        ls_data TYPE /SRMAP/IF_FNDX_PD_TEMPLATE=>TY_ROOT,
        lv_pdf TYPE xstring.

  FIELD-SYMBOLS: <ls_item_node>          TYPE /srmap/if_fndx_pd_template=>ty_item,
                 <fs_root_party>         TYPE /srmap/if_fndx_pd_template=>ty_party,
                 <fs_root_location_node> TYPE /srmap/if_fndx_pd_template=>ty_location,
                 <fs_item_party_node>    TYPE /srmap/if_fndx_pd_template=>ty_item_party,
                 <fs_item_location_node> TYPE /srmap/if_fndx_pd_template=>ty_item_location,
                 <ls_root_node>          TYPE /srmap/if_fndx_pd_template=>ty_root.

  CHECK iv_form_message_type IS NOT INITIAL.

  mr_po_msg ?= iv_form_message_type.

  CALL METHOD me->init
      EXPORTING
         in_bo_instance_tab = it_bo_instance_tab.

  CALL METHOD me->get_data.

  CALL METHOD me->map_bo2msg.

  CALL METHOD me->do_post.

  iv_form_message_type = mr_po_msg.

  CALL METHOD me->generate_pdf
     EXPORTING
       in_message_type = iv_form_message_type
     IMPORTING
       out_pdf = lv_pdf.

  CALL METHOD me->send_mail
     EXPORTING
       im_pdf_data = lv_pdf.

  CALL METHOD me->log( ).
  COMMIT WORK AND WAIT.
endmethod.

method DO_POST.
  DATA: ls_root_node LIKE LINE OF mt_root_nodes,
          lr_item TYPE REF TO /SRMAP/LPURX_F_PO_ITEM,
          lv_item_id TYPE APC_V_BTD_ITEM_ID,
          lt_item_node LIKE LINE OF mt_item_nodes.
    READ TABLE mt_root_nodes INTO ls_root_node INDEX 1.
    CHECK sy-subrc = 0.
    mr_po_msg->form_purchase_order_request-PURCHASE_ORDER-name-content = ls_root_node-STATUS-DELIVERY_PROCESSING_STCD.
    IF ls_root_node-STATUS-DELIVERY_PROCESSING_STCD = 1 OR ls_root_node-STATUS-DELIVERY_PROCESSING_STCD = 2.
       LOOP AT mr_po_msg->form_purchase_order_request-PURCHASE_ORDER-ITEM REFERENCE INTO lr_item.
          lv_item_id = lr_item->ID.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_item_id
            IMPORTING
              output = lv_item_id.
          READ TABLE mt_item_nodes INTO lt_item_node WITH KEY ID = lv_item_id.
          CHECK sy-subrc = 0.
          lr_item->ACTION_CODE_NAME-content = lt_item_node-status-DELIVERY_PROCESSING_STCD.
       ENDLOOP.
    ENDIF.

endmethod.

method GENERATE_PDF.
  DATA: lv_xml TYPE xstring,
        ls_parameters TYPE omst_output_requests,
        lv_preview_data TYPE xstring,
        lt_errmsg TYPE bapiret2_t.
  FIELD-SYMBOLS: <ls_data> TYPE any.

  ASSIGN in_message_type->* TO <ls_data>.
  CHECK <ls_data> IS ASSIGNED.
      TRY.
          CALL METHOD cl_proxy_xml_transform=>abap_to_xml_xstring
            EXPORTING
              abap_data  = <ls_data>
              ddic_type  = '/SRMAP/LPURX_F_PO_REQUEST'
            RECEIVING
              xml        = lv_xml.
        CATCH cx_proxy_fault.

      ENDTRY.

    ls_parameters-form_tp_code = 'ZPOFO'.
    ls_parameters-form_template_country_code = 'US'.
    ls_parameters-form_template_language_code = 'E'.
    ls_parameters-output_data = lv_xml.

    CALL FUNCTION '/DOC/OM_PREVIEW_OUTPUT'
      EXPORTING
        is_outputrequest_set        = ls_parameters
     IMPORTING
       EV_RP_PDF_DOCUMENT          = lv_preview_data
      TABLES
        et_errmsg                   = lt_errmsg
     EXCEPTIONS
       ERR_IN_OUTPUT_SERVICE       = 1
       OTHERS                      = 2.
    CHECK sy-subrc = 0.
    out_pdf = lv_preview_data.
endmethod.

method GET_DATA.

   DATA:  ls_loc_nodes              TYPE /srmap/if_fndx_pd_template=>ty_location,
          lt_node_ids               TYPE sesf_bo_node_id_tab,
          lt_messages               TYPE if_esf_types=>ty_messages,
          lt_party_contact_party_id TYPE sesf_bo_node_id_tab,
          ls_item_loc_nodes         TYPE /srmap/if_fndx_pd_template=>ty_item_location,
          lt_item_uuids             TYPE /srmap/t_fnd_guid_sorted,
          ls_item_uuid              TYPE /srmap/s_fnd_guid_tab,
          lr_pop_helper             TYPE REF TO /srmap/cl_pop_helper,
          lv_node_id                TYPE sesf_bo_node_id,
          lx_error                  TYPE REF TO cx_esf_core_service.

   FIELD-SYMBOLS: <ls_item_node>          TYPE /srmap/if_fndx_pd_template=>ty_item,
                 <fs_root_party>         TYPE /srmap/if_fndx_pd_template=>ty_party,
                 <fs_root_location_node> TYPE /srmap/if_fndx_pd_template=>ty_location,
                 <fs_item_party_node>    TYPE /srmap/if_fndx_pd_template=>ty_item_party,
                 <fs_item_location_node> TYPE /srmap/if_fndx_pd_template=>ty_item_location.


   TRY.
   CALL METHOD mr_lcp->retrieve
      EXPORTING
          in_bo_node_name = /srmap/if_fndx_pd_template=>co_bo_node-root
          in_node_ids     = mt_root_node_id
      IMPORTING
          out_data        = mt_root_nodes.

   CALL METHOD mr_lcp->retrieve
      EXPORTING
          in_bo_node_name = /srmap/if_fndx_pd_template=>co_bo_node-item
          in_node_ids     = mt_item_id
      IMPORTING
          out_data        = mt_item_nodes.

   CALL METHOD mr_lcp->retrieve_by_association
      EXPORTING
          in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-root
          in_association_name = /srmap/if_fndx_pd_template=>co_assoc-root-location
          in_node_ids         = mt_root_node_id
          in_fill_data        = abap_true
      IMPORTING
          out_data            = mt_root_location_nodes.

    LOOP AT mt_root_location_nodes INTO ls_loc_nodes.
       lv_node_id = ls_loc_nodes-node_id.
       APPEND lv_node_id TO lt_node_ids.
       CLEAR lv_node_id.
    ENDLOOP.

    CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_md_location_ids
      EXPORTING
          it_location_node_ids   = lt_node_ids
          iv_location_node_name  = /srmap/if_fndx_pd_template=>co_bo_node-location
          iv_bo_association_name = /srmap/if_fndx_pd_template=>co_assoc-location-loc
          ir_lcp_facade          = mr_lcp_facade
          ir_lcp                 = mr_lcp
      IMPORTING
          et_md_location_ids     = mt_location_standard_ids
          et_messages            = lt_messages.

    CALL METHOD mr_lcp->retrieve_by_association
       EXPORTING
          in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-root
          in_association_name = /srmap/if_fndx_pd_template=>co_assoc-root-delivery_terms
          in_node_ids         = mt_root_node_id
          in_fill_data        = abap_true
       IMPORTING
          out_data            = mt_root_deliv_terms_nodes.

    CALL METHOD mr_lcp->retrieve_by_association
       EXPORTING
          in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-root
          in_association_name = /srmap/if_fndx_pd_template=>co_assoc-root-cash_discount_terms
          in_node_ids         = mt_root_node_id
          in_fill_data        = abap_true
       IMPORTING
          out_data            = mt_root_cashdiscount_nodes.

    CALL METHOD mr_lcp->retrieve_by_association
       EXPORTING
          in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-root
          in_association_name = /srmap/if_fndx_pd_template=>co_assoc-root-party
          in_node_ids         = mt_root_node_id
          in_fill_data        = abap_true
       IMPORTING
          out_data            = mt_root_party_nodes.

     CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_md_party_ids
       EXPORTING
          it_root_node_ids               = mt_root_node_id
          it_party_nodes                 = mt_root_party_nodes
          iv_read_buyer_party_seller_ids = abap_true
          ir_lcp_facade                  = mr_lcp_facade
          ir_lcp                         = mr_lcp
       IMPORTING
          et_md_party_ids                = mt_party_ids
          et_messages                    = lt_messages.

     " check if a seller party exists and retrieve its party_contact_party
     READ TABLE mt_root_party_nodes ASSIGNING <fs_root_party>
              WITH KEY role_category_code = /srmap/if_fnd_constants_party=>c_seller
              BINARY SEARCH.
     IF sy-subrc = 0 AND <fs_root_party> IS ASSIGNED.
        CLEAR lt_party_contact_party_id.
        APPEND <fs_root_party>-node_id TO lt_party_contact_party_id.
        CALL METHOD mr_lcp->retrieve_by_association
          EXPORTING
             in_bo_node_name            = /srmap/if_fndx_pd_template=>co_bo_node-party
             in_association_name        = /srmap/if_fndx_pd_template=>co_assoc-party-party_contact_party
             in_node_ids                = lt_party_contact_party_id
             in_fill_data               = abap_true
          IMPORTING
             out_data                   = mt_party_contact_party.
        SORT mt_party_contact_party BY parent_node_id ASCENDING.
     ENDIF.

     CALL METHOD mr_lcp->retrieve_by_association
        EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-root
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-root-btd_reference
           in_node_ids         = mt_root_node_id
           in_fill_data        = abap_true
        IMPORTING
           out_data            = mt_root_btd_reference.

     CALL METHOD mr_lcp->retrieve_by_association
        EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-item
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-item-item_delivery_terms
           in_node_ids         = mt_item_id
           in_fill_data        = abap_true
        IMPORTING
           out_data            = mt_item_deliv_terms_nodes.

     CALL METHOD mr_lcp->retrieve_by_association
        EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-item
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-item-item_party
           in_node_ids         = mt_item_id
           in_fill_data        = abap_true
        IMPORTING
           out_data            = mt_item_party_nodes.

     CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_md_party_ids
        EXPORTING
           it_root_node_ids    = mt_root_node_id
           it_item_party_nodes = mt_item_party_nodes
           ir_lcp_facade       = mr_lcp_facade
           ir_lcp              = mr_lcp
        IMPORTING
           et_md_party_ids     = mt_item_party_ids
           et_messages         = lt_messages.

     CALL METHOD mr_lcp->retrieve_by_association
        EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-item
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-item-item_product
           in_node_ids         = mt_item_id
           in_fill_data        = abap_true
        IMPORTING
           out_data            = mt_item_product_nodes.

     CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_md_product_ids
        EXPORTING
           it_item_product_nodes = mt_item_product_nodes
           ir_lcp_facade         = mr_lcp_facade
        IMPORTING
           et_md_product_ids     = mt_product_standard_ids.

     CALL METHOD mr_lcp->retrieve_by_association
        EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-item
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-item-item_location
           in_node_ids         = mt_item_id
           in_fill_data        = abap_true
        IMPORTING
           out_data            = mt_item_location_nodes.

     CLEAR lt_node_ids.
     LOOP AT mt_item_location_nodes INTO ls_item_loc_nodes.
         lv_node_id = ls_item_loc_nodes-node_id.
         APPEND lv_node_id TO lt_node_ids.
         CLEAR lv_node_id.
     ENDLOOP.
     CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_md_location_ids
        EXPORTING
           it_location_node_ids   = lt_node_ids
           iv_location_node_name  = /srmap/if_fndx_pd_template=>co_bo_node-item_location
           iv_bo_association_name = /srmap/if_fndx_pd_template=>co_assoc-item_location-loc
           ir_lcp_facade          = mr_lcp_facade
           ir_lcp                 = mr_lcp
        IMPORTING
           et_md_location_ids     = mt_item_loc_standard_id.

      CALL METHOD mr_lcp->retrieve_by_association
         EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-item
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-item-item_btd_reference
           in_node_ids         = mt_item_id
           in_fill_data        = abap_true
         IMPORTING
           out_data            = mt_item_btd_reference.

      CALL METHOD mr_lcp->retrieve_by_association
         EXPORTING
           in_bo_node_name     = /srmap/if_fndx_pd_template=>co_bo_node-item
           in_association_name = /srmap/if_fndx_pd_template=>co_assoc-item-item_schedule_line
           in_node_ids         = mt_item_id
           in_fill_data        = abap_true
         IMPORTING
           out_data            = mt_item_schedule_lines.

       CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_do_att
         EXPORTING
           it_bo_parent_node_ids   = mt_root_node_id
           iv_bo_parent_node_name  = /srmap/if_fndx_pd_template=>co_bo_node-root
           iv_do_prefix            = /srmap/if_fndx_pd_template=>co_do_prefix-root-attachment_folder         "AttachmentFolder
           iv_request_before_image = abap_false
           ir_lcp                  = mr_lcp
         IMPORTING
           et_att_nodes            = mt_root_att_nodes.

       CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_do_ltx
         EXPORTING
           it_bo_parent_node_ids   = mt_root_node_id
           iv_bo_parent_node_name  = /srmap/if_fndx_pd_template=>co_bo_node-root
           iv_do_prefix            = /srmap/if_fndx_pd_template=>co_do_prefix-root-text_collection
           iv_request_before_image = abap_false
           ir_lcp                  = mr_lcp
         IMPORTING
           et_ltx_nodes            = mt_root_ltx_nodes.

     LOOP AT mt_item_nodes ASSIGNING <ls_item_node>.
        ls_item_uuid-guid = <ls_item_node>-node_id.
        INSERT ls_item_uuid INTO TABLE lt_item_uuids.
     ENDLOOP.
      IF lt_item_uuids IS NOT INITIAL.
        CREATE OBJECT lr_pop_helper.
        CALL METHOD lr_pop_helper->get_act_pco_to_po
          EXPORTING
            iv_get_with_dap     = abap_true
            iv_get_pco_item_btd = abap_true
            it_item_guids       = lt_item_uuids
          IMPORTING
            et_pco_item_btd     = mt_pco_so_reference_nodes.
      ENDIF.

    CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_do_addr
       EXPORTING
          it_party                = mt_root_party_nodes
          it_item_party           = mt_item_party_nodes
          it_party_contact_party  = mt_party_contact_party
          it_location             = mt_root_location_nodes
          it_item_location        = mt_item_location_nodes
          iv_b2b_message          = abap_true
          iv_request_before_image = abap_false
          ir_lcp_facade           = mr_lcp_facade
          ir_lcp                  = mr_lcp
       IMPORTING
          et_addr_nodes           = mt_addr_nodes
          et_messages             = lt_messages.

    CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_do_att
       EXPORTING
          it_bo_parent_node_ids   = mt_item_id
          iv_bo_parent_node_name  = /srmap/if_fndx_pd_template=>co_bo_node-item
          iv_do_prefix            = /srmap/if_fndx_pd_template=>co_do_prefix-item-item_attachment_folder         "ItemAttachmentFolder
          iv_request_before_image = abap_false
          ir_lcp                  = mr_lcp
       IMPORTING
          et_att_nodes            = mt_item_att_nodes.

    CALL METHOD /srmap/cl_fnd_paf_helper=>retrieve_do_ltx
       EXPORTING
          it_bo_parent_node_ids   = mt_item_id
          iv_bo_parent_node_name  = /srmap/if_fndx_pd_template=>co_bo_node-item
          iv_do_prefix            = /srmap/if_fndx_pd_template=>co_do_prefix-item-item_text_collection        "ItemTextCollection
          iv_request_before_image = abap_false
          ir_lcp                  = mr_lcp
       IMPORTING
          et_ltx_nodes            = mt_item_ltx_nodes.
    CATCH cx_esf_core_service INTO lx_error.
     lv_error_message = lx_error->get_text( ).
     MESSAGE E001(/SF0A0001/PODEMO) WITH lv_error_message.
  ENDTRY.

*    CALL METHOD me->convert_party_ids_to_ext_ids
*      CHANGING
*        ct_party      = me->mt_root_party_nodes
*        ct_item_party = me->mt_item_party_nodes.
endmethod.

method GET_RECEIVER_EMAIL.

  DATA:lt_address_association TYPE SESF_ASSOCIATION_LINK_TAB,
       ls_link TYPE SESF_ASSOCIATION_LINK,
       lt_node_id TYPE SESF_BO_NODE_ID_TAB,
       ls_node_id TYPE SESF_BO_NODE_ID,
       lt_email TYPE IF_ADDRP_ADDRESS=>TT_EMAIL,
       ls_email TYPE IF_ADDRP_ADDRESS=>TY_EMAIL,
       lx_exception TYPE REF TO cx_esf_core_service.

  APPEND mv_root_node_id TO lt_node_id.

  TRY.
  CALL METHOD mr_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'ROOT'
       IN_ASSOCIATION_NAME = 'SELLER_PARTY'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.

  CHECK lt_address_association IS NOT INITIAL.
  CLEAR: lt_node_id.
  LOOP AT lt_address_association INTO ls_link.
    APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.
  CLEAR: lt_address_association.
  CALL METHOD mr_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'PARTY'
       IN_ASSOCIATION_NAME = 'PARTY'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.
  CHECK lt_address_association IS NOT INITIAL.
  CLEAR: lt_node_id.

  LOOP AT lt_address_association INTO ls_link.
     APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.

  CLEAR: lt_address_association.
  CALL METHOD mv_party_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'ROOT'
       IN_ASSOCIATION_NAME = 'CURR_DEF_ADDR_INF'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.

  CHECK lt_address_association IS NOT INITIAL.
  CLEAR lt_node_id.
  LOOP AT lt_address_association INTO ls_link.
     APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.

  CLEAR lt_address_association.
  call method mv_party_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'ADDRESS_INFORMATION'
       IN_ASSOCIATION_NAME = 'ADDRESS'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.

  CHECK lt_address_association IS NOT INITIAL.

  CLEAR lt_node_id.
  LOOP AT lt_address_association INTO ls_link.
     APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.
  CLEAR: lt_address_association.


  CALL METHOD mv_party_lcp->RETRIEVE_BY_ASSOCIATION
  EXPORTING
    IN_BO_NODE_NAME     = 'Address.ROOT'
    IN_ASSOCIATION_NAME = 'DEFAULT_EMAIL'
    IN_NODE_IDS         = lt_node_id
    IN_FILL_DATA        = 'X'
  IMPORTING
    out_data  = lt_email.

  CATCH cx_esf_core_service INTO lx_exception.
     lv_error_message = lx_exception->get_text( ).
     MESSAGE E001(/SF0A0001/PODEMO) WITH lv_error_message.
  ENDTRY.

  CHECK lt_email IS NOT INITIAL.
  READ TABLE lt_email INTO ls_email INDEX 1.
  mv_receiver_mail = ls_email-URI-content.
endmethod.

method GET_SENDER_MAIL.
  DATA:lt_address_association TYPE SESF_ASSOCIATION_LINK_TAB,
       ls_link TYPE SESF_ASSOCIATION_LINK,
       lt_node_id TYPE SESF_BO_NODE_ID_TAB,
       ls_node_id TYPE SESF_BO_NODE_ID,
       lt_email TYPE IF_ADDRP_ADDRESS=>TT_EMAIL,
       ls_email TYPE IF_ADDRP_ADDRESS=>TY_EMAIL,
       lx_exception TYPE REF TO cx_esf_core_service.

  APPEND mv_root_node_id TO lt_node_id.

  TRY.
  CALL METHOD mr_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'ROOT'
       IN_ASSOCIATION_NAME = 'BUYER_PARTY'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.

  CHECK lt_address_association IS NOT INITIAL.
  CLEAR: lt_node_id.
  LOOP AT lt_address_association INTO ls_link.
    APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.
  CLEAR: lt_address_association.
  CALL METHOD mr_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'PARTY'
       IN_ASSOCIATION_NAME = 'PARTY'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.
  CHECK lt_address_association IS NOT INITIAL.
  CLEAR: lt_node_id.

  LOOP AT lt_address_association INTO ls_link.
     APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.

  CLEAR: lt_address_association.
  CALL METHOD mv_party_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'ROOT'
       IN_ASSOCIATION_NAME = 'CURR_DEF_ADDR_INF'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.

  CHECK lt_address_association IS NOT INITIAL.
  CLEAR lt_node_id.
  LOOP AT lt_address_association INTO ls_link.
     APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.

  CLEAR lt_address_association.
  call method mv_party_lcp->RETRIEVE_BY_ASSOCIATION
     EXPORTING
       IN_BO_NODE_NAME     = 'ADDRESS_INFORMATION'
       IN_ASSOCIATION_NAME = 'ADDRESS'
       IN_NODE_IDS         = lt_node_id
       IN_FILL_DATA        = ABAP_FALSE
     IMPORTING
       OUT_LINKS = lt_address_association.

  CHECK lt_address_association IS NOT INITIAL.

  CLEAR lt_node_id.
  LOOP AT lt_address_association INTO ls_link.
     APPEND ls_link-target_node_id TO lt_node_id.
  ENDLOOP.
  CLEAR: lt_address_association.


  CALL METHOD mv_party_lcp->RETRIEVE_BY_ASSOCIATION
  EXPORTING
    IN_BO_NODE_NAME     = 'Address.ROOT'
    IN_ASSOCIATION_NAME = 'DEFAULT_EMAIL'
    IN_NODE_IDS         = lt_node_id
    IN_FILL_DATA        = 'X'
  IMPORTING
    out_data  = lt_email.

  CATCH cx_esf_core_service INTO lx_exception.
     lv_error_message = lx_exception->get_text( ).
     MESSAGE E001(/SF0A0001/PODEMO) WITH lv_error_message.
  ENDTRY.
  CHECK lt_email IS NOT INITIAL.
  READ TABLE lt_email INTO ls_email INDEX 1.
  mv_sender_email = ls_email-URI-content.
endmethod.

method INIT.
  DATA: ls_bo_instance TYPE /DOC/OM_ST_BO_INS,
        lt_dn_item_node_link      TYPE sesf_association_link_tab,
        ls_dn_item_node_link      TYPE sesf_association_link,
        lx_exception TYPE REF TO cx_esf_core_service.

  LOOP AT in_bo_instance_tab INTO ls_bo_instance.
     APPEND ls_bo_instance-BO_ID TO mt_root_node_id.
     mv_root_node_id = ls_bo_instance-BO_ID.
  ENDLOOP.



  CALL METHOD cl_esf_lcp_factory=>get_lcp_facade
    RECEIVING out_lcp_facade = mr_lcp_facade.

  TRY.
  mr_lcp = mr_lcp_facade->get_lcp( '/SRMAP/LPURX_PO' ).
  mv_party_lcp = mr_lcp_facade->get_lcp( 'PARTY' ).


  CALL METHOD mr_lcp->retrieve_by_association
        EXPORTING
            in_bo_node_name     = 'ROOT'
            in_association_name = 'ITEM'
            in_node_ids         = mt_root_node_id
        IMPORTING
            out_links           = lt_dn_item_node_link.
  CATCH cx_esf_core_service INTO lx_exception.
     lv_error_message = lx_exception->get_text( ).
     MESSAGE E001(/SF0A0001/PODEMO) WITH lv_error_message.
  ENDTRY.
  LOOP AT lt_dn_item_node_link INTO ls_dn_item_node_link.
     APPEND ls_dn_item_node_link-target_node_id TO mt_item_id.
  ENDLOOP.

endmethod.

method LOG.
  DATA: ls_entry TYPE /SF0A0001/PO,
        lv_guid TYPE SYSUUID_X16.

  CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_x16
        RECEIVING
          uuid = lv_guid.

  ls_entry-guid = lv_guid.
  ls_entry-username = sy-uname.
  ls_entry-nodeid = mv_root_node_id.
  ls_entry-po_id = mv_po_id.
  ls_entry-sender_mail = mv_sender_email.
  ls_entry-receiver_mail = mv_receiver_mail.
  ls_entry-senddate = sy-datum.
  ls_entry-sendtime = sy-timlo.

  INSERT INTO /SF0A0001/PO VALUES ls_entry.
endmethod.

method MAP_BO2MSG.


   DATA:  lr_map                 TYPE REF TO /srmap/cl_po_paf_map_to_ext,
          ls_buyer_party         TYPE /srmap/if_fndx_pd_template=>ty_party,
          lv_company_id          TYPE OM_COMPANY_ID,
          lr_company             TYPE REF TO /srmap/if_fnd_md_bp_company,
          lv_country             TYPE ap_country_code,
          lr_message             TYPE REF TO CL_SPAF_AGENT_MESSAGE_HANDLER,
          it_bo_node_list        TYPE /SRMAP/T_FND_PAF_BO_NODE_LIST,
          is_bo_node_list        LIKE LINE OF it_bo_node_list,
          ls_item_id             TYPE SESF_BO_NODE_ID.

    FIELD-SYMBOLS: <ls_root_node>          TYPE /srmap/if_fndx_pd_template=>ty_root.

    READ TABLE mt_root_nodes ASSIGNING <ls_root_node> INDEX 1.
    CHECK sy-subrc = 0.
    CREATE OBJECT lr_map.
    CREATE OBJECT lr_message.

    is_bo_node_list-BO_NAME = '/SRMAP/LPURX_PO'.
    is_bo_node_list-BO_ROOT_NODE_ID = mv_root_node_id.
    is_bo_node_list-BO_NODE_NAME = 'ROOT'.
    is_bo_node_list-BO_NODE_ID = is_bo_node_list-BO_ROOT_NODE_ID.
    is_bo_node_list-PROCESSING_INSTRUCTION = 'DATA'.
    APPEND is_bo_node_list TO it_bo_node_list.

    LOOP AT mt_item_id INTO ls_item_id.
       CLEAR is_bo_node_list.
       is_bo_node_list-BO_NAME = '/SRMAP/LPURX_PO'.
       is_bo_node_list-BO_ROOT_NODE_ID = mv_root_node_id.
       is_bo_node_list-BO_NODE_NAME = 'ITEM'.
       is_bo_node_list-BO_NODE_ID = ls_item_id.
       is_bo_node_list-PROCESSING_INSTRUCTION = 'DATA'.
       APPEND is_bo_node_list TO it_bo_node_list.
    ENDLOOP.
    CALL METHOD lr_map->init
      EXPORTING
        iv_agent_class_name    = 'CL_DUMMY'"iv_agent_class_name
        it_bo_node_list        = it_bo_node_list
        iv_b2b_message         = abap_false
        IR_MESSAGE_HANDLER     = lr_message.

    CALL METHOD lr_map->to_s_form_po_msg
          EXPORTING
            iv_interactive_form          = abap_false
            is_root_node                 = <ls_root_node>
            it_item_nodes                = mt_item_nodes
            it_root_party_nodes          = mt_root_party_nodes
            it_root_location_nodes       = mt_root_location_nodes
            it_root_deliv_terms_nodes    = mt_root_deliv_terms_nodes
            it_item_product_nodes        = mt_item_product_nodes
            it_item_deliv_terms_nodes    = mt_item_deliv_terms_nodes
            it_item_party_nodes          = mt_item_party_nodes
            it_item_location_nodes       = mt_item_location_nodes
            it_item_btd_reference        = mt_item_btd_reference
            it_item_schedule_lines       = mt_item_schedule_lines
            it_root_cashdiscount_nodes   = mt_root_cashdiscount_nodes
            it_root_att_nodes            = mt_root_att_nodes
            it_item_att_nodes            = mt_item_att_nodes
            it_root_ltx_nodes            = mt_root_ltx_nodes
            it_item_ltx_nodes            = mt_item_ltx_nodes
            it_location_standard_id      = mt_location_standard_ids
            it_item_location_standard_id = mt_item_loc_standard_id
            it_addr_nodes                = mt_addr_nodes
            it_party_ids                 = mt_party_ids
            it_item_party_ids            = mt_item_party_ids
            it_party_contact_party       = mt_party_contact_party
            it_product_standard_ids      = mt_product_standard_ids
          IMPORTING
            es_form_po_req_msg           = mr_po_msg->form_purchase_order_request.

    CHECK mr_po_msg IS NOT INITIAL.
    mv_po_id = mr_po_msg->FORM_PURCHASE_ORDER_REQUEST-PURCHASE_ORDER-ID-CONTENT.
endmethod.

method SEND_MAIL.
 DATA:
      lv_subject TYPE STRING,
      ls_docdata        TYPE souts_docdata,
      ls_send_data       TYPE souts_senddata,
      ls_recipient TYPE SOUTS_ERECP,
      ls_recipients     TYPE  souts_recp,
      lv_REQUEST_IDS  TYPE SOUTTT_REQID,
      lv_TARGETS_WITH_ERROR TYPE SOUTTT_RECEXC,
      lx_output_service TYPE REF TO CX_OUTPUT_SERVICE,
      lv_error TYPE string.

CHECK im_pdf_data IS NOT INITIAL.
me->get_sender_mail( ).
me->get_receiver_email( ).

CHECK mv_sender_email IS NOT INITIAL.
CHECK mv_receiver_mail IS NOT INITIAL.

lv_subject                 = 'Purchase Order Change'.
ls_recipient-mail_address  = mv_receiver_mail.
APPEND ls_recipient TO ls_recipients-e_recipients.

ls_docdata-TYPE            = 'PDF'.
ls_docdata-TITLE           = 'Purchase Order'.
ls_docdata-CONTENT_BIN = im_pdf_data.
ls_send_data-sender-mail_address         = mv_sender_email.

TRY.
    CL_OUTPUT_SERVICE=>DOCUMENT_OUTPUT(
      EXPORTING
        IP_OUTPUT_IMMEDIATELY   = 'X'
        IP_SUBJECT              = lv_SUBJECT
        IS_RECIPIENTS           = ls_recipients
        IS_DOCDATA              = ls_docdata
        IS_SEND_DATA            = ls_send_data
      IMPORTING
        ET_REQUEST_IDS          = lv_REQUEST_IDS
        ET_TARGETS_WITH_ERROR   = lv_TARGETS_WITH_error
        ).
  CATCH CX_OUTPUT_SERVICE INTO lx_output_service.
     lv_error = lx_output_service->get_text( ).
     MESSAGE lv_error TYPE 'E'.

ENDTRY.

COMMIT WORK AND WAIT.
endmethod.

message class: /SF0A0001/PODEMO
000:test message
001:lcp call error:&1