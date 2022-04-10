set define off
prompt PATH /helpdesk/hdr/report_template
begin
uis.route('/helpdesk/hdr/report_template+add:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hdr/report_template+add:sample_report_data','Ui_Helpdesk33.Sample_Report_Data',null,'M','A',null,null,null,null);
uis.route('/helpdesk/hdr/report_template+add:save_report_template','Ui_Helpdesk33.Save_Report_Template','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdr/report_template+edit:model','Ui_Helpdesk33.Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hdr/report_template+edit:sample_report_data','Ui_Helpdesk33.Sample_Report_Data',null,'M','A',null,null,null,null);
uis.route('/helpdesk/hdr/report_template+edit:save_report_template','Ui_Helpdesk33.Save_Report_Template','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdr/report_template+open:model','Ui_Helpdesk33.Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hdr/report_template+open:run','Ui_Helpdesk33.Run','M','M','A',null,null,null,null);
uis.route('/helpdesk/hdr/report_template+open:table_filials','Ui_Helpdesk33.Filials',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hdr/report_template','helpdesk33');
uis.form('/helpdesk/hdr/report_template','/helpdesk/hdr/report_template','A','A','F','H','M','N',null);
uis.form('/helpdesk/hdr/report_template+add','/helpdesk/hdr/report_template','A','A','F','H','M','N',null);
uis.form('/helpdesk/hdr/report_template+edit','/helpdesk/hdr/report_template','A','A','F','H','M','N',null);
uis.form('/helpdesk/hdr/report_template+open','/helpdesk/hdr/report_template','A','A','F','H','M','N',null);






uis.ready('/helpdesk/hdr/report_template+open','.model.');
uis.ready('/helpdesk/hdr/report_template','.model.');
uis.ready('/helpdesk/hdr/report_template+add','.model.');
uis.ready('/helpdesk/hdr/report_template+edit','.model.');

commit;
end;
/
