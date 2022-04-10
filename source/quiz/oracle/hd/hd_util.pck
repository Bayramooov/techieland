create or replace package Hd_Util is
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Quiz_New
  (
    o_Option_Quiz   out nocopy Hd_Pref.Option_Quiz_Rt,
    i_Child_Quiz_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Add_Child_Quiz
  (
    o_Option      in out nocopy Hd_Pref.Option_Rt,
    i_Option_Quiz Hd_Pref.Option_Quiz_Rt
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Quiz_Set_New
  (
    o_Option_Quiz_Set   out nocopy Hd_Pref.Option_Quiz_Set_Rt,
    i_Child_Quiz_Set_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Add_Child_Quiz_Set
  (
    o_Option          in out nocopy Hd_Pref.Option_Rt,
    i_Option_Quiz_Set Hd_Pref.Option_Quiz_Set_Rt
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_New
  (
    o_Option    out nocopy Hd_Pref.Option_Rt,
    i_Option_Id number,
    i_Name      varchar2,
    i_State     varchar2,
    i_Order_No  number,
    i_Value     varchar2
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Add_Option
  (
    o_Quiz   in out nocopy Hd_Pref.Quiz_Rt,
    i_Option Hd_Pref.Option_Rt
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_New
  (
    o_Quiz            out nocopy Hd_Pref.Quiz_Rt,
    i_Company_Id      number,
    i_Quiz_Id         number,
    i_Name            varchar2,
    i_State           varchar2,
    i_Data_Kind       varchar2,
    i_Quiz_Kind       varchar2,
    i_Select_Multiple varchar2,
    i_Select_Form     varchar2,
    i_Min_Scale       varchar2,
    i_Max_Scale       varchar2,
    i_Is_Required     varchar2
  );
end Hd_Util;
/
create or replace package body Hd_Util is
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Quiz_New
  (
    o_Option_Quiz   out nocopy Hd_Pref.Option_Quiz_Rt,
    i_Child_Quiz_Id number
  ) is
  begin
    o_Option_Quiz.Child_Quiz_Id := i_Child_Quiz_Id;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Add_Child_Quiz
  (
    o_Option      in out nocopy Hd_Pref.Option_Rt,
    i_Option_Quiz Hd_Pref.Option_Quiz_Rt
  ) is
  begin
    o_Option.Quizs.Extend;
    o_Option.Quizs(o_Option.Quizs.Count) := i_Option_Quiz;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Quiz_Set_New
  (
    o_Option_Quiz_Set   out nocopy Hd_Pref.Option_Quiz_Set_Rt,
    i_Child_Quiz_Set_Id number
  ) is
  begin
    o_Option_Quiz_Set.Child_Quiz_Set_Id := i_Child_Quiz_Set_Id;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Add_Child_Quiz_Set
  (
    o_Option          in out nocopy Hd_Pref.Option_Rt,
    i_Option_Quiz_Set Hd_Pref.Option_Quiz_Set_Rt
  ) is
  begin
    o_Option.Quiz_Sets.Extend;
    o_Option.Quiz_Sets(o_Option.Quiz_Sets.Count) := i_Option_Quiz_Set;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Option_New
  (
    o_Option    out nocopy Hd_Pref.Option_Rt,
    i_Option_Id number,
    i_Name      varchar2,
    i_State     varchar2,
    i_Order_No  number,
    i_Value     varchar2
  ) is
  begin
    o_Option.Option_Id := i_Option_Id;
    o_Option.Name      := i_Name;
    o_Option.State     := i_State;
    o_Option.Order_No  := i_Order_No;
    o_Option.Value     := i_Value;
  
    o_Option.Quizs     := Hd_Pref.Option_Quiz_Nt();
    o_Option.Quiz_Sets := Hd_Pref.Option_Quiz_Set_Nt();
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Add_Option
  (
    o_Quiz   in out nocopy Hd_Pref.Quiz_Rt,
    i_Option Hd_Pref.Option_Rt
  ) is
  begin
    o_Quiz.Options.Extend;
    o_Quiz.Options(o_Quiz.Options.Count) := i_Option;
  
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_New
  (
    o_Quiz            out nocopy Hd_Pref.Quiz_Rt,
    i_Company_Id      number,
    i_Quiz_Id         number,
    i_Name            varchar2,
    i_State           varchar2,
    i_Data_Kind       varchar2,
    i_Quiz_Kind       varchar2,
    i_Select_Multiple varchar2,
    i_Select_Form     varchar2,
    i_Min_Scale       varchar2,
    i_Max_Scale       varchar2,
    i_Is_Required     varchar2
  ) is
  begin
    o_Quiz.Company_Id      := i_Company_Id;
    o_Quiz.Quiz_Id         := i_Quiz_Id;
    o_Quiz.Name            := i_Name;
    o_Quiz.State           := i_State;
    o_Quiz.Data_Kind       := i_Data_Kind;
    o_Quiz.Quiz_Kind       := i_Quiz_Kind;
    o_Quiz.Select_Multiple := i_Select_Multiple;
    o_Quiz.Select_Form     := i_Select_Form;
    o_Quiz.Min_Scale       := i_Min_Scale;
    o_Quiz.Max_Scale       := i_Max_Scale;
    o_Quiz.Is_Required     := i_Is_Required;
  
    o_Quiz.Options := Hd_Pref.Option_Nt();
  end;

end Hd_Util;
/
