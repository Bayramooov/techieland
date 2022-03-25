set define off
prompt PATH /helpdesk/hd/quiz_list
begin
uis.route('/helpdesk/hd/quiz_list$delete','Ui_Helpdesk7.Del','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hd/quiz_list:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz_list:table','Ui_Helpdesk7.Query',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz_list','helpdesk7');
uis.form('/helpdesk/hd/quiz_list','/helpdesk/hd/quiz_list','H','A','F','HM','M','N',null);



uis.action('/helpdesk/hd/quiz_list','add','H','/helpdesk/hd/quiz+add','S','O');
uis.action('/helpdesk/hd/quiz_list','delete','H',null,null,'A');
uis.action('/helpdesk/hd/quiz_list','edit','H','/helpdesk/hd/quiz+edit','S','O');



uis.ready('/helpdesk/hd/quiz_list','.add.delete.edit.model.');

commit;
end;
/
