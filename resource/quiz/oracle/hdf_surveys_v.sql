create or replace view hdf_surveys_v as 
select t.*,
       h.Sv_Quiz_Set_Id,
       h.Quiz_Set_Id,
       h.Parent_Option_Id Quiz_Set_Parent_Option_Id,
       d.Sv_Quiz_Id,
       d.Quiz_Id,
       d.Order_No,
       d.Parent_Option_Id Quiz_Parent_Option_Id,
       w.Sv_Quiz_Unit_Id,
       w.Answer,
       w.Option_Id
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
   with read only;
/   
