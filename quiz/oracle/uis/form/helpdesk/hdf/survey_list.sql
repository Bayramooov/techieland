set define off
prompt PATH /helpdesk/hdf/survey_list
begin
uis.route('/helpdesk/hdf/survey_list:model','Ui_Helpdesk23.Model',null,'M','A','Y',null,null,null);
uis.route('/helpdesk/hdf/survey_list:table','Ui_Helpdesk23.Query',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdf/survey_list:table_quiz_set_groups','Ui_Helpdesk23.Query_Quiz_Set_Groups',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hdf/survey_list','helpdesk23');
uis.form('/helpdesk/hdf/survey_list','/helpdesk/hdf/survey_list','F','A','F','HM','M','N',null);



uis.action('/helpdesk/hdf/survey_list','add','F','/helpdesk/hdf/survey+add','S','O');
uis.action('/helpdesk/hdf/survey_list','delete','F',null,null,'A');
uis.action('/helpdesk/hdf/survey_list','edit','F','/helpdesk/hdf/survey+edit','S','O');
uis.action('/helpdesk/hdf/survey_list','view','F','/helpdesk/hdf/survey_view','S','O');



uis.ready('/helpdesk/hdf/survey_list','.add.delete.edit.model.view.');

commit;
end;
/
