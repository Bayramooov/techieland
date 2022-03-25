----------------------------------------------------------------------------------------------------
-- deleted
----------------------------------------------------------------------------------------------------
create table hdr_report_templates(
  company_id                      number(20)          not null,
  report_template_id              number(20)          not null,
  name                            varchar2(300 char)  not null,
  description                     varchar2(300 char),
  state                           varchar2(1)         not null,
  quiz_setting                    varchar2(3000),
  template_setting                clob                not null,
  constraint hdr_report_templates_pk primary key (company_id, report_template_id) using index tablespace GWS_INDEX,
  constraint hdr_report_templates_c1 check (state in ('A', 'P'))
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table hdr_templates(
  company_id                      number(20)          not null,
  template_id                     number(20)          not null,
  name                            varchar2(300 char)  not null,
  description                     varchar2(3000 char),
  template_kind                   varchar2(1)         not null,
  state                           varchar2(1)         not null,
  setting                         clob                not null,
  constraint hdr_templates_pk primary key (company_id, template_id) using index tablespace GWS_INDEX,
  constraint hdr_templates_c1 check (state in ('A', 'P')),
  constraint hdr_templates_c2 check (template_kind in ('F', 'Q', 'D'))
) tablespace GWS_DATA;

comment on column hdr_templates.template_kind is 'across (F)ilials, across (Q)uizs, across (D)ocuments';
