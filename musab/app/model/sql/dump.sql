-- inserting into ROUTES
-- (route, path, action, route_kind, function, pass_parameter, redirect_route, privacy, access, grant, state)
insert into `musab_routes` values ('/musab/route+add', '/musab/route', '', 'P', '', 'N', '', 'P', 'A', 'N', 'A');
insert into `musab_routes` values ('/musab/route+add:model', '/musab/route', 'model', 'A', 'add_model', 'Y', '', 'P', 'A', 'N', 'A');

insert into `musab_routes` values ('/musab/route+edit', '/musab/route', '', 'P', '', 'N', '', 'P', 'A', 'N', 'A');
insert into `musab_routes` values ('/musab/route+edit:model', '/musab/route', 'model', 'A', 'edit_model', 'Y', '', 'P', 'A', 'N', 'A');

insert into `musab_routes` values ('/musab/route_list', '/musab/route_list', '', 'P', '', 'N', '', 'P', 'A', 'N', 'A');
insert into `musab_routes` values ('/musab/route_list:model', '/musab/route_list', 'model', 'A', 'model', 'N', '', 'P', 'A', 'N', 'A');
insert into `musab_routes` values ('/musab/route_list:add', '/musab/route_list', 'add', 'R', '', 'N', '/musab/route+add', 'P', 'A', 'N', 'A');
insert into `musab_routes` values ('/musab/route_list:edit', '/musab/route_list', 'edit', 'R', '', 'N', '/musab/route+edit', 'P', 'A', 'N', 'A');
