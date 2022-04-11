-- inserting into FORMS
insert into forms (url, form_kind, state) values ('/core/dev/form_list', 'D', 'R');
insert into forms (url, form_kind, state) values ('/core/dev/form', 'D', 'R');
insert into forms (url, form_kind, state) values ('/core/dev/route_list', 'D', 'R');
insert into forms (url, form_kind, state) values ('/core/dev/route', 'D', 'R');

insert into forms (url, form_kind, state) values ('/hospital/thp/person_list', 'P', 'R');

-- inserting into ROUTES
insert into routes (form_id, route, grantable, state) values (1, '/core/dev/form_list', 'N', 'R');
insert into routes (form_id, route, grantable, state) values (2, '/core/dev/form+add', 'N', 'R');
insert into routes (form_id, route, grantable, state) values (3, '/core/dev/form+edit', 'N', 'R');
insert into routes (form_id, route, grantable, state) values (3, '/core/dev/route_list', 'N', 'R');
insert into routes (form_id, route, grantable, state) values (4, '/core/dev/route+add', 'N', 'R');
insert into routes (form_id, route, grantable, state) values (4, '/core/dev/route+edit', 'N', 'R');
