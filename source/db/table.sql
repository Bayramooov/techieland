create table regions(
  company_id                      number(20)         not null,
  region_id                       number(20)         not null,
  name                            varchar2(100 char) not null,
  constraint regions_pk primary key (company_id, region_id) using index tablespace GWS_INDEX,
  constraint regions_pk unique key (region_id) using index tablespace GWS_INDEX,
  constraint regions_c1 check (decode(name, trim(name), 1, 0) = 1)
) tablespace GWS_DATA;
