set define off
prompt PATH /helpdesk/hdf/survey_view
begin
uis.route('/helpdesk/hdf/survey_view:model','Ui_Helpdesk29.Model','M','M','A','Y',null,null,null);

uis.path('/helpdesk/hdf/survey_view','helpdesk29');
uis.form('/helpdesk/hdf/survey_view','/helpdesk/hdf/survey_view','A','A','F','H','M','N',null);






uis.ready('/helpdesk/hdf/survey_view','.model.');

commit;
end;
/
