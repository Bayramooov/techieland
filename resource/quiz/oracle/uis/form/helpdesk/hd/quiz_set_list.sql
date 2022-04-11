set define off
prompt PATH /helpdesk/hd/quiz_set_list
begin
uis.route('/helpdesk/hd/quiz_set_list$delete','Ui_Helpdesk16.Del','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_list:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_list:table','Ui_Helpdesk16.Query',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_list','helpdesk16');
uis.form('/helpdesk/hd/quiz_set_list','/helpdesk/hd/quiz_set_list','H','A','F','H','M','N',null);



uis.action('/helpdesk/hd/quiz_set_list','add','H','/helpdesk/hd/quiz_set+add','S','O');
uis.action('/helpdesk/hd/quiz_set_list','bind_quizs','H','/helpdesk/hd/quiz_set_binds','S','O');
uis.action('/helpdesk/hd/quiz_set_list','delete','H',null,null,'A');
uis.action('/helpdesk/hd/quiz_set_list','edit','H','/helpdesk/hd/quiz_set+edit','S','O');
uis.action('/helpdesk/hd/quiz_set_list','set_order','H','/helpdesk/hd/quiz_set_binds_set_order','S','O');



uis.ready('/helpdesk/hd/quiz_set_list','.add.bind_quizs.delete.edit.model.set_order.');

commit;
end;
/
