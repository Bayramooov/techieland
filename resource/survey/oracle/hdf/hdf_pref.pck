create or replace package Hdf_Pref is
  ----------------------------------------------------------------------------------------------------  
  type Survey_Quiz_Answer_Rt is record(
    Sv_Quiz_Unit_Id number,
    Option_Id       number,
    Answer          varchar2(4000 char));
  ----------------------------------------------------------------------------------------------------  
  type Survey_Quiz_Answer_Nt is table of Survey_Quiz_Answer_Rt;
  ----------------------------------------------------------------------------------------------------  
  type Survey_Quiz_Rt is record(
    Sv_Quiz_Id          number,
    Quiz_Id             number,
    Parent_Option_Id    number,
    Survey_Quiz_Answers Survey_Quiz_Answer_Nt);
  ----------------------------------------------------------------------------------------------------  
  type Survey_Quiz_Nt is table of Survey_Quiz_Rt;
  ----------------------------------------------------------------------------------------------------  
  type Survey_Quiz_Set_Rt is record(
    Sv_Quiz_Set_Id   number,
    Quiz_Set_Id      number,
    Parent_Option_Id number,
    Survey_Quizs     Survey_Quiz_Nt);
  ----------------------------------------------------------------------------------------------------  
  type Survey_Quiz_Set_Nt is table of Survey_Quiz_Set_Rt;
  ----------------------------------------------------------------------------------------------------  
  type Survey_Rt is record(
    Company_Id        number,
    Survey_Id         number,
    Filial_Id         number,
    Quiz_Set_Group_Id number,
    Survey_Number     varchar2(50 char),
    Survey_Date       date,
    Status            varchar2(1),
    Note              varchar2(400 char),
    Survey_Quiz_Sets  Survey_Quiz_Set_Nt);
  ----------------------------------------------------------------------------------------------------  
  --survey status;
  c_Ss_Draft      constant varchar2(1) := 'D';
  c_Ss_New        constant varchar2(1) := 'N';
  c_Ss_Processing constant varchar2(1) := 'P';
  c_Ss_Completed  constant varchar2(1) := 'C';
  c_Ss_Removed    constant varchar2(1) := 'R';
end Hdf_Pref;
/
create or replace package body Hdf_Pref is

end Hdf_Pref;
/
