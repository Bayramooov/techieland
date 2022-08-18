-- inserting into ROUTE
-- (route, path, mode, action, route_kind, parent_route, function, pass_parameter, redirection_route, privacy, access, grant, state)
insert into `musab_route` values ('/musab/route+add', '/musab/route', '+add', null, 'P', null, null, 'N', null, 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route+add:model', '/musab/route', '+add', ':model', 'A', '/musab/route+add', 'add_model', 'Y', null, 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route+add:save', '/musab/route', '+add', ':save', 'A', '/musab/route+add', 'add', 'Y', null, 'P', 'A', 'N', 'A');

insert into `musab_route` values ('/musab/route+edit', '/musab/route', '+edit', null, 'P', null, null, 'N', null, 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route+edit:model', '/musab/route', '+edit', ':model', 'A', '/musab/route+edit', 'edit_model', 'Y', null, 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route+edit:save', '/musab/route', '+edit', ':save', 'A', '/musab/route+edit', 'add', 'Y', null, 'P', 'A', 'N', 'A');

insert into `musab_route` values ('/musab/route_list', '/musab/route_list', null, null, 'P', null, null, 'N', null, 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route_list:model', '/musab/route_list', null, ':model', 'A', '/musab/route_list', 'model', 'N', null, 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route_list:add', '/musab/route_list', null, ':add', 'R', '/musab/route_list', null, 'N', '/musab/route+add', 'P', 'A', 'N', 'A');
insert into `musab_route` values ('/musab/route_list:edit', '/musab/route_list', null, ':edit', 'R', '/musab/route_list', null, 'N', '/musab/route+edit', 'P', 'A', 'N', 'A');

-- inserting into COMPANY
-- (company_id, company_code, state)
insert into `musab_company` values (0, 'head', 'A');
insert into `musab_company` values (1, 'musab', 'A');

-- inserting into USER
-- (company_id, user_id, username, password, state)
insert into `musab_user` values (0, 0, 'admin', '123', 'A');
insert into `musab_user` values (1, 1, 'admin', '123', 'A');
