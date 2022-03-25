set define off
prompt PATH /helpdesk/hdr/template
begin
uis.route('/helpdesk/hdr/template+add$save','Ui_Helpdesk38.Save','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdr/template+add:model','Ui_Helpdesk38.Add_Model',null,'M','A','Y',null,null,null);
uis.route('/helpdesk/hdr/template+add:quiz_options','Ui_Helpdesk38.Query_Quiz_Options',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdr/template+add:quizs','Ui_Helpdesk38.Query_Quizs',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdr/template+edit$save','Ui_Helpdesk38.Save','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdr/template+edit:model','Ui_Helpdesk38.Edit_Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hdr/template+edit:quiz_options','Ui_Helpdesk38.Query_Quiz_Options',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdr/template+edit:quizs','Ui_Helpdesk38.Query_Quizs',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hdr/template','helpdesk38');
uis.form('/helpdesk/hdr/template','/helpdesk/hdr/template','A','A','F','H','M','N',null);
uis.form('/helpdesk/hdr/template+add','/helpdesk/hdr/template','A','A','F','H','M','N',null);
uis.form('/helpdesk/hdr/template+edit','/helpdesk/hdr/template','A','A','F','H','M','N',null);



uis.action('/helpdesk/hdr/template+add','save','A',null,null,'A');
uis.action('/helpdesk/hdr/template+edit','save','A',null,null,'A');



uis.ready('/helpdesk/hdr/template','.model.');
uis.ready('/helpdesk/hdr/template+add','.model.save.');
uis.ready('/helpdesk/hdr/template+edit','.model.save.');

commit;
end;
/
