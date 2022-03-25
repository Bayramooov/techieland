set define off
prompt PATH /helpdesk/hdr/template_list
begin
uis.route('/helpdesk/hdr/template_list$delete','Ui_Helpdesk37.Del','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdr/template_list:model','Ui.No_Model',null,null,'A','Y',null,null,null);
uis.route('/helpdesk/hdr/template_list:table','Ui_Helpdesk37.Query',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hdr/template_list','helpdesk37');
uis.form('/helpdesk/hdr/template_list','/helpdesk/hdr/template_list','A','A','F','H','M','N',null);



uis.action('/helpdesk/hdr/template_list','add','A','/helpdesk/hdr/template+add','S','O');
uis.action('/helpdesk/hdr/template_list','delete','A',null,null,'A');
uis.action('/helpdesk/hdr/template_list','edit','A','/helpdesk/hdr/template+edit','S','O');
uis.action('/helpdesk/hdr/template_list','open','A','/helpdesk/hdr/report','S','O');



uis.ready('/helpdesk/hdr/template_list','.add.delete.edit.model.open.');

commit;
end;
/
