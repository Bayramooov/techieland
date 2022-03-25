set define off
prompt PATH /helpdesk/hd/quiz_set_binds
begin
uis.route('/helpdesk/hd/quiz_set_binds$attach','Ui_Helpdesk17.Attach','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_binds$detach','Ui_Helpdesk17.Detach','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_binds:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_binds:table','Ui_Helpdesk17.Query','M','Q','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_binds','helpdesk17');
uis.form('/helpdesk/hd/quiz_set_binds','/helpdesk/hd/quiz_set_binds','H','A','F','H','M','N',null);



uis.action('/helpdesk/hd/quiz_set_binds','add_quiz','H','/helpdesk/hd/quiz+add','D','O');
uis.action('/helpdesk/hd/quiz_set_binds','attach','H',null,null,'A');
uis.action('/helpdesk/hd/quiz_set_binds','detach','H',null,null,'A');



uis.ready('/helpdesk/hd/quiz_set_binds','.add_quiz.attach.detach.model.');

commit;
end;
/
