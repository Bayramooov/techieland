create or replace package Hd_Pref is
  ----------------------------------------------------------------------------------------------------  
  type Option_Quiz_Rt is record(
    Child_Quiz_Id number);
  ----------------------------------------------------------------------------------------------------  
  type Option_Quiz_Nt is table of Option_Quiz_Rt;
  ----------------------------------------------------------------------------------------------------  
  type Option_Quiz_Set_Rt is record(
    Child_Quiz_Set_Id number);
  ----------------------------------------------------------------------------------------------------  
  type Option_Quiz_Set_Nt is table of Option_Quiz_Set_Rt;
  ----------------------------------------------------------------------------------------------------  
  type Option_Rt is record(
    Option_Id number,
    name      varchar2(300 char),
    State     varchar2(1),
    Order_No  number,
    value     varchar2(300 char),
    Quizs     Option_Quiz_Nt,
    Quiz_Sets Option_Quiz_Set_Nt);
  ----------------------------------------------------------------------------------------------------  
  type Option_Nt is table of Option_Rt;
  ----------------------------------------------------------------------------------------------------  
  type Quiz_Rt is record(
    Company_Id      number,
    Quiz_Id         number,
    name            varchar2(300 char),
    State           varchar2(1),
    Data_Kind       varchar2(1),
    Quiz_Kind       varchar2(1),
    Select_Multiple varchar2(1),
    Select_Form     varchar2(1),
    Min_Scale       number,
    Max_Scale       number,
    Is_Required     varchar2(1),
    Options         Option_Nt);
  ----------------------------------------------------------------------------------------------------  
  --quiz data kind
  c_Dk_Number     constant varchar2(1) := 'N';
  c_Dk_Date       constant varchar2(1) := 'D';
  c_Dk_Short_Text constant varchar2(1) := 'S';
  c_Dk_Long_Text  constant varchar2(1) := 'L';
  c_Dk_Boolean    constant varchar2(1) := 'B';

  ----------------------------------------------------------------------------------------------------  
  --quiz_kind
  c_Qk_Manual          constant varchar2(1) := 'M';
  c_Qk_Select          constant varchar2(1) := 'S';
  c_Qk_Select_By_Value constant varchar2(1) := 'V';

  ----------------------------------------------------------------------------------------------------  
  --select form 
  c_Sf_Check_Box    constant varchar2(1) := 'C';
  c_Sf_Radio_Button constant varchar2(1) := 'R';
  c_Sf_Drop_Down    constant varchar2(1) := 'D';
end Hd_Pref;
/
create or replace package body Hd_Pref is

end Hd_Pref;
/
