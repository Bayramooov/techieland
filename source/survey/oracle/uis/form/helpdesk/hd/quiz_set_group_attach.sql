set define off
prompt PATH /helpdesk/hd/quiz_set_group_attach
begin

uis.path('/helpdesk/hd/quiz_set_group_attach','helpdesk18');
uis.form('/helpdesk/hd/quiz_set_group_attach','/helpdesk/hd/quiz_set_group_attach','A','A','F','H','M','N',null);






uis.ready('/helpdesk/hd/quiz_set_group_attach','.model.');

commit;
end;
/
