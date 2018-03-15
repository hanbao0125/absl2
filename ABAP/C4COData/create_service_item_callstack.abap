YTEJ8CJ8Y_CL_S975A99AC46E3924A~create_node
 CL_PDI_ABSL_RT_ADAPTER~create_node
  CL_PDI_ABSL_RT_ADAPTER~create - return created NODE
   CL_PDI_ABSL_RT_ADAPTER~create_esf2 
     (1) get bo metadata dynamically via cl_esf_bo_access=>get_node_table_container
     (2) go_lcp_facade->get_lcp( in_bo_name = cv_bo_name ).
     (3) cl_esf_bo_access=>create 
       (1) mapper = get_runtime_mapper( 'SERVICE_REQUEST' ): result->CL_ESF_BO_ACCESS2CR_MAPPER
       (2) CL_ESF_BO_ACCESS2CR_MAPPER->create
         ls_runtime_context-core_runtime->_map_and_modify: CL_ESF_CORE_RUNTIME
          CL_ESF_CORE_RUNTIME~_modify
           (1) mo_locker->lock_for_modify
           (2) determine_delete_cascade "Jerry: as always in ABAP, deletion is considered FIRST
           " create a snapshot to support before modify image for layered extensions and
           "to roll back changes in case reject modify validations fail
           (3) mo_service_manager->create_snapshot
           " let modifications become effective
           (4) mo_buffer->modify:CL_ESF_DATA_ACCESS
             (1) CL_ESF_SNAPSHOT_VERSION_CTRL~before_modify
             (2) CASE modification-mode
                  WHEN create.
                    create_node_instances_by_assoc
                      create_node_instance " Jerry: CL_ESF_BUFFER~CREATE_NODE_INSTANCE still called within loop 
                       (1) transfer_attributes
                       (2) io_change_handler->notify_create
                       "notify all composition like associations
                       (3) io_change_handler->notify_update
                       "Jerry: SAM notification
                       (4) mo_notification_handler->notify
                  WHEN update.
              " Jerry: entry point for AFTER_MODIFY determination by CL_ESF_CORE_RUNTIME
              (3) do_determinations(cl_esf_rt_metadata_access=>gcs_det_exec_time-after_modify ))
                (1) 
           (5) mo_sam->process_sam_changes
