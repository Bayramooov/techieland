create or replace package Hdf_Util is
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Answer_New
  (
    o_Survey_Quiz_Answer out nocopy Hdf_Pref.Survey_Quiz_Answer_Rt,
    i_Sv_Quiz_Unit_Id    number,
    i_Option_Id          number,
    i_Answer             varchar2
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Add_Answer
  (
    o_Survey_Quiz        in out nocopy Hdf_Pref.Survey_Quiz_Rt,
    i_Survey_Quiz_Answer Hdf_Pref.Survey_Quiz_Answer_Rt
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_New
  (
    o_Survey_Quiz      out nocopy Hdf_Pref.Survey_Quiz_Rt,
    i_Sv_Quiz_Id       number,
    i_Quiz_Id          number,
    i_Parent_Option_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Set_Add_Quiz
  (
    o_Survey_Quiz_Set in out nocopy Hdf_Pref.Survey_Quiz_Set_Rt,
    i_Survey_Quiz     Hdf_Pref.Survey_Quiz_Rt
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Set_New
  (
    o_Survey_Quiz_Set  out nocopy Hdf_Pref.Survey_Quiz_Set_Rt,
    i_Sv_Quiz_Set_Id   number,
    i_Quiz_Set_Id      number,
    i_Parent_Option_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Add_Quiz_Set
  (
    o_Survey          in out nocopy Hdf_Pref.Survey_Rt,
    i_Survey_Quiz_Set Hdf_Pref.Survey_Quiz_Set_Rt
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_New
  (
    o_Survey            out nocopy Hdf_Pref.Survey_Rt,
    i_Company_Id        number,
    i_Survey_Id         number,
    i_Filial_Id         number,
    i_Quiz_Set_Group_Id number,
    i_Survey_Number     varchar2,
    i_Survey_Date       date,
    i_Status            varchar2,
    i_Note              varchar2
  );
end Hdf_Util;
/
create or replace package body Hdf_Util is
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Answer_New
  (
    o_Survey_Quiz_Answer out nocopy Hdf_Pref.Survey_Quiz_Answer_Rt,
    i_Sv_Quiz_Unit_Id    number,
    i_Option_Id          number,
    i_Answer             varchar2
  ) is
  begin
    o_Survey_Quiz_Answer.Sv_Quiz_Unit_Id := i_Sv_Quiz_Unit_Id;
    o_Survey_Quiz_Answer.Option_Id       := i_Option_Id;
    o_Survey_Quiz_Answer.Answer          := i_Answer;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Add_Answer
  (
    o_Survey_Quiz        in out nocopy Hdf_Pref.Survey_Quiz_Rt,
    i_Survey_Quiz_Answer Hdf_Pref.Survey_Quiz_Answer_Rt
  ) is
  begin
    o_Survey_Quiz.Survey_Quiz_Answers.Extend;
    o_Survey_Quiz.Survey_Quiz_Answers(o_Survey_Quiz.Survey_Quiz_Answers.Count) := i_Survey_Quiz_Answer;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_New
  (
    o_Survey_Quiz      out nocopy Hdf_Pref.Survey_Quiz_Rt,
    i_Sv_Quiz_Id       number,
    i_Quiz_Id          number,
    i_Parent_Option_Id number
  ) is
  begin
    o_Survey_Quiz.Sv_Quiz_Id       := i_Sv_Quiz_Id;
    o_Survey_Quiz.Quiz_Id          := i_Quiz_Id;
    o_Survey_Quiz.Parent_Option_Id := i_Parent_Option_Id;
  
    o_Survey_Quiz.Survey_Quiz_Answers := Hdf_Pref.Survey_Quiz_Answer_Nt();
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Set_Add_Quiz
  (
    o_Survey_Quiz_Set in out nocopy Hdf_Pref.Survey_Quiz_Set_Rt,
    i_Survey_Quiz     Hdf_Pref.Survey_Quiz_Rt
  ) is
  begin
    o_Survey_Quiz_Set.Survey_Quizs.Extend;
    o_Survey_Quiz_Set.Survey_Quizs(o_Survey_Quiz_Set.Survey_Quizs.Count) := i_Survey_Quiz;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Set_New
  (
    o_Survey_Quiz_Set  out nocopy Hdf_Pref.Survey_Quiz_Set_Rt,
    i_Sv_Quiz_Set_Id   number,
    i_Quiz_Set_Id      number,
    i_Parent_Option_Id number
  ) is
  begin
    o_Survey_Quiz_Set.Sv_Quiz_Set_Id   := i_Sv_Quiz_Set_Id;
    o_Survey_Quiz_Set.Quiz_Set_Id      := i_Quiz_Set_Id;
    o_Survey_Quiz_Set.Parent_Option_Id := i_Parent_Option_Id;
  
    o_Survey_Quiz_Set.Survey_Quizs := Hdf_Pref.Survey_Quiz_Nt();
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Add_Quiz_Set
  (
    o_Survey          in out nocopy Hdf_Pref.Survey_Rt,
    i_Survey_Quiz_Set Hdf_Pref.Survey_Quiz_Set_Rt
  ) is
  begin
    o_Survey.Survey_Quiz_Sets.Extend;
    o_Survey.Survey_Quiz_Sets(o_Survey.Survey_Quiz_Sets.Count) := i_Survey_Quiz_Set;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_New
  (
    o_Survey            out nocopy Hdf_Pref.Survey_Rt,
    i_Company_Id        number,
    i_Survey_Id         number,
    i_Filial_Id         number,
    i_Quiz_Set_Group_Id number,
    i_Survey_Number     varchar2,
    i_Survey_Date       date,
    i_Status            varchar2,
    i_Note              varchar2
  ) is
  begin
    o_Survey.Company_Id        := i_Company_Id;
    o_Survey.Survey_Id         := i_Survey_Id;
    o_Survey.Filial_Id         := i_Filial_Id;
    o_Survey.Quiz_Set_Group_Id := i_Quiz_Set_Group_Id;
    o_Survey.Survey_Number     := i_Survey_Number;
    o_Survey.Survey_Date       := i_Survey_Date;
    o_Survey.Status            := i_Status;
    o_Survey.Note              := i_Note;
  
    o_Survey.Survey_Quiz_Sets := Hdf_Pref.Survey_Quiz_Set_Nt();
  end;

end Hdf_Util;
/
