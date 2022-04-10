set define off
prompt PATH /helpdesk/hd/quiz_set_binds_set_order
begin
uis.route('/helpdesk/hd/quiz_set_binds_set_order:model','Ui_Helpdesk21.Model','M','L','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_binds_set_order:save','Ui_Helpdesk21.Set_Order','M',null,'A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_binds_set_order','helpdesk21');
uis.form('/helpdesk/hd/quiz_set_binds_set_order','/helpdesk/hd/quiz_set_binds_set_order','H','A','F','H','M','N',null);



uis.action('/helpdesk/hd/quiz_set_binds_set_order','save','H',null,null,'A');



uis.ready('/helpdesk/hd/quiz_set_binds_set_order','.model.save.');

commit;
end;
/
