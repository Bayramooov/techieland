create or replace type Array_Number force is table of number;
create or replace type Matrix_Number force is table of Array_Number not null;

create or replace type Array_Varchar2 force is table of Varchar2(32767);
create or replace type Matrix_Varchar2 force is table of Array_Varchar2 not null;
