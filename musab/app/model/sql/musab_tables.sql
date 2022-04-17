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
create table `musab_routes`(
  `route`                         varchar(500) not null,
  `path`                          varchar(500) not null,
  `action`                        varchar(100),
  `route_kind`                    varchar(1)   not null comment '(P)ath, (A)ction, (R)edirect',
  `function`                      varchar(100),
  `pass_parameter`                varchar(1)   not null comment '(Y)es, (N)o',
  `redirect_route`                varchar(500)          comment 'musab_routes(route)',
  `privacy`                       varchar(1)   not null comment '(A)uthentication, (P)ublic',
  `access`                        varchar(1)   not null comment '(A)ll, (H)ead-filial, (F)ilial',
  `grant`                         varchar(1)   not null comment '(Y)es, (N)o',
  `state`                         varchar(1)   not null comment '(A)ctive, (P)assive',
  constraint `musab_routes_pk` primary key (`route`),
  constraint `musab_routes_f1` foreign key (`redirect_route`) references `musab_routes` (`route`)
);

alter table `musab_routes` add constraint `musab_routes_c1`  check (`route` = `path` and `route_kind` in ('P', 'R') or `route_kind` = 'A');
alter table `musab_routes` add constraint `musab_routes_c2`  check (`route` = `path` || ':' || `action` and `grant` = 'N' and `route_kind` = 'A' or `route_kind` in ('P', 'R'));
alter table `musab_routes` add constraint `musab_routes_c3`  check (`route` = `path` || '$' || `action` and `grant` = 'Y' and `route_kind` = 'A' or `route_kind` in ('P', 'R'));
alter table `musab_routes` add constraint `musab_routes_c4`  check (`route_kind` in ('P', 'A', 'R'));
alter table `musab_routes` add constraint `musab_routes_c5`  check (`function` is not null and `route_kind` = 'A' or `function` is null and `route_kind` in ('P', 'R'));
alter table `musab_routes` add constraint `musab_routes_c6`  check (`pass_parameter` in ('Y', 'N'));
alter table `musab_routes` add constraint `musab_routes_c7`  check (`pass_parameter` = 'N' and `function` is null or `function` is not null);
alter table `musab_routes` add constraint `musab_routes_c8`  check (`redirect_route` is not null and `route_kind` = 'R' or `redirect_route` is null and `route_kind` in ('P', 'R'));
alter table `musab_routes` add constraint `musab_routes_c8`  check (`redirect_route` <> `route`);
alter table `musab_routes` add constraint `musab_routes_c9`  check (`privacy` in ('A', 'P'));
alter table `musab_routes` add constraint `musab_routes_c10` check (`access` in ('A', 'H', 'F'));
alter table `musab_routes` add constraint `musab_routes_c11` check (`access` = 'A' and `privacy` = 'P' or `privacy` = 'A');
alter table `musab_routes` add constraint `musab_routes_c12` check (`grant` in ('Y', 'N'));
alter table `musab_routes` add constraint `musab_routes_c13` check (`grant` = 'N' and `privacy` = 'P' or `privacy` = 'A');
alter table `musab_routes` add constraint `musab_routes_c14` check (`state` in ('A', 'P'));

alter table `musab_routes` comment 'musab-dev';


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
