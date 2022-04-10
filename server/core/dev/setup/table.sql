-- --------------------------------------------------------------------------------------------------
-- Framework tables
-- --------------------------------------------------------------------------------------------------
create table forms(
  form_id                         int(10) unsigned not null auto_increment,
  url                             varchar(250)     not null,
  form_kind                       varchar(1)       not null comment '(A)uth, (P)ublic, (D)ev',
  form_grant                      varchar(1)       comment '(A)ll, company (H)ead, (F)ilial',
  state                           varchar(1)       not null comment '(R)eady, (N)ot ready',
  constraint forms_pk primary key (form_id),
  constraint forms_u1 unique (url)
);

alter table forms add constraint forms_c1 check (form_kind in ('A', 'P', 'D'));
alter table forms add constraint forms_c2 check (form_grant in ('A', 'H', 'F'));
alter table forms add constraint forms_c3 check (form_kind = 'A' and form_grant is not null or (form_kind = 'P' or form_kind = 'D') and form_grant is null);
alter table forms add constraint forms_c4 check (state in ('R', 'N'));
alter table forms comment 'TECHIELAND: list of forms';

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
