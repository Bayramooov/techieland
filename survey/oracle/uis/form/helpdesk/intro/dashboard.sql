set define off
prompt PATH /helpdesk/intro/dashboard
begin
uis.route('/helpdesk/intro/dashboard:model','Ui.No_Model',null,null,'S','Y',null,null,null);

uis.path('/helpdesk/intro/dashboard','helpdesk34');
uis.form('/helpdesk/intro/dashboard','/helpdesk/intro/dashboard','A','S','N','H','M','N',null);






uis.ready('/helpdesk/intro/dashboard','.model.');

commit;
end;
/
