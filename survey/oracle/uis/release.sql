set define off
set serveroutput on
declare
v_project_code varchar2(10) := 'helpdesk';
--------------------------------------------------
procedure form(a varchar2, b varchar2) is begin
z_md_release_forms.save_one(i_PROJECT_CODE=>v_project_code,i_FORM=>a,i_ACTION_SET=>b);end;
--------------------------------------------------
procedure garbage(a varchar2) is begin
z_md_garbage_forms.insert_try(i_PROJECT_CODE=>v_project_code,i_FORM=>a);end;
begin
delete md_release_forms t where t.project_code = v_project_code;
delete md_garbage_forms t where t.project_code = v_project_code;
----------------------------------------------------------------------------------------------------
dbms_output.put_line('==== Release forms ====');
form('/core/intro/help','.model.');
form('/core/m','.model.');
form('/core/md/access_request','.done.done_for_role.model.to_full_form.');
form('/core/md/access_request_list','.model.open.reject.');
form('/core/md/attach_role','.attach.detach.model.set_mode.');
form('/core/md/audit_list','.details.model.');
form('/core/md/audit_setting','.audit.model.');
form('/core/md/change_password','.model.');
form('/core/md/company_add','.model.save.');
form('/core/md/company_audit_info_audit','.details.model.');
form('/core/md/company_audit_info_audit_details','.model.');
form('/core/md/company_edit','.model.save.');
form('/core/md/company_filial_project','.model.');
form('/core/md/company_list','.add.edit.model.remove.view.');
form('/core/md/company_module_setting','.model.');
form('/core/md/company_view','.admin.audit.edit.error.license.model.project.reset_admin_password.');
form('/core/md/filial+add','.model.');
form('/core/md/filial+edit','.model.');
form('/core/md/filial_audit','.details.model.');
form('/core/md/filial_audit_details','.model.');
form('/core/md/filial_list','.add.delete.edit.model.view.');
form('/core/md/filial_user_list','.attach.detach.model.set_mode.');
form('/core/md/filial_view','.attach.audit_details.detach.edit.model.programm_errors.user_audits.users.');
form('/core/md/help_form','.model.');
form('/core/md/log_list','.model.');
form('/core/md/person_audit_details','.model.');
form('/core/md/profile','.details.model.');
form('/core/md/query_executor','.model.');
form('/core/md/region+add','.model.');
form('/core/md/region+edit','.model.');
form('/core/md/region_audit','.details.model.');
form('/core/md/region_audit_details','.model.');
form('/core/md/region_list','.add.audit.child.delete.edit.model.select.');
form('/core/md/region_list+cities','.add.audit.child.delete.edit.model.');
form('/core/md/region_list+districts','.add.audit.delete.edit.model.select.');
form('/core/md/region_list+towns','.add.audit.child.delete.edit.model.');
form('/core/md/region_list+x','.model.');
form('/core/md/role+add','.model.');
form('/core/md/role+edit','.model.');
form('/core/md/role_audit','.details.model.');
form('/core/md/role_audit_details','.model.');
form('/core/md/role_form_action','.model.next.save.');
form('/core/md/role_form_list','.access_generate_all.attach.bind_doc_report.bind_external.bind_form.bind_report.bind_widget.detach.model.next.set_mode.');
form('/core/md/role_list','.add.audit.bind_forms.bind_projects.bind_users.delete.edit.model.');
form('/core/md/role_project','.model.');
form('/core/md/role_user_list','.attach.detach.model.set_mode.');
form('/core/md/set_role_access','.model.');
form('/core/md/user+add','.model.model.');
form('/core/md/user+edit','.model.');
form('/core/md/user_access_request','.model.');
form('/core/md/user_audit','.details.model.');
form('/core/md/user_audit_details','.model.');
form('/core/md/user_form_action','.model.next.save.');
form('/core/md/user_form_list','.attach.bind_doc_report.bind_external.bind_form.bind_report.bind_widget.detach.model.next.set_mode.');
form('/core/md/user_list','.add.audit.bind_forms.change_state.delete.delete_device.edit.model.tokens.view.');
form('/core/md/user_token','.model.');
form('/core/md/user_token+add','.generate.model.');
form('/core/md/user_token_list','.add.delete.model.');
form('/core/md/user_view','.audit.details.edit.model.model.programm_errors.');
form('/core/mf/file_manager','.model.');
form('/core/ms/kanban','.model.task.');
form('/core/ms/message+add','.model.');
form('/core/ms/message+edit','.model.');
form('/core/ms/message_list','.model.');
form('/core/ms/notification','.model.');
form('/core/ms/notification_list','.model.');
form('/core/ms/task+add','.add_type.model.select_type.');
form('/core/ms/task+add_template','.model.');
form('/core/ms/task+edit_template','.model.');
form('/core/ms/task+view','.add_type.model.select_type.');
form('/core/ms/task_attach','.add.model.');
form('/core/ms/task_attach_group','.model.select_type.');
form('/core/ms/task_group+add','.model.');
form('/core/ms/task_group+edit','.model.save.');
form('/core/ms/task_group_list','.add.child.delete.edit.group_settings.model.');
form('/core/ms/task_group_settings','.default_groups.model.save.');
form('/core/ms/task_list','.attach_person.attach_task_group.detach_person.model.set_involve_statuses.view.');
form('/core/ms/task_project+add','.model.');
form('/core/ms/task_project+edit','.model.');
form('/core/ms/task_project_list','.add.delete.edit.model.tasks.');
form('/core/ms/task_status+add','.model.');
form('/core/ms/task_status+edit','.model.');
form('/core/ms/task_status_list','.add.delete.edit.model.set_order_no.');
form('/core/ms/task_template_list','.model.');
form('/core/ms/task_type+add','.model.');
form('/core/ms/task_type+edit','.model.');
form('/core/ms/task_type_list','.add.delete.edit.model.');
form('/core/ms/task_user_list','.add.delete.edit.model.');
form('/core/mt/sync','.model.');
form('/core/ph/kanban','.model.');
form('/core/ph/task','.model.');
form('/core/s','.model.');
form('/helpdesk/hd/quiz+add','.add_child_quiz.add_quiz.add_quiz_set.model.select_quiz.select_quiz_set.');
form('/helpdesk/hd/quiz+edit','.add_quiz.add_quiz_set.model.select_quiz.select_quiz_set.');
form('/helpdesk/hd/quiz_list','.add.delete.edit.model.');
form('/helpdesk/hd/quiz_set+add','.model.');
form('/helpdesk/hd/quiz_set+edit','.model.');
form('/helpdesk/hd/quiz_set_binds','.add_quiz.attach.detach.model.');
form('/helpdesk/hd/quiz_set_binds_set_order','.model.save.');
form('/helpdesk/hd/quiz_set_group+add','.model.');
form('/helpdesk/hd/quiz_set_group+edit','.model.');
form('/helpdesk/hd/quiz_set_group_attach','.model.');
form('/helpdesk/hd/quiz_set_group_binds','.add_quiz_set.attach.detach.model.');
form('/helpdesk/hd/quiz_set_group_binds_set_order','.model.');
form('/helpdesk/hd/quiz_set_group_list','.add.bind_quiz_sets.delete.edit.model.set_order_no.');
form('/helpdesk/hd/quiz_set_list','.add.bind_quizs.delete.edit.model.set_order.');
form('/helpdesk/hdf/survey+add','.model.save.');
form('/helpdesk/hdf/survey+edit','.model.save.');
form('/helpdesk/hdf/survey_list','.add.delete.edit.model.view.');
form('/helpdesk/hdf/survey_view','.model.');
form('/helpdesk/hdr/report','.edit.model.');
form('/helpdesk/hdr/report_template','.model.');
form('/helpdesk/hdr/report_template+add','.model.');
form('/helpdesk/hdr/report_template+edit','.model.');
form('/helpdesk/hdr/report_template+open','.model.');
form('/helpdesk/hdr/template','.model.');
form('/helpdesk/hdr/template+add','.model.save.');
form('/helpdesk/hdr/template+edit','.model.save.');
form('/helpdesk/hdr/template_list','.add.delete.edit.model.open.');
form('/helpdesk/intro/dashboard','.model.');
----------------------------------------------------------------------------------------------------
dbms_output.put_line('==== Garbages ====');
commit;
end;
/