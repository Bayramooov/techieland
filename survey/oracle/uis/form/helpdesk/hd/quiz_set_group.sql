set define off
prompt PATH /helpdesk/hd/quiz_set_group
begin
uis.route('/helpdesk/hd/quiz_set_group+add:model','Ui_Helpdesk13.Add_Model',null,'M','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_group+add:save','Ui_Helpdesk13.Add','M','M','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_group+edit:model','Ui_Helpdesk13.Edit_Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_group+edit:save','Ui_Helpdesk13.Edit','M','M','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_group','helpdesk13');
uis.form('/helpdesk/hd/quiz_set_group+add','/helpdesk/hd/quiz_set_group','H','A','F','H','M','N',null);
uis.form('/helpdesk/hd/quiz_set_group+edit','/helpdesk/hd/quiz_set_group','H','A','F','H','M','N',null);






uis.ready('/helpdesk/hd/quiz_set_group+edit','.model.');
uis.ready('/helpdesk/hd/quiz_set_group+add','.model.');

commit;
end;
/
