set define off
prompt PATH /helpdesk/hd/quiz_set_group_list
begin
uis.route('/helpdesk/hd/quiz_set_group_list$delete','Ui_Helpdesk12.Del','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_set_group_list:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_set_group_list:table','Ui_Helpdesk12.Query',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_set_group_list','helpdesk12');
uis.form('/helpdesk/hd/quiz_set_group_list','/helpdesk/hd/quiz_set_group_list','H','A','F','H','M','N',null);



uis.action('/helpdesk/hd/quiz_set_group_list','add','H','/helpdesk/hd/quiz_set_group+add','S','O');
uis.action('/helpdesk/hd/quiz_set_group_list','bind_quiz_sets','H','/helpdesk/hd/quiz_set_group_binds','S','O');
uis.action('/helpdesk/hd/quiz_set_group_list','delete','H',null,null,'A');
uis.action('/helpdesk/hd/quiz_set_group_list','edit','H','/helpdesk/hd/quiz_set_group+edit','S','O');
uis.action('/helpdesk/hd/quiz_set_group_list','set_order_no','H','/helpdesk/hd/quiz_set_group_binds_set_order','S','O');



uis.ready('/helpdesk/hd/quiz_set_group_list','.add.bind_quiz_sets.delete.edit.model.set_order_no.');

commit;
end;
/
