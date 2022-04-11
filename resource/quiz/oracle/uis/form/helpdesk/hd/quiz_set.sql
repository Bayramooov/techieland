set define off
prompt PATH /helpdesk/hd/quiz_set
begin
uis.route('/helpdesk/hd/quiz_set+add:model','Ui_Helpdesk15.Add_Model',null,'M','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set+add:save','Ui_Helpdesk15.Add','M','M','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set+edit:model','Ui_Helpdesk15.Edit_Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set+edit:save','Ui_Helpdesk15.Edit','M',null,'A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set','helpdesk15');
uis.form('/helpdesk/hd/quiz_set+add','/helpdesk/hd/quiz_set','H','A','F','H','M','N',null);
uis.form('/helpdesk/hd/quiz_set+edit','/helpdesk/hd/quiz_set','A','A','F','H','M','N',null);






uis.ready('/helpdesk/hd/quiz_set+add','.model.');
uis.ready('/helpdesk/hd/quiz_set+edit','.model.');

commit;
end;
/
