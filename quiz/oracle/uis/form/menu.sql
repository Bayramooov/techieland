set define off
declare
begin
delete md_menus t where t.project_code = 'helpdesk';
delete md_menu_forms t where t.project_code = 'helpdesk';
----------------------------------------------------------------------------------------------------
dbms_output.put_line('==== Menus ====');
uis.menu('helpdesk',1,'Reference',null,'3');
uis.menu('helpdesk',10,'Survey',null,'2');
uis.menu('helpdesk',12,'Main',null,'1');
uis.menu('helpdesk',2,'Main','1',null);
uis.menu('helpdesk',11,'Main','10','1');
uis.menu('helpdesk',13,'admin','12',null);
uis.menu('helpdesk',14,'reports','12',null);
----------------------------------------------------------------------------------------------------
dbms_output.put_line('==== Menu forms ====');
uis.menu_form('helpdesk',2,'/helpdesk/hd/quiz_list',3,'/helpdesk/hd/quiz+add');
uis.menu_form('helpdesk',2,'/helpdesk/hd/quiz_set_group_list',1,'/helpdesk/hd/quiz_set_group+add');
uis.menu_form('helpdesk',2,'/helpdesk/hd/quiz_set_list',2,'/helpdesk/hd/quiz_set+add');
uis.menu_form('helpdesk',11,'/helpdesk/hdf/survey_list',1,null);
uis.menu_form('helpdesk',13,'/core/md/company_list',5,null);
uis.menu_form('helpdesk',13,'/core/md/filial_list',1,null);
uis.menu_form('helpdesk',13,'/core/md/query_executor',3,null);
uis.menu_form('helpdesk',13,'/core/md/role_list',2,null);
uis.menu_form('helpdesk',13,'/core/md/user_list',4,null);
uis.menu_form('helpdesk',14,'/helpdesk/hdr/template_list',1,null);
commit;
end;
/
