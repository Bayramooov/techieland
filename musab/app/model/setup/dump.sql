-- musab_routes
insert into `musab_routes` (`path_code`, `path`, `access_kind`, `grant`, `state`) values ('ui_musab1', '/musab/route', 'P', 'A', 'A');
insert into `musab_routes` (`path_code`, `path`, `access_kind`, `grant`, `state`) values ('ui_musab2', '/musab/route_list', 'P', 'A', 'A');
insert into `musab_routes` (`path_code`, `path`, `access_kind`, `grant`, `state`) values ('ui_musab3', '/musab/route_view', 'P', 'A', 'A');

-- inserting into ROUTES
insert into `musab_route_actions` (`path_code`, `action`, `action_kind`, `pass_parameter`, `state`) values ('ui_musab1', 'add_model', 'A', 'N', 'A');
insert into `musab_route_actions` (`path_code`, `action`, `action_kind`, `pass_parameter`, `state`) values ('ui_musab1', 'edit_model', 'A', 'Y', 'A');

insert into `musab_route_actions` (`path_code`, `action`, `action_kind`, `pass_parameter`, `state`) values ('ui_musab2', 'model', 'A', 'N', 'A');
insert into `musab_route_actions` (`path_code`, `action`, `action_kind`, `pass_parameter`, `state`) values ('ui_musab2', 'delete', 'A', 'Y', 'A');

insert into `musab_route_actions` (`path_code`, `action`, `action_kind`, `pass_parameter`, `state`) values ('ui_musab3', 'model', 'A', 'Y', 'A');
