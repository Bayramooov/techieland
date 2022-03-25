create or replace package Hd_Core is
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Save(i_Quiz Hd_Pref.Quiz_Rt);
end Hd_Core;
/
create or replace package body Hd_Core is
  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Quiz_Set_Save
  (
    i_Company_Id      number,
    i_Option_Id       number,
    i_Option_Quiz_Set Hd_Pref.Option_Quiz_Set_Rt
  ) is
    r_Option_Quiz_Set Hd_Option_Quiz_Sets%rowtype;
  begin
    r_Option_Quiz_Set.Company_Id        := i_Company_Id;
    r_Option_Quiz_Set.Option_Id         := i_Option_Id;
    r_Option_Quiz_Set.Child_Quiz_Set_Id := i_Option_Quiz_Set.Child_Quiz_Set_Id;
  
    if not
        z_Hd_Option_Quiz_Sets.Exist(i_Company_Id        => r_Option_Quiz_Set.Company_Id,
                                    i_Option_Id         => r_Option_Quiz_Set.Option_Id,
                                    i_Child_Quiz_Set_Id => r_Option_Quiz_Set.Child_Quiz_Set_Id) then
      z_Hd_Option_Quiz_Sets.Insert_Row(r_Option_Quiz_Set);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Quiz_Save
  (
    i_Company_Id  number,
    i_Option_Id   number,
    i_Option_Quiz Hd_Pref.Option_Quiz_Rt
  ) is
    r_Option_Quiz Hd_Option_Quizs%rowtype;
  begin
    r_Option_Quiz.Company_Id    := i_Company_Id;
    r_Option_Quiz.Option_Id     := i_Option_Id;
    r_Option_Quiz.Child_Quiz_Id := i_Option_Quiz.Child_Quiz_Id;
  
    if not z_Hd_Option_Quizs.Exist(i_Company_Id    => r_Option_Quiz.Company_Id,
                                   i_Option_Id     => r_Option_Quiz.Option_Id,
                                   i_Child_Quiz_Id => r_Option_Quiz.Child_Quiz_Id) then
      z_Hd_Option_Quizs.Insert_Row(r_Option_Quiz);
    end if;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Option_Save
  (
    i_Company_Id number,
    i_Quiz_Id    number,
    i_Option     Hd_Pref.Option_Rt
  ) is
    r_Option              Hd_Quiz_Options%rowtype;
    v_Option_Quiz_Ids     Array_Number := Array_Number();
    v_Option_Quiz_Set_Ids Array_Number := Array_Number();
  begin
    r_Option.Company_Id := i_Company_Id;
    r_Option.Option_Id  := i_Option.Option_Id;
    r_Option.Quiz_Id    := i_Quiz_Id;
    r_Option.Name       := i_Option.Name;
    r_Option.State      := i_Option.State;
    r_Option.Order_No   := i_Option.Order_No;
    r_Option.Value      := i_Option.Value;
  
    z_Hd_Quiz_Options.Save_Row(r_Option);
  
    for i in 1 .. i_Option.Quizs.Count
    loop
      Option_Quiz_Save(i_Company_Id, r_Option.Option_Id, i_Option.Quizs(i));
    
      v_Option_Quiz_Ids.Extend;
      v_Option_Quiz_Ids(v_Option_Quiz_Ids.Count) := i_Option.Quizs(i).Child_Quiz_Id;
    end loop;
  
    for i in 1 .. i_Option.Quiz_Sets.Count
    loop
      Option_Quiz_Set_Save(i_Company_Id, r_Option.Option_Id, i_Option.Quiz_Sets(i));
    
      v_Option_Quiz_Set_Ids.Extend;
      v_Option_Quiz_Set_Ids(v_Option_Quiz_Set_Ids.Count) := i_Option.Quiz_Sets(i).Child_Quiz_Set_Id;
    end loop;
  
    delete from Hd_Option_Quizs t
     where t.Company_Id = r_Option.Company_Id
       and t.Option_Id = r_Option.Option_Id
       and t.Child_Quiz_Id not member of v_Option_Quiz_Ids;
  
    delete from Hd_Option_Quiz_Sets t
     where t.Company_Id = r_Option.Company_Id
       and t.Option_Id = r_Option.Option_Id
       and t.Child_Quiz_Set_Id not member of v_Option_Quiz_Set_Ids;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Save(i_Quiz Hd_Pref.Quiz_Rt) is
    r_Quiz       Hd_Quizs%rowtype;
    v_Option_Ids Array_Number := Array_Number();
  begin
    r_Quiz.Company_Id      := i_Quiz.Company_Id;
    r_Quiz.Quiz_Id         := i_Quiz.Quiz_Id;
    r_Quiz.Name            := i_Quiz.Name;
    r_Quiz.State           := i_Quiz.State;
    r_Quiz.Data_Kind       := i_Quiz.Data_Kind;
    r_Quiz.Quiz_Kind       := i_Quiz.Quiz_Kind;
    r_Quiz.Select_Multiple := i_Quiz.Select_Multiple;
    r_Quiz.Select_Form     := i_Quiz.Select_Form;
    r_Quiz.Min_Scale       := i_Quiz.Min_Scale;
    r_Quiz.Max_Scale       := i_Quiz.Max_Scale;
    r_Quiz.Is_Required     := i_Quiz.Is_Required;
  
    z_Hd_Quizs.Save_Row(r_Quiz);
  
    for i in 1 .. i_Quiz.Options.Count
    loop
      Option_Save(r_Quiz.Company_Id, r_Quiz.Quiz_Id, i_Quiz.Options(i));
      v_Option_Ids.Extend;
      v_Option_Ids(v_Option_Ids.Count) := i_Quiz.Options(i).Option_Id;
    end loop;
  
    delete from Hd_Quiz_Options t
     where t.Company_Id = r_Quiz.Company_Id
       and t.Quiz_Id = r_Quiz.Quiz_Id
       and t.Option_Id not member of v_Option_Ids;
  end;

end Hd_Core;
/
