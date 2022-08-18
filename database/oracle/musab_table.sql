prompt Musab
prompt (c) 2022 Techieland LLC (www.techieland.uz)

----------------------------------------------------------------------------------------------------
create table musab_route(
  route                         varchar2(500) not null,
  path                          varchar2(500) not null,
  mode                          varchar2(50),
  action                        varchar2(50),
  route_kind                    varchar2(1)   not null,
  parent_route                  varchar2(50),
  function                      varchar2(100),
  pass_parameter                varchar2(1)   not null,
  redirection_route             varchar2(500),
  privacy                       varchar2(1)   not null,
  route_access                  varchar2(1)   not null,
  route_grant                   varchar2(1)   not null,
  state                         varchar2(1)   not null,
  constraint musab_route_pk  primary key (route),
  constraint musab_route_f1  foreign key (parent_route) references musab_route (route) on delete cascade,
  constraint musab_route_f2  foreign key (redirection_route) references musab_route (route) on delete set null,
  constraint musab_route_c1  check (route = path || mode || action),
  constraint musab_route_c2  check (substr(mode, 1, 1) = '+' or mode is null),
  constraint musab_route_c3  check (action is null and route_kind = 'P' or route_kind in ('A', 'R')),
  constraint musab_route_c4  check (action is not null and route_kind in ('A', 'R') or route_kind = 'P'),
  constraint musab_route_c5  check ((substr(action, 1, 1) = '$' and route_grant = 'Y' or route_grant = 'N') and route_kind in ('A', 'R') or route_kind = 'P'),
  constraint musab_route_c6  check ((substr(action, 1, 1) = ':' and route_grant = 'N' or route_grant = 'Y') and route_kind in ('A', 'R') or route_kind = 'P'),
  constraint musab_route_c7  check (route_kind in ('P', 'A', 'R')),
  constraint musab_route_c8  check (parent_route is not null and route_kind in ('A', 'R') or route_kind = 'P'),
  constraint musab_route_c9  check (parent_route is null and route_kind = 'P' or route_kind in ('A', 'R')),
  constraint musab_route_c10 check (parent_route <> route),
  constraint musab_route_c11 check (function is not null and route_kind = 'A' or route_kind in ('P', 'R')),
  constraint musab_route_c12 check (function is null and route_kind in ('P', 'R') or route_kind = 'A'),
  constraint musab_route_c13 check (pass_parameter in ('Y', 'N')),
  constraint musab_route_c14 check (pass_parameter = 'N' and function is null or function is not null),
  constraint musab_route_c15 check (redirection_route is null and route_kind in ('P', 'A') or route_kind = 'R'),
  constraint musab_route_c16 check (redirection_route <> route),
  constraint musab_route_c17 check (privacy in ('A', 'P')),
  constraint musab_route_c18 check (route_access in ('A', 'H', 'F')),
  constraint musab_route_c19 check (route_access = 'A' and privacy = 'P' or privacy = 'A'),
  constraint musab_route_c20 check (route_grant in ('Y', 'N')),
  constraint musab_route_c21 check (route_grant = 'N' and privacy = 'P' or privacy = 'A'),
  constraint musab_route_c22 check (route_grant = 'Y' and privacy = 'A' and route_kind = 'P' or privacy = 'P' or route_kind in ('A', 'R')),
  constraint musab_route_c23 check (state in ('A', 'P'))
);

comment on table musab_route is 'musab-dev: route';

comment on column musab_route.route_kind is '(P)ath, (A)ction, (R)edirect';
comment on column musab_route.pass_parameter is '(Y)es, (N)o';
comment on column musab_route.redirection_route is 'musab_route(route)';
comment on column musab_route.privacy is '(A)uthentication, (P)ublic';
comment on column musab_route.route_access is '(A)ll, (H)ead-filial, (F)ilial';
comment on column musab_route.route_grant is '(Y)es, (N)o';
comment on column musab_route.state is '(A)ctive, (P)assive';

create index musab_route_i1 on musab_route (parent_route);
create index musab_route_i2 on musab_route (redirection_route);

----------------------------------------------------------------------------------------------------
-- TEMP
----------------------------------------------------------------------------------------------------
create table musab_test(
  company_id                      number(20)         not null,
  medicine_form_item_id           number(20)         not null,
  medicine_form_id                number(20)         not null,
  name_ru                         varchar2(200 char) not null,
  name_uz                         varchar2(200 char) not null,
  name_en                         varchar2(200 char) not null,
  name_latin                      varchar2(200 char),
  state                           varchar2(1)        not null,
  order_no                        number(6),
  pcode                           varchar2(20),
  constraint musab_test_pk primary key (company_id, medicine_form_item_id),
  constraint musab_test_u1 unique (medicine_form_item_id),
  constraint musab_test_u2 unique (company_id, medicine_form_item_id, medicine_form_id),
  constraint musab_test_c1 check (decode(name_ru, trim(name_ru), 1, 0) = 1),
  constraint musab_test_c2 check (decode(name_uz, trim(name_uz), 1, 0) = 1),
  constraint musab_test_c3 check (decode(name_en, trim(name_en), 1, 0) = 1),
  constraint musab_test_c4 check (decode(name_latin, trim(name_latin), 1, 0) = 1),
  constraint musab_test_c5 check (state in ('A', 'P'))
);
