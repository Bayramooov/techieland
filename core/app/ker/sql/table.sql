-- --------------------------------------------------------------------------------------------------
-- Modules: one minimal group of functionalities which can be turned ON and OFF, which
-- can have a cost, which can have multiple forms and actions.
-- The application is tree of modules, child modules sibling modules parent modules... (parent_id)
-- --------------------------------------------------------------------------------------------------
create table modules(
  `module_id`                     int(10) unsigned not null auto_increment,
  `name`                          varchar(50)      not null,
  `description`                   varchar(1000),
  `code`                          varchar(10)      not null,
  `version`                       varchar(10)      not null,
  `required`                      varchar(1)       not null,
  `state`                         varchar(1)       not null comment '(A)ctive, (P)assive',
  constraint modules_pk primary key (module_id),
  constraint modules_u1 unique (code)
);

alter table modules add constraint modules_c1 check (state in ('A', 'P'));
alter table modules comment 'core: list of modules';

-- --------------------------------------------------------------------------------------------------
create table module_dependencies(
  `module_id`                     int(10) unsigned not null,
  `dependency_id`                 int(10) unsigned not null,
  `version`                       varchar(10)      not null,
  constraint module_dependencies_pk primary key (module_id, dependency_id),
  constraint module_dependencies_f1 foreign key (module_id) references modules(module_id),
  constraint module_dependencies_f2 foreign key (dependency_id) references modules(module_id)
);

-- --------------------------------------------------------------------------------------------------
create table forms(
  `form_id`                       int(10) unsigned not null auto_increment,
  `path`                          varchar(250)     not null,
  `form_kind`                     varchar(1)       not null comment '(A)uth, (P)ublic',
  `form_grant`                    varchar(1)       comment '(A)ll, filial (H)ead, (F)ilial',
  `state`                         varchar(1)       not null comment '(R)eady, (N)ot ready',
  constraint forms_pk primary key (form_id),
  constraint forms_u1 unique (url)
);

alter table forms add constraint forms_c1 check (form_kind in ('A', 'P'));
alter table forms add constraint forms_c2 check (form_grant in ('A', 'H', 'F'));
alter table forms add constraint forms_c3 check (form_kind = 'A' and form_grant is not null or (form_kind = 'P' or form_kind = 'D') and form_grant is null);
alter table forms add constraint forms_c4 check (state in ('R', 'N'));
alter table forms comment 'core: list of forms';

-- --------------------------------------------------------------------------------------------------
create table routes(
  route_id                        int(10) unsigned not null auto_increment,
  form_id                         int(10) unsigned not null,
  route                           varchar(250)     not null,
  grantable                       varchar(1)       comment '(Y)es, (No)', -- Is this route can be granted to users ('NO' if form_kind is 'DEV')
  state                           varchar(1)       not null comment '(R)eady, (N)ot ready',
  constraint routes_pk primary key (route_id),
  constraint routes_f1 foreign key (form_id) references forms(form_id) on delete cascade,
  constraint routes_u1 unique (route)
);

alter table routes add constraint routes_c1 check (grantable in ('Y', 'N'));
alter table routes add constraint routes_c2 check (state in ('R', 'N'));
alter table routes comment 'TECHIELAND: list of routes';

-- --------------------------------------------------------------------------------------------------
-- create table companies(
--   company_id                      int(10) unsigned not null auto_increment,
--   is_company_head                 varchar(1)       not null comment '(Y)es, (N)o',
--   company_code                    varchar(10)      not null,
--   state                           varchar(1)       not null comment '(A)ctive, (P)assive',
--   constraint companies_pk primary key (company_id),
--   constraint companies_u1 unique (company_code)
-- );

-- alter table companies add constraint companies_c1 check (is_company_head in ('Y', 'N'));
-- alter table companies add constraint companies_c2 check (state in ('A', 'P'));
-- alter table companies comment 'TECHIELAND: list of companies';
