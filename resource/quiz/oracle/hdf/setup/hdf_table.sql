prompt HELP_DESK DOCUMENT module
prompt (c) 2020 Greenwhite solutions (www.greenwhite.uz)
----------------------------------------------------------------------------------------------------
create table hdf_surveys(
  company_id                      number(20)           not null,
  survey_id                       number(20)           not null,
  filial_id                       number(20)           not null,  
  quiz_set_group_id               number(20)           not null,
  survey_number                   varchar2(50 char)    not null, 
  survey_date                     date                 not null,
  status                          varchar2(1)          not null,
  note                            varchar2(400 char),
  created_by                      number(20)           not null,
  created_on                      date                 not null,
  modified_by                     number(20)           not null,
  modified_on                     date                 not null,
  constraint hdf_surveys_pk primary key (company_id, survey_id) using index tablespace GWS_INDEX,
  constraint hdf_surveys_f1 foreign key (company_id, quiz_set_group_id) references hd_quiz_set_groups(company_id, quiz_set_group_id),
  constraint hdf_surveys_f2 foreign key (company_id, created_by) references md_persons(company_id, person_id),
  constraint hdf_surveys_f3 foreign key (company_id, modified_by) references md_persons(company_id, person_id),  
  constraint hdf_surveys_c1 check (status in ('D', 'N', 'P', 'C', 'R')),
  constraint hdf_surveys_c2 check (survey_date = trunc(survey_date))
) tablespace GWS_DATA;

comment on column hdf_surveys.status is '(D)raft, (N)ew, (P)rocessing, (C)ompleted, (R)emoved';

----------------------------------------------------------------------------------------------------  
create table hdf_survey_quiz_sets(
  company_id                      number(20)   not null,
  sv_quiz_set_id                  number(20)   not null,
  survey_id                       number(20)   not null,
  quiz_set_id                     number(20)   not null,
  parent_option_id                number(20),
  constraint hdf_survey_quiz_sets_pk primary key (company_id, sv_quiz_set_id) using index tablespace GWS_INDEX,
  constraint hdf_survey_quiz_sets_f1 foreign key (company_id, survey_id) references hdf_surveys(company_id, survey_id),
  constraint hdf_survey_quiz_sets_f2 foreign key (company_id, quiz_set_id) references hd_quiz_sets(company_id, quiz_set_id),
  constraint hdf_survey_quiz_sets_f3 foreign key (company_id, parent_option_id) references hd_quiz_options(company_id, option_id)
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------                   
create table hdf_survey_quizs(
  company_id                      number(20)   not null,
  sv_quiz_id                      number(20)   not null,
  sv_quiz_set_id                  number(20)   not null,
  quiz_id                         number(20)   not null,
  order_no                        number(6)    not null,
  parent_option_id                number(20),
  constraint hdf_survey_quizs_pk primary key (company_id, sv_quiz_id) using index tablespace GWS_INDEX,
  constraint hdf_survey_quizs_f1 foreign key (company_id, sv_quiz_set_id) references hdf_survey_quiz_sets(company_id, sv_quiz_set_id) on delete cascade,
  constraint hdf_survey_quizs_f2 foreign key (company_id, quiz_id) references hd_quizs(company_id, quiz_id),
  constraint hdf_survey_quizs_f3 foreign key (company_id, parent_option_id) references hd_quiz_options(company_id, option_id)
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------               
create table hdf_survey_quiz_answers(
  company_id                      number(20)         not null,
  sv_quiz_unit_id                 number(20)         not null,
  sv_quiz_id                      number(20)         not null,
  option_id                       number(20),
  answer                          varchar2(4000 char) not null,
  constraint hdf_survey_quiz_answers_pk primary key (company_id, sv_quiz_unit_id) using index tablespace GWS_INDEX,
  constraint hdf_survey_quiz_answers_f1 foreign key (company_id, sv_quiz_id) references hdf_survey_quizs(company_id, sv_quiz_id) on delete cascade,
  constraint hdf_survey_quiz_answers_f2 foreign key (company_id, option_id) references hd_quiz_options(company_id, option_id)
) tablespace GWS_DATA;
