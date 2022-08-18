-- create table `musab_sequences`(
--   `name`                          varchar(50)      not null,
--   `index`                         int(10) unsigned not null
--   constraint `musab_sequences_pk` primary key (`name`)
-- );

-- alter table `musab_sequences` comment 'musab-dev: self-made sequences like in the Oracle';

/****************************************************************************************************
  * tables which are commented as 'musab-dev' are only for company head users
  
  projects:
    project_id
    name
    description
    code
    parent_id
    state
  
  -- Modules: one minimal group of functionalities which can be turned ON and OFF, which
  -- can have a cost, which can have multiple musab_route and actions.
  -- The application is tree of modules, child modules sibling modules parent modules... (parent_id)
  modules:
    module_id
    name
    description
    code
    state
  
  -- dependency modules of a module. It can be useful when switch on/off the module, if a parent
  -- module is switched off then all the child modules also will be switched off automatically
  module_dependencies:
    module_id
    dependency_id

****************************************************************************************************/
-- --------------------------------------------------------------------------------------------------
create table `musab_route`(
  `route`                         varchar(500) not null,
  `path`                          varchar(500) not null,
  `mode`                          varchar(50),
  `action`                        varchar(50),
  `route_kind`                    varchar(1)   not null comment '(P)ath, (A)ction, (R)edirect',
  `parent_route`                  varchar(50),
  `function`                      varchar(100),
  `pass_parameter`                varchar(1)   not null comment '(Y)es, (N)o',
  `redirection_route`             varchar(500)          comment 'musab_route(route)',
  `privacy`                       varchar(1)   not null comment '(A)uthentication, (P)ublic',
  `access`                        varchar(1)   not null comment '(A)ll, (H)ead-filial, (F)ilial',
  `grant`                         varchar(1)   not null comment '(Y)es, (N)o',
  `state`                         varchar(1)   not null comment '(A)ctive, (P)assive',
  constraint `musab_route_pk`  primary key (`route`),
  constraint `musab_route_f1`  foreign key (`parent_route`) references `musab_route` (`route`) on delete cascade,
  constraint `musab_route_f2`  foreign key (`redirection_route`) references `musab_route` (`route`) on delete set null,
  constraint `musab_route_c1`  check (`route` = concat(`path`, `mode`, `action`)),
  constraint `musab_route_c2`  check (substr(`mode`, 1, 1) = '+' or `mode` is null),
  constraint `musab_route_c3`  check (`action` is null and `route_kind` = 'P' or `route_kind` in ('A', 'R')),
  constraint `musab_route_c4`  check (`action` is not null and `route_kind` in ('A', 'R') or `route_kind` = 'P'),
  constraint `musab_route_c5`  check ((substr(`action`, 1, 1) = '$' and `grant` = 'Y' or `grant` = 'N') and `route_kind` in ('A', 'R') or `route_kind` = 'P'),
  constraint `musab_route_c6`  check ((substr(`action`, 1, 1) = ':' and `grant` = 'N' or `grant` = 'Y') and `route_kind` in ('A', 'R') or `route_kind` = 'P'),
  constraint `musab_route_c7`  check (`route_kind` in ('P', 'A', 'R')),
  constraint `musab_route_c8`  check (`parent_route` is not null and `route_kind` in ('A', 'R') or `route_kind` = 'P'),
  constraint `musab_route_c9`  check (`parent_route` is null and `route_kind` = 'P' or `route_kind` in ('A', 'R')),
  constraint `musab_route_c10` check (`parent_route` <> `route`),
  constraint `musab_route_c11` check (`function` is not null and `route_kind` = 'A' or `route_kind` in ('P', 'R')),
  constraint `musab_route_c12` check (`function` is null and `route_kind` in ('P', 'R') or `route_kind` = 'A'),
  constraint `musab_route_c13` check (`pass_parameter` in ('Y', 'N')),
  constraint `musab_route_c14` check (`pass_parameter` = 'N' and `function` is null or `function` is not null),
  constraint `musab_route_c15` check (`redirection_route` is null and `route_kind` in ('P', 'A') or `route_kind` = 'R'),
  constraint `musab_route_c16` check (`redirection_route` <> `route`),
  constraint `musab_route_c17` check (`privacy` in ('A', 'P')),
  constraint `musab_route_c18` check (`access` in ('A', 'H', 'F')),
  constraint `musab_route_c19` check (`access` = 'A' and `privacy` = 'P' or `privacy` = 'A'),
  constraint `musab_route_c20` check (`grant` in ('Y', 'N')),
  constraint `musab_route_c21` check (`grant` = 'N' and `privacy` = 'P' or `privacy` = 'A'),
  constraint `musab_route_c22` check (`grant` = 'Y' and `privacy` = 'A' and `route_kind` = 'P' or `privacy` = 'P' or `route_kind` in ('A', 'R')),
  constraint `musab_route_c23` check (`state` in ('A', 'P'))
);

alter table `musab_route` comment 'musab-dev: route';

create index `musab_route_i1` on `musab_route` (`parent_route`);
create index `musab_route_i2` on `musab_route` (`redirection_route`);
-- only `route_kind` = 'P' can have child route and it cannot be child itself
-- parent route (route_kind = P) and model route (route_kind = A, action = ':model') are always gonna be called together
-- if parent route state is passive then all the childrens' state must be passive

-- --------------------------------------------------------------------------------------------------
create table `musab_company`(
  `company_id`                    int(20) unsigned not null,
  `company_code`                  varchar(50)      not null comment 'Company unique identifier',
  `state`                         varchar(1)       not null comment '(A)ctive, (Passive)',
  constraint `musab_company_pk` primary key (`company_id`),
  constraint `musab_company_u1` unique (`company_code`),
  constraint `musab_company_c1` check (`state` in ('A', 'P'))
);

alter table `musab_company` comment 'musab-dev: company';

/****************************************************************************************************
  -- hirarchial menu items of a project
  menus:
    menu_id
    project_id
    parent_id
    path_code
    route_action_id
****************************************************************************************************/

-- --------------------------------------------------------------------------------------------------
create table `musab_user`(
  `company_id`                    int(20) unsigned not null,
  `user_id`                       int(20) unsigned not null,
  `username`                      varchar(50)      not null,
  `password`                      varchar(64)      not null,
  `state`                         varchar(1)       not null comment '(A)ctive, (P)assive',
  constraint `musab_user_pk` primary key (`company_id`, `user_id`),
  constraint `musab_user_u1` unique (`user_id`),
  constraint `musab_user_u2` unique (`company_id`, `username`),
  constraint `musab_user_c1` check (`state` in ('A', 'P'))
);
