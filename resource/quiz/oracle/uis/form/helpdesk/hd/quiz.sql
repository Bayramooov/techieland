set define off
prompt PATH /helpdesk/hd/quiz
begin
uis.route('/helpdesk/hd/quiz+add:model','Ui_Helpdesk14.Add_Model',null,'M','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz+add:save','Ui_Helpdesk14.Add','M','M','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz+add:table_quiz_sets','Ui_Helpdesk14.Quiz_Sets_Query',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz+add:table_quizs','Ui_Helpdesk14.Quizs_Query',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz+edit:model','Ui_Helpdesk14.Edit_Model','M','M','A','Y',null,null,null);
uis.route('/helpdesk/hd/quiz+edit:save','Ui_Helpdesk14.Edit','M','M','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz+edit:table_quiz_sets','Ui_Helpdesk14.Quiz_Sets_Query',null,'Q','A',null,null,null,null);
uis.route('/helpdesk/hd/quiz+edit:table_quizs','Ui_Helpdesk14.Quizs_Query',null,'Q','A',null,null,null,null);

uis.path('/helpdesk/hd/quiz','helpdesk14');
uis.form('/helpdesk/hd/quiz+add','/helpdesk/hd/quiz','H','A','F','H','M','N',null);
uis.form('/helpdesk/hd/quiz+edit','/helpdesk/hd/quiz','H','A','F','H','M','N',null);



uis.action('/helpdesk/hd/quiz+add','add_child_quiz','H','/helpdesk/hd/quiz+add','S','O');
uis.action('/helpdesk/hd/quiz+add','add_quiz','H','/helpdesk/hd/quiz+add','D','O');
uis.action('/helpdesk/hd/quiz+add','add_quiz_set','H','/helpdesk/hd/quiz_set+add','D','O');
uis.action('/helpdesk/hd/quiz+add','select_quiz','H','/helpdesk/hd/quiz_list','D','O');
uis.action('/helpdesk/hd/quiz+add','select_quiz_set','H','/helpdesk/hd/quiz_set_list','D','O');
uis.action('/helpdesk/hd/quiz+edit','add_quiz','H','/helpdesk/hd/quiz+add','D','O');
uis.action('/helpdesk/hd/quiz+edit','add_quiz_set','H','/helpdesk/hd/quiz_set+add','D','O');
uis.action('/helpdesk/hd/quiz+edit','select_quiz','H','/helpdesk/hd/quiz_list','D','O');
uis.action('/helpdesk/hd/quiz+edit','select_quiz_set','H','/helpdesk/hd/quiz_set_list','D','O');



uis.ready('/helpdesk/hd/quiz+edit','.add_quiz.add_quiz_set.model.select_quiz.select_quiz_set.');
uis.ready('/helpdesk/hd/quiz+add','.add_child_quiz.add_quiz.add_quiz_set.model.select_quiz.select_quiz_set.');

commit;
end;
/
