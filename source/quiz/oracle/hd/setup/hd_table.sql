----------------------------------------------------------------------------------------------------  
create table hd_quiz_sets(
   company_id                      number(20)         not null,
   quiz_set_id                     number(20)         not null,
   name                            varchar2(300 char) not null,
   state                           varchar2(1)        not null,
   description                     varchar2(300 char),
   constraint hd_quiz_sets_pk primary key (company_id, quiz_set_id) using index tablespace GWS_INDEX,
   constraint hd_quiz_sets_u2 unique (quiz_set_id) using index tablespace GWS_INDEX, 
   constraint hd_quiz_sets_u1 unique (company_id, name) using index tablespace GWS_INDEX, 
   constraint hd_quiz_sets_c1 check (state in ('A', 'P'))
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------  
create table hd_quizs(
  company_id                      number(20)         not null,
  quiz_id                         number(20)         not null,
  name                            varchar2(300 char) not null,
  state                           varchar2(1)        not null,
  data_kind                       varchar2(1)        not null,
  quiz_kind                       varchar2(1)        not null,  
  select_multiple                 varchar2(1),
  select_form                     varchar2(1),
  min_scale                       number(20),
  max_scale                       number(20),
  is_required                     varchar2(1)        not null,
  constraint hd_quizs_pk primary key (company_id, quiz_id) using index tablespace GWS_INDEX,
  constraint hd_quizs_u1 unique (quiz_id) using index tablespace GWS_INDEX,
  constraint hd_quizs_c1 check (state in ('A', 'P')),
  constraint hd_quizs_c2 check (data_kind in ('N', 'D', 'S', 'L', 'B')),
  constraint hd_quizs_c3 check (quiz_kind in ('M', 'S', 'V')),
  constraint hd_quizs_c4 check (select_multiple in ('Y', 'N')),
  constraint hd_quizs_c5 check (select_form in ('C', 'R', 'D')),
  constraint hd_quizs_c6 check (quiz_kind = 'M' and select_multiple is null and select_form is null or quiz_kind in ('S', 'V') and select_multiple is not null and select_form is not null),
  constraint hd_quizs_c7 check (select_multiple = 'Y' and select_form in ('C', 'D') or select_multiple = 'N' and select_form in ('C', 'R', 'D')),  
  constraint hd_quizs_c8 check (max_scale > min_scale),
  constraint hd_quizs_c9 check(is_required in ('Y','N'))
) tablespace GWS_DATA;

comment on column hd_quizs.state is '(A)ctive, (P)assive';
comment on column hd_quizs.data_kind is '(N)umber, (D)ate, (S)short Text, (L)ong Text, (B)oolean';
comment on column hd_quizs.quiz_kind is '(M)anual, (S)elect, Select by (V)alue';
comment on column hd_quizs.select_multiple is '(Y)es, (N)o';
comment on column hd_quizs.select_form is '(C)heck-box, (R)adio-button, (D)rop-down';

----------------------------------------------------------------------------------------------------
create table hd_quiz_options(
  company_id                      number(20)          not null,
  option_id                       number(20)          not null,
  quiz_id                         number(20)          not null,
  name                            varchar2(4000 char) not null,
  state                           varchar2(1)         not null,
  order_no                        number(6)           not null,
  value                           varchar2(300 char),
  constraint hd_quiz_options_pk primary key (company_id, option_id) using index tablespace GWS_INDEX,
  constraint hd_quiz_options_f1 foreign key (company_id, quiz_id) references hd_quizs(company_id, quiz_id) on delete cascade,
  constraint hd_quiz_options_c1 check(state in ('A', 'P'))  
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table hd_quiz_set_binds(
  company_id                      number(20) not null,
  quiz_set_id                     number(20) not null,
  quiz_id                         number(20) not null,
  order_no                        number(6),
  constraint hd_quiz_set_binds_pk primary key (company_id, quiz_set_id, quiz_id) using index tablespace GWS_INDEX,
  constraint hd_quiz_set_binds_f1 foreign key (company_id, quiz_set_id) references hd_quiz_sets(company_id, quiz_set_id),   
  constraint hd_quiz_set_binds_f2 foreign key  (company_id, quiz_id) references hd_quizs(company_id, quiz_id)
) tablespace GWS_DATA;