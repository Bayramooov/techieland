set define off
prompt PATH /helpdesk/hd/quiz_set_group_binds_set_order
begin
uis.route('/helpdesk/hd/quiz_set_group_binds_set_order:model','Ui_Helpdesk22.Model','M','L','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_group_binds_set_order:save','Ui_Helpdesk22.Set_Order','M',null,'A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_group_binds_set_order','helpdesk22');
uis.form('/helpdesk/hd/quiz_set_group_binds_set_order','/helpdesk/hd/quiz_set_group_binds_set_order','H','A','F','H','M','N',null);






uis.ready('/helpdesk/hd/quiz_set_group_binds_set_order','.model.');

commit;
end;
/
