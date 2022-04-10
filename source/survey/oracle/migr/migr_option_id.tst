PL/SQL Developer Test script 3.0
94
-- create table old_Hdf_Survey_Quiz_Answers as (select * from Hdf_Survey_Quiz_Answers);
declare
  r_Answer Hdf_Survey_Quiz_Answers%rowtype;
  ----------------
  Function Get_Option_Id
  (
    i_Company_Id number,
    i_Quiz_Id    number,
    i_Name       varchar2
  ) return number is
    r_Option Hd_Quiz_Options%rowtype;
  begin
    select t.Option_Id
      into r_Option.Option_Id
      from Hd_Quiz_Options t
     where t.Company_Id = i_Company_Id
       and t.Quiz_Id = i_Quiz_Id
       and t.Name = i_Name;
  
    return r_Option.Option_Id;
  exception
    when No_Data_Found then
      r_Option.Company_Id := i_Company_Id;
      r_Option.Option_Id  := Hd_Next.Option_Id;
      r_Option.Name       := i_Name;
      r_Option.Quiz_Id    := i_Quiz_Id;
      r_Option.State      := 'A';
      r_Option.Order_No   := 99;
    
      z_Hd_Quiz_Options.Save_Row(r_Option);
    
      return r_Option.Option_Id;
  end;
begin
  -- add option_id
  for r in (select d.Quiz_Id, w.*, q.Name
              from Hdf_Surveys t
              join Hdf_Survey_Quiz_Sets h
                on t.Company_Id = h.Company_Id
               and t.Survey_Id = h.Survey_Id
              join Hdf_Survey_Quizs d
                on d.Company_Id = h.Company_Id
               and d.Sv_Quiz_Set_Id = h.Sv_Quiz_Set_Id
              join Hdf_Survey_Quiz_Answers w
                on w.Company_Id = d.Company_Id
               and w.Sv_Quiz_Id = d.Sv_Quiz_Id
              join Hd_Quizs q
                on d.Company_Id = q.Company_Id
               and d.Quiz_Id = q.Quiz_Id
            
             where w.Answer is not null
               and q.Quiz_Kind = 'S'
               and w.Option_Id is null)
  loop
    r_Answer.Company_Id      := r.Company_Id;
    r_Answer.Sv_Quiz_Unit_Id := r.Sv_Quiz_Unit_Id;
    r_Answer.Sv_Quiz_Id      := r.Sv_Quiz_Id;
    r_Answer.Option_Id       := Get_Option_Id(r.Company_Id, r.Quiz_Id, r.Answer);
    r_Answer.Answer          := r.Answer;
  
    z_Hdf_Survey_Quiz_Answers.Update_Row(r_Answer);
  end loop;

  -- remove option_id
  for r in (select d.Quiz_Id, w.*, q.Name
              from Hdf_Surveys t
              join Hdf_Survey_Quiz_Sets h
                on t.Company_Id = h.Company_Id
               and t.Survey_Id = h.Survey_Id
              join Hdf_Survey_Quizs d
                on d.Company_Id = h.Company_Id
               and d.Sv_Quiz_Set_Id = h.Sv_Quiz_Set_Id
              join Hdf_Survey_Quiz_Answers w
                on w.Company_Id = d.Company_Id
               and w.Sv_Quiz_Id = d.Sv_Quiz_Id
              join Hd_Quizs q
                on d.Company_Id = q.Company_Id
               and d.Quiz_Id = q.Quiz_Id
            
             where w.Answer is not null
               and q.Quiz_Kind = 'M'
               and w.Option_Id is not null)
  loop
    r_Answer.Company_Id      := r.Company_Id;
    r_Answer.Sv_Quiz_Unit_Id := r.Sv_Quiz_Unit_Id;
    r_Answer.Sv_Quiz_Id      := r.Sv_Quiz_Id;
    r_Answer.Option_Id       := null;
    r_Answer.Answer          := r.Answer;
  
    z_Hdf_Survey_Quiz_Answers.Update_Row(r_Answer);
  end loop;

  commit;
end;
0
0
