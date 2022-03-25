create or replace package Hdf_Core is
  ----------------------------------------------------------------------------------------------------
  Function Gen_Document_Number
  (
    i_Company_Id number,
    i_Filial_Id  number,
    i_Table      Fazo_Schema.w_Table_Name,
    i_Column     Fazo_Schema.w_Column_Name
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Save(i_Survey Hdf_Pref.Survey_Rt);
end Hdf_Core;
/
create or replace package body Hdf_Core is
  ---------------------------------------------------------------------------------------------------- 
  Function t
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2 is
  begin
    return b.Translate('HDF:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Document_Number
  (
    i_Company_Id number,
    i_Filial_Id  number,
    i_Table      Fazo_Schema.w_Table_Name,
    i_Column     Fazo_Schema.w_Column_Name
  ) return varchar2 is
  begin
    return Lpad(Md_Core.Sequence_Nextval(i_Company_Id => i_Company_Id,
                                         i_Filial_Id  => i_Filial_Id,
                                         i_Code       => i_Table.Name || ':' || i_Column.Name),
                10,
                0);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quiz_Answers_Save
  (
    i_Company_Id          number,
    i_Sv_Quiz_Id          number,
    i_Survey_Quiz_Answers Hdf_Pref.Survey_Quiz_Answer_Nt
  ) is
    r_Quiz_Answer      Hdf_Survey_Quiz_Answers%rowtype;
    v_Quiz_Answer      Hdf_Pref.Survey_Quiz_Answer_Rt;
    v_Sv_Quiz_Unit_Ids Array_Number := Array_Number();
  begin
    v_Sv_Quiz_Unit_Ids.Extend(i_Survey_Quiz_Answers.Count);
  
    for i in 1 .. i_Survey_Quiz_Answers.Count
    loop
      v_Quiz_Answer := i_Survey_Quiz_Answers(i);
    
      r_Quiz_Answer.Company_Id      := i_Company_Id;
      r_Quiz_Answer.Sv_Quiz_Unit_Id := v_Quiz_Answer.Sv_Quiz_Unit_Id;
      r_Quiz_Answer.Sv_Quiz_Id      := i_Sv_Quiz_Id;
      r_Quiz_Answer.Option_Id       := v_Quiz_Answer.Option_Id;
      r_Quiz_Answer.Answer          := v_Quiz_Answer.Answer;
    
      z_Hdf_Survey_Quiz_Answers.Save_Row(r_Quiz_Answer);
    
      v_Sv_Quiz_Unit_Ids(i) := r_Quiz_Answer.Sv_Quiz_Unit_Id;
    end loop;
  
    delete from Hdf_Survey_Quiz_Answers t
     where t.Company_Id = i_Company_Id
       and t.Sv_Quiz_Id = i_Sv_Quiz_Id
       and t.Sv_Quiz_Unit_Id not in (select Column_Value
                                       from table(v_Sv_Quiz_Unit_Ids));
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Quizs_Save
  (
    i_Company_Id     number,
    i_Sv_Quiz_Set_Id number,
    i_Survey_Quizs   Hdf_Pref.Survey_Quiz_Nt
  ) is
    r_Survey_Quiz Hdf_Survey_Quizs%rowtype;
    v_Survey_Quiz Hdf_Pref.Survey_Quiz_Rt;
    v_Sv_Quiz_Ids Array_Number := Array_Number();
  begin
    v_Sv_Quiz_Ids.Extend(i_Survey_Quizs.Count);
  
    for i in 1 .. i_Survey_Quizs.Count
    loop
      v_Survey_Quiz := i_Survey_Quizs(i);
    
      r_Survey_Quiz.Company_Id       := i_Company_Id;
      r_Survey_Quiz.Sv_Quiz_Id       := v_Survey_Quiz.Sv_Quiz_Id;
      r_Survey_Quiz.Sv_Quiz_Set_Id   := i_Sv_Quiz_Set_Id;
      r_Survey_Quiz.Quiz_Id          := v_Survey_Quiz.Quiz_Id;
      r_Survey_Quiz.Order_No         := i;
      r_Survey_Quiz.Parent_Option_Id := v_Survey_Quiz.Parent_Option_Id;
    
      z_Hdf_Survey_Quizs.Save_Row(r_Survey_Quiz);
    
      v_Sv_Quiz_Ids(i) := r_Survey_Quiz.Sv_Quiz_Id;
    
      Survey_Quiz_Answers_Save(i_Company_Id,
                               r_Survey_Quiz.Sv_Quiz_Id,
                               v_Survey_Quiz.Survey_Quiz_Answers);
    end loop;
  
    delete from Hdf_Survey_Quizs t
     where t.Company_Id = i_Company_Id
       and t.Sv_Quiz_Set_Id = i_Sv_Quiz_Set_Id
       and t.Sv_Quiz_Id not in
           (select Column_Value
              from table(cast(v_Sv_Quiz_Ids as Array_Number)));
  end;

  ----------------------------------------------------------------------------------------------------    
  Procedure Survey_Quiz_Sets_Save
  (
    i_Company_Id       number,
    i_Survey_Id        number,
    i_Survey_Quiz_Sets Hdf_Pref.Survey_Quiz_Set_Nt
  ) is
    r_Survey_Quiz_Set     Hdf_Survey_Quiz_Sets%rowtype;
    v_Survey_Quiz_Set     Hdf_Pref.Survey_Quiz_Set_Rt;
    v_Survey_Quiz_Set_Ids Array_Number := Array_Number();
  begin
    v_Survey_Quiz_Set_Ids.Extend(i_Survey_Quiz_Sets.Count);
  
    for i in 1 .. i_Survey_Quiz_Sets.Count
    loop
      v_Survey_Quiz_Set := i_Survey_Quiz_Sets(i);
    
      r_Survey_Quiz_Set.Company_Id       := i_Company_Id;
      r_Survey_Quiz_Set.Sv_Quiz_Set_Id   := v_Survey_Quiz_Set.Sv_Quiz_Set_Id;
      r_Survey_Quiz_Set.Survey_Id        := i_Survey_Id;
      r_Survey_Quiz_Set.Quiz_Set_Id      := v_Survey_Quiz_Set.Quiz_Set_Id;
      r_Survey_Quiz_Set.Parent_Option_Id := v_Survey_Quiz_Set.Parent_Option_Id;
    
      z_Hdf_Survey_Quiz_Sets.Save_Row(r_Survey_Quiz_Set);
    
      v_Survey_Quiz_Set_Ids(i) := r_Survey_Quiz_Set.Sv_Quiz_Set_Id;
    
      Survey_Quizs_Save(i_Company_Id,
                        r_Survey_Quiz_Set.Sv_Quiz_Set_Id,
                        v_Survey_Quiz_Set.Survey_Quizs);
    end loop;
  
    delete from Hdf_Survey_Quiz_Sets t
     where t.Company_Id = i_Company_Id
       and t.Survey_Id = i_Survey_Id
       and t.Sv_Quiz_Set_Id not in
           (select Column_Value
              from table(cast(v_Survey_Quiz_Set_Ids as Array_Number)));
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Save(i_Survey Hdf_Pref.Survey_Rt) is
    r_Survey    Hdf_Surveys%rowtype;
    v_Is_Exists boolean;
  begin
    if z_Hdf_Surveys.Exist_Lock(i_Company_Id => i_Survey.Company_Id,
                                i_Survey_Id  => i_Survey.Survey_Id,
                                o_Row        => r_Survey) then
      if r_Survey.Filial_Id <> i_Survey.Filial_Id then
        b.Raise_Fatal(t('cannot change other filial survey, survey_id=$1', i_Survey.Survey_Id));
      end if;
    
      v_Is_Exists := true;
    end if;
  
    r_Survey.Company_Id        := i_Survey.Company_Id;
    r_Survey.Survey_Id         := i_Survey.Survey_Id;
    r_Survey.Filial_Id         := i_Survey.Filial_Id;
    r_Survey.Quiz_Set_Group_Id := i_Survey.Quiz_Set_Group_Id;
    r_Survey.Survey_Date       := i_Survey.Survey_Date;
    r_Survey.Status            := i_Survey.Status;
    r_Survey.Note              := i_Survey.Note;
  
    if v_Is_Exists then
      z_Hdf_Surveys.Update_Row(r_Survey);
    else
      r_Survey.Survey_Number := Gen_Document_Number(i_Company_Id => r_Survey.Company_Id,
                                                    i_Filial_Id  => r_Survey.Filial_Id,
                                                    i_Table      => Zt.Hdf_Surveys,
                                                    i_Column     => z.Survey_Number);
      z_Hdf_Surveys.Insert_Row(r_Survey);
    end if;
  
    Survey_Quiz_Sets_Save(i_Survey.Company_Id, i_Survey.Survey_Id, i_Survey.Survey_Quiz_Sets);
  end;

end Hdf_Core;
/
