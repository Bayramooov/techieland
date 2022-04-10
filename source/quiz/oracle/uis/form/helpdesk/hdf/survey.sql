set define off
prompt PATH /helpdesk/hdf/survey
begin
uis.route('/helpdesk/hdf/survey+add$save','Ui_Helpdesk24.Add','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+add:get_children','Ui_Helpdesk24.Get_Children','M','M','A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+add:load_quiz_sets','Ui_Helpdesk24.Load_Ref_Quiz_Sets','M','M','A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+add:model','Ui_Helpdesk24.Add_Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hdf/survey+add:table_quiz_set_groups','Ui_Helpdesk24.Query_Quiz_Set_Groups',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+edit$save','Ui_Helpdesk24.Edit','M',null,'A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+edit:get_children','Ui_Helpdesk24.Get_Children','M','M','A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+edit:load_quiz_sets','Ui_Helpdesk24.Load_Ref_Quiz_Sets','M','M','A',null,null,null,null);
uis.route('/helpdesk/hdf/survey+edit:model','Ui_Helpdesk24.Edit_Model','M','M','A','Y',null,null,null);

uis.path('/helpdesk/hdf/survey','helpdesk24');
uis.form('/helpdesk/hdf/survey+add','/helpdesk/hdf/survey','A','A','F','H','M','N',null);
uis.form('/helpdesk/hdf/survey+edit','/helpdesk/hdf/survey','A','A','F','H','M','N',null);



uis.action('/helpdesk/hdf/survey+add','save','A',null,null,'A');
uis.action('/helpdesk/hdf/survey+edit','save','A',null,null,'A');



uis.ready('/helpdesk/hdf/survey+add','.model.save.');
uis.ready('/helpdesk/hdf/survey+edit','.model.save.');

commit;
end;
/
