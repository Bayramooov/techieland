set define off
prompt PATH /helpdesk/hd/quiz_set_group_binds
begin
uis.route('/helpdesk/hd/quiz_set_group_binds$attach','Ui_Helpdesk18.Attach','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_group_binds$detach','Ui_Helpdesk18.Detach','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_group_binds:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_group_binds:table','Ui_Helpdesk18.Query','M','Q','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_group_binds','helpdesk18');
uis.form('/helpdesk/hd/quiz_set_group_binds','/helpdesk/hd/quiz_set_group_binds','H','A','F','H','M','N',null);



uis.action('/helpdesk/hd/quiz_set_group_binds','add_quiz_set','H','/helpdesk/hd/quiz_set+add','D','O');
uis.action('/helpdesk/hd/quiz_set_group_binds','attach','H',null,null,'A');
uis.action('/helpdesk/hd/quiz_set_group_binds','detach','H',null,null,'A');



uis.ready('/helpdesk/hd/quiz_set_group_binds','.add_quiz_set.attach.detach.model.');

commit;
end;
/
