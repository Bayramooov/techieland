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
  -- can have a cost, which can have multiple musab_routes and actions.
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
    
*/
-- --------------------------------------------------------------------------------------------------
-- table of all the routes which can be handled by the server.
-- full url: protocol://host.com/path:action?query=1&query=2
-- `path` is unique and same as the directory architecture and it is the location of its controller file.
-- `path_code` is auto-generated unique identification of the path and its controller (ui_musab571)
-- `access_kind` route either can be open to the public or can be reached only by authentication
-- `grant` grant only filial users or only filial head users or both if the `access_kind` is (A)uth..
-- `state` route can be switch off (passive) for a while when maintenance is on-going by company head users
-- TODO: naming issues with musab_routes and path_code
-- TODO: possibly `musab_routes` & `musab_route_actions` might be joined together
-- --------------------------------------------------------------------------------------------------
create table `musab_routes`(
  `path_code`                     varchar(50)  not null,
  `path`                          varchar(500) not null,
  `access_kind`                   varchar(1)   not null comment '(A)uthentication, (P)ublic',
  `grant`                         varchar(1)   not null comment '(A)ll, filial (H)ead, (F)ilial',
  `state`                         varchar(1)   not null comment '(A)ctive, (P)assive',
  constraint `musab_routes_pk` primary key (`path_code`),
  constraint `musab_routes_u1` unique (`path`)
);

alter table `musab_routes` add constraint `musab_routes_c1` check (`access_kind` in ('A', 'P'));
alter table `musab_routes` add constraint `musab_routes_c2` check (`grant` in ('A', 'H', 'F'));
alter table `musab_routes` add constraint `musab_routes_c3` check (`access_kind` = 'P' and `grant` = 'A');
alter table `musab_routes` add constraint `musab_routes_c4` check (`state` in ('A', 'P'));
alter table `musab_routes` comment 'musab-dev';

-- --------------------------------------------------------------------------------------------------
-- TODO: check (redirect_id <> action_id) in one row
-- --------------------------------------------------------------------------------------------------
create table `musab_route_actions`(
  `action_id`                     int(10) unsigned not null auto_increment,
  `path_code`                     varchar(50)      not null comment 'musab_routes(path_code)',
  `action`                        varchar(100)     not null,
  `action_kind`                   varchar(1)       not null comment '(A)ction, (G)rant, (R)edirect',
  `pass_parameter`                varchar(1)       not null comment '(Y)es, (N)o',
  `redirect_id`                   int(10) unsigned comment 'musab_route_actions(action_id)',
  `state`                         varchar(1)       not null comment '(A)ctive, (P)assive',
  constraint `musab_route_actions_pk` primary key (`action_id`),
  constraint `musab_route_actions_u1` unique (`path_code`, `action`),
  constraint `musab_route_actions_f1` foreign key (`path_code`) references `musab_routes` (`path_code`) on delete cascade,
  constraint `musab_route_actions_f2` foreign key (`redirect_id`) references `musab_route_actions` (`action_id`) on delete set null
);

alter table `musab_route_actions` add constraint `musab_route_actions_c1` check (`action_kind` in ('A', 'G', 'R'));
alter table `musab_route_actions` add constraint `musab_route_actions_c2` check (`pass_parameter` in ('Y', 'N'));
alter table `musab_route_actions` comment 'musab-dev';

/****************************************************************************************************
  -- hirarchial menu items of a project
  menus:
    menu_id
    project_id
    parent_id
    path_code
    route_action_id
  
  
  companies:
    company_id
    code
    state
  
  users:
    company_id
    user_id
    login
    password
  
*/
