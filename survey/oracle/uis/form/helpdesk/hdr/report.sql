set define off
prompt PATH /helpdesk/hdr/report
begin
uis.route('/helpdesk/hdr/report:filials','Ui_Helpdesk39.Query_Filials',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdr/report:model','Ui_Helpdesk39.Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hdr/report:quiz_options','Ui_Helpdesk39.Query_Quiz_Options',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdr/report:quizs','Ui_Helpdesk39.Query_Quizs',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdr/report:run','Ui_Helpdesk39.Run','M',null,'A',null,null,null,null);

uis.path('/helpdesk/hdr/report','helpdesk39');
uis.form('/helpdesk/hdr/report','/helpdesk/hdr/report','A','A','F','H','M','N',null);



uis.action('/helpdesk/hdr/report','edit','A','/helpdesk/hdr/template+edit','S','O');



uis.ready('/helpdesk/hdr/report','.edit.model.');

commit;
end;
/
