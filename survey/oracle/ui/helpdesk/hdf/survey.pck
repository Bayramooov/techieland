create or replace package Ui_Helpdesk24 is
  ----------------------------------------------------------------------------------------------------
  Function Query_Quiz_Set_Groups return Fazo_Query;
  ----------------------------------------------------------------------------------------------------  
  Function Get_Children(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Function Add_Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Procedure Add(p Hashmap);
  ----------------------------------------------------------------------------------------------------  
  Function Edit_Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Procedure Edit(p Hashmap);
  ----------------------------------------------------------------------------------------------------
  Function Load_Ref_Quiz_Sets(p Hashmap) return Hashmap;
end Ui_Helpdesk24;
/
create or replace package body Ui_Helpdesk24 is
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
    return b.Translate('UI-HELPDESK24:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Query_Quiz_Set_Groups return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hd_quiz_set_groups',
                    Fazo.Zip_Map('company_id', Ui.Company_Id, 'state', 'A'),
                    true);
  
    q.Number_Field('quiz_set_group_id');
    q.Varchar2_Field('name');
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Survey_Statuses return Matrix_Varchar2 is
  begin
    return Matrix_Varchar2(Array_Varchar2(Hdf_Pref.c_Ss_Draft, t('ss_draft')),
                           Array_Varchar2(Hdf_Pref.c_Ss_New, t('ss_new')),
                           Array_Varchar2(Hdf_Pref.c_Ss_Processing, t('ss_processing')),
                           Array_Varchar2(Hdf_Pref.c_Ss_Completed, t('ss_completed')));
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Status_Name(i_Status_Code varchar2) return varchar2 is
    v_Statuses Matrix_Varchar2 := Survey_Statuses;
  begin
    for i in 1 .. v_Statuses.Count
    loop
      if v_Statuses(i) (1) = i_Status_Code then
        return v_Statuses(i)(2);
      end if;
    end loop;
  
    return null;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Quiz_Answers
  (
    o_Survey_Quiz in out nocopy Hdf_Pref.Survey_Quiz_Rt,
    i_List        Arraylist
  ) is
    r_Quiz_Answer Hdf_Survey_Quiz_Answers%rowtype;
    v_Quiz_Answer Hdf_Pref.Survey_Quiz_Answer_Rt;
    v_List_Item   Hashmap;
  begin
    for i in 1 .. i_List.Count
    loop
      v_List_Item := Treat(i_List.r_Hashmap(i) as Hashmap);
    
      r_Quiz_Answer := z_Hdf_Survey_Quiz_Answers.To_Row(v_List_Item,
                                                        z.Sv_Quiz_Unit_Id,
                                                        z.Option_Id,
                                                        z.Answer);
      if r_Quiz_Answer.Sv_Quiz_Unit_Id is null then
        r_Quiz_Answer.Sv_Quiz_Unit_Id := Hdf_Next.Hdf_Sv_Quiz_Unit_Id;
      end if;
    
      Hdf_Util.Survey_Quiz_Answer_New(o_Survey_Quiz_Answer => v_Quiz_Answer,
                                      i_Sv_Quiz_Unit_Id    => r_Quiz_Answer.Sv_Quiz_Unit_Id,
                                      i_Option_Id          => r_Quiz_Answer.Option_Id,
                                      i_Answer             => r_Quiz_Answer.Answer);
    
      Hdf_Util.Survey_Quiz_Add_Answer(o_Survey_Quiz        => o_Survey_Quiz,
                                      i_Survey_Quiz_Answer => v_Quiz_Answer);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Survey_Quizs
  (
    o_Survey_Quiz_Set in out nocopy Hdf_Pref.Survey_Quiz_Set_Rt,
    i_List            Arraylist
  ) is
    r_Survey_Quiz Hdf_Survey_Quizs%rowtype;
    v_Survey_Quiz Hdf_Pref.Survey_Quiz_Rt;
    v_List_Item   Hashmap;
  begin
    for i in 1 .. i_List.Count
    loop
      v_List_Item := Treat(i_List.r_Hashmap(i) as Hashmap);
    
      r_Survey_Quiz := z_Hdf_Survey_Quizs.To_Row(v_List_Item,
                                                 z.Sv_Quiz_Id,
                                                 z.Quiz_Id,
                                                 z.Parent_Option_Id);
    
      if r_Survey_Quiz.Sv_Quiz_Id is null then
        r_Survey_Quiz.Sv_Quiz_Id := Hdf_Next.Hdf_Sv_Quiz_Id;
      end if;
    
      Hdf_Util.Survey_Quiz_New(o_Survey_Quiz      => v_Survey_Quiz,
                               i_Sv_Quiz_Id       => r_Survey_Quiz.Sv_Quiz_Id,
                               i_Quiz_Id          => r_Survey_Quiz.Quiz_Id,
                               i_Parent_Option_Id => r_Survey_Quiz.Parent_Option_Id);
    
      Fill_Quiz_Answers(v_Survey_Quiz, v_List_Item.r_Arraylist('quiz_answers'));
    
      Hdf_Util.Survey_Quiz_Set_Add_Quiz(o_Survey_Quiz_Set => o_Survey_Quiz_Set,
                                        i_Survey_Quiz     => v_Survey_Quiz);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Survey_Quiz_Sets
  (
    o_Survey in out nocopy Hdf_Pref.Survey_Rt,
    i_List   Arraylist
  ) is
    r_Survey_Quiz_Set Hdf_Survey_Quiz_Sets%rowtype;
    v_Survey_Quiz_Set Hdf_Pref.Survey_Quiz_Set_Rt;
    v_List_Item       Hashmap;
  begin
    for i in 1 .. i_List.Count
    loop
      v_List_Item := Treat(i_List.r_Hashmap(i) as Hashmap);
    
      r_Survey_Quiz_Set := z_Hdf_Survey_Quiz_Sets.To_Row(v_List_Item,
                                                         z.Sv_Quiz_Set_Id,
                                                         z.Quiz_Set_Id,
                                                         z.Parent_Option_Id);
    
      if r_Survey_Quiz_Set.Sv_Quiz_Set_Id is null then
        r_Survey_Quiz_Set.Sv_Quiz_Set_Id := Hdf_Next.Hdf_Sv_Quiz_Set_Id;
      end if;
    
      Hdf_Util.Survey_Quiz_Set_New(o_Survey_Quiz_Set  => v_Survey_Quiz_Set,
                                   i_Sv_Quiz_Set_Id   => r_Survey_Quiz_Set.Sv_Quiz_Set_Id,
                                   i_Quiz_Set_Id      => r_Survey_Quiz_Set.Quiz_Set_Id,
                                   i_Parent_Option_Id => r_Survey_Quiz_Set.Parent_Option_Id);
    
      Fill_Survey_Quizs(v_Survey_Quiz_Set, v_List_Item.r_Arraylist('quizs'));
    
      Hdf_Util.Survey_Add_Quiz_Set(o_Survey => o_Survey, i_Survey_Quiz_Set => v_Survey_Quiz_Set);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Load_Ref_Quiz_Options
  (
    i_Quiz_Id      number,
    i_Sv_Quiz_Id   number := null,
    i_Is_Check_Box boolean := null
  ) return Arraylist is
    v_Quiz_Options Arraylist := Arraylist();
    v_Quiz_Option  Hashmap;
  
    --------------------------------------------------   
    Function Get_Checked(i_Option_Id number) return varchar2 is
      v_Checked varchar2(1);
    begin
      select 'Y'
        into v_Checked
        from Dual
       where exists (select 1
                from Hdf_Survey_Quiz_Answers t
               where t.Company_Id = Ui.Company_Id
                 and t.Sv_Quiz_Id = i_Sv_Quiz_Id
                 and t.Option_Id = i_Option_Id);
      return v_Checked;
    
    exception
      when No_Data_Found then
        return 'N';
    end;
  begin
    for r in (select *
                from Hd_Quiz_Options t
               where t.Company_Id = Ui.Company_Id
                 and t.Quiz_Id = i_Quiz_Id
                 and t.state = 'A'
               order by t.Order_No)
    loop
      v_Quiz_Option := z_Hd_Quiz_Options.To_Map(r, z.Option_Id, z.Name, z.Value);
    
      if i_Sv_Quiz_Id is not null and i_Is_Check_Box then
        v_Quiz_Option.Put('check_box_answer', Get_Checked(r.Option_Id));
      end if;
    
      v_Quiz_Options.Push(v_Quiz_Option);
    end loop;
  
    return v_Quiz_Options;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Load_Ref_Quizs(i_Quiz_Set_Id number) return Arraylist is
    v_Quizs Arraylist := Arraylist();
    v_Quiz  Hashmap;
  begin
    for r in (select t.*
                from Hd_Quizs t
                join Hd_Quiz_Set_Binds k
                  on k.Company_Id = t.Company_Id
                 and k.Quiz_Id = t.Quiz_Id
               where k.Company_Id = Ui.Company_Id
                 and k.Quiz_Set_Id = i_Quiz_Set_Id
                 and t.State = 'A'
               order by k.Order_No)
    loop
      v_Quiz := z_Hd_Quizs.To_Map(r,
                                  z.Quiz_Id,
                                  z.Name,
                                  z.State,
                                  z.Data_Kind,
                                  z.Quiz_Kind,
                                  z.Select_Multiple,
                                  z.Select_Form,
                                  z.Min_Scale,
                                  z.Max_Scale,
                                  z.Is_Required);
    
      v_Quiz.Put('options', Load_Ref_Quiz_Options(r.Quiz_Id));
      v_Quizs.Push(v_Quiz);
    end loop;
  
    return v_Quizs;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Ref_Quiz_Sets(p Hashmap) return Hashmap is
    v_Quiz_Sets         Arraylist := Arraylist();
    v_Quiz_Set          Hashmap;
    v_Quiz_Set_Group_Id number := p.r_Number('quiz_set_group_id');
    result              Hashmap := Hashmap();
  begin
    for r in (select t.*
                from Hd_Quiz_Sets t
                join Hd_Quiz_Set_Group_Binds k
                  on k.Company_Id = t.Company_Id
                 and k.Quiz_Set_Id = t.Quiz_Set_Id
               where t.Company_Id = Ui.Company_Id
                 and k.Quiz_Set_Group_Id = v_Quiz_Set_Group_Id
               order by k.Order_No)
    loop
      v_Quiz_Set := z_Hd_Quiz_Sets.To_Map(r, z.Quiz_Set_Id, z.Name);
      v_Quiz_Set.Put('quizs', Load_Ref_Quizs(r.Quiz_Set_Id));
    
      v_Quiz_Sets.Push(v_Quiz_Set);
    end loop;
  
    Result.Put('quiz_sets', v_Quiz_Sets);
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Load_Sv_Quiz_Options
  (
    o_Quiz            in out nocopy Hashmap,
    i_Sv_Quiz_Id      number,
    i_Quiz_Id         number,
    i_Quiz_Kind       varchar2,
    i_Select_Multiple varchar2,
    i_Select_Form     varchar2
  ) is
    v_List          Arraylist := Arraylist();
    v_List_Item     Hashmap;
    v_z_Column_Name varchar2(100) := 'answer';
    v_Is_Check_Box  boolean := false;
  begin
    if i_Select_Form = Hd_Pref.c_Sf_Drop_Down then
      v_z_Column_Name := 'name';
    end if;
  
    for r in (select *
                from Hdf_Survey_Quiz_Answers t
               where t.Company_Id = Ui.Company_Id
                 and t.Sv_Quiz_Id = i_Sv_Quiz_Id)
    loop
      v_List.Push(z_Hdf_Survey_Quiz_Answers.To_Map(r,
                                                   z.Sv_Quiz_Unit_Id,
                                                   z.Option_Id,
                                                   z.Answer,
                                                   i_Answer => v_z_Column_Name));
    end loop;
  
    if v_List.Count > 0 then
      v_List_Item := Treat(v_List.r_Hashmap(1) as Hashmap);
    
      if i_Quiz_Kind = Hd_Pref.c_Qk_Manual then
        o_Quiz.Put_All(v_List_Item);
      else
        if i_Select_Multiple = 'N' then
          o_Quiz.Put_All(Fazo.Zip_Map('sv_quiz_unit_id',
                                      v_List_Item.r_Number('sv_quiz_unit_id'),
                                      'answer_option_id',
                                      v_List_Item.r_Number('option_id'),
                                      'answer_option_name',
                                      v_List_Item.r_Varchar2(v_z_Column_Name)));
        else
          if i_Select_Form = Hd_Pref.c_Sf_Drop_Down then
            o_Quiz.Put('answer_options', v_List);
          else
            v_Is_Check_Box := true;
          end if;
        end if;
      end if;
    end if;
  
    o_Quiz.Put('options', Load_Ref_Quiz_Options(i_Quiz_Id, i_Sv_Quiz_Id, v_Is_Check_Box));
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Load_Sv_Quizs(i_Sv_Quiz_Set_Id number) return Arraylist is
    v_List      Arraylist := Arraylist();
    v_List_Item Hashmap;
  begin
    for r in (select t.*,
                     k.Name,
                     k.Data_Kind,
                     k.Quiz_Kind,
                     k.Select_Multiple,
                     k.Select_Form,
                     k.Min_Scale,
                     k.Max_Scale,
                     k.Is_Required
                from Hdf_Survey_Quizs t
                join Hd_Quizs k
                  on k.Company_Id = t.Company_Id
                 and k.Quiz_Id = t.Quiz_Id
               where t.Company_Id = Ui.Company_Id
                 and t.Sv_Quiz_Set_Id = i_Sv_Quiz_Set_Id
               order by t.Order_No)
    loop
      v_List_Item := Fazo.Zip_Map('sv_quiz_id',
                                  r.Sv_Quiz_Id,
                                  'quiz_id',
                                  r.Quiz_Id,
                                  'parent_option_id',
                                  r.Parent_Option_Id,
                                  'name',
                                  r.Name,
                                  'data_kind',
                                  r.Data_Kind,
                                  'quiz_kind',
                                  r.Quiz_Kind);
    
      v_List_Item.Put_All(Fazo.Zip_Map('select_multiple',
                                       r.Select_Multiple,
                                       'select_form',
                                       r.Select_Form,
                                       'min_scale',
                                       r.Min_Scale,
                                       'max_scale',
                                       r.Max_Scale,
                                       'is_required',
                                       r.Is_Required));
      Load_Sv_Quiz_Options(v_List_Item,
                           r.Sv_Quiz_Id,
                           r.Quiz_Id,
                           r.Quiz_Kind,
                           r.Select_Multiple,
                           r.Select_Form);
    
      v_List.Push(v_List_Item);
    end loop;
  
    return v_List;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Load_Sv_Quiz_Sets(i_Survey_Id number) return Arraylist is
    v_List      Arraylist := Arraylist();
    v_List_Item Hashmap;
  begin
    for r in (select t.*,
                     (select k.Name
                        from Hd_Quiz_Sets k
                       where k.Company_Id = t.Company_Id
                         and k.Quiz_Set_Id = t.Quiz_Set_Id) name
                from Hdf_Survey_Quiz_Sets t
               where t.Company_Id = Ui.Company_Id
                 and t.Survey_Id = i_Survey_Id)
    loop
      v_List_Item := Fazo.Zip_Map('sv_quiz_set_id',
                                  r.Sv_Quiz_Set_Id,
                                  'quiz_set_id',
                                  r.Quiz_Set_Id,
                                  'parent_option_id',
                                  r.Parent_Option_Id,
                                  'name',
                                  r.Name);
      v_List_Item.Put('quizs', Load_Sv_Quizs(r.Sv_Quiz_Set_Id));
    
      v_List.Push(v_List_Item);
    end loop;
  
    return v_List;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Get_Children(p Hashmap) return Hashmap is
    v_Option_Id number := p.r_Number('option_id');
    v_List      Arraylist := Arraylist();
    v_List_Item Hashmap;
    result      Hashmap := Hashmap();
  begin
    for r in (select *
                from Hd_Quizs t
               where t.Company_Id = Ui.Company_Id
                 and exists (select 1
                        from Hd_Option_Quizs k
                       where k.Company_Id = t.Company_Id
                         and k.Option_Id = v_Option_Id
                         and k.Child_Quiz_Id = t.Quiz_Id))
    loop
      v_List_Item := z_Hd_Quizs.To_Map(r,
                                       z.Quiz_Id,
                                       z.Name,
                                       z.State,
                                       z.Data_Kind,
                                       z.Quiz_Kind,
                                       z.Select_Multiple,
                                       z.Select_Form,
                                       z.Min_Scale,
                                       z.Max_Scale);
      v_List_Item.Put('parent_option_id', v_Option_Id);
    
      v_List_Item.Put('options', Load_Ref_Quiz_Options(r.Quiz_Id));
      v_List.Push(v_List_Item);
    end loop;
  
    Result.Put('quizs', v_List);
  
    v_List := Arraylist();
    for r in (select *
                from Hd_Quiz_Sets t
               where t.Company_Id = Ui.Company_Id
                 and exists (select 1
                        from Hd_Option_Quiz_Sets k
                       where k.Company_Id = t.Company_Id
                         and k.Option_Id = v_Option_Id
                         and k.Child_Quiz_Set_Id = t.Quiz_Set_Id))
    loop
      v_List_Item := z_Hd_Quiz_Sets.To_Map(r, z.Quiz_Set_Id, z.Name);
      v_List_Item.Put('parent_option_id', v_Option_Id);
      v_List_Item.Put('quizs', Load_Ref_Quizs(r.Quiz_Set_Id));
    
      v_List.Push(v_List_Item);
    end loop;
  
    Result.Put('quiz_sets', v_List);
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Record
  (
    o_Survey in out nocopy Hdf_Pref.Survey_Rt,
    p        Hashmap
  ) is
    r_Survey Hdf_Surveys%rowtype;
  begin
    z_Hdf_Surveys.To_Row(r_Survey,
                         p,
                         z.Survey_Id,
                         z.Quiz_Set_Group_Id,
                         z.Survey_Number,
                         z.Survey_Date,
                         z.Status,
                         z.Note);
  
    if r_Survey.Survey_Id is null then
      r_Survey.Survey_Id := Hdf_Next.Hdf_Survey_Id;
    end if;
  
    Hdf_Util.Survey_New(o_Survey            => o_Survey,
                        i_Company_Id        => Ui.Company_Id,
                        i_Survey_Id         => r_Survey.Survey_Id,
                        i_Filial_Id         => Ui.Filial_Id,
                        i_Quiz_Set_Group_Id => r_Survey.Quiz_Set_Group_Id,
                        i_Survey_Number     => r_Survey.Survey_Number,
                        i_Survey_Date       => r_Survey.Survey_Date,
                        i_Status            => r_Survey.Status,
                        i_Note              => r_Survey.Note);
  
    Fill_Survey_Quiz_Sets(o_Survey, p.r_Arraylist('quiz_sets'));
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Add_Model(p Hashmap) return Hashmap is
    result                Hashmap := Hashmap();
    v_Statuses            Matrix_Varchar2 := Survey_Statuses;
    v_Quiz_Set_Group_Name Hd_Quiz_Set_Groups.Name%type;
    v_Quiz_Set_Group_Id   Hd_Quiz_Set_Groups.Quiz_Set_Group_Id%type;
  begin
    Result.Put('survey_date', Trunc(sysdate));
    Result.Put('status', v_Statuses(1) (1));
    Result.Put('status_name', v_Statuses(1) (2));
    Result.Put('statuses', Fazo.Zip_Matrix(v_Statuses));
  
    select Hqs.Quiz_Set_Group_Id, Hqs.Name
      into v_Quiz_Set_Group_Id, v_Quiz_Set_Group_Name
      from Hd_Quiz_Set_Groups Hqs
     where Hqs.Company_Id = Ui.Company_Id
       and Rownum < 2;
  
    Result.Put('name', v_Quiz_Set_Group_Name);
    Result.Put('quiz_set_group_id', v_Quiz_Set_Group_Id);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Add(p Hashmap) is
    v_Survey Hdf_Pref.Survey_Rt;
  begin
    Fill_Record(v_Survey, p);
  
    Hdf_Api.Survey_Save(v_Survey);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Edit_Model(p Hashmap) return Hashmap is
    result   Hashmap;
    r_Survey Hdf_Surveys%rowtype := z_Hdf_Surveys.Load(i_Company_Id => Ui.Company_Id,
                                                       i_Survey_Id  => p.r_Number('survey_id'));
  
    r_Quiz_Set_Group Hd_Quiz_Set_Groups%rowtype := z_Hd_Quiz_Set_Groups.Load(i_Company_Id        => Ui.Company_Id,
                                                                             i_Quiz_Set_Group_Id => r_Survey.Quiz_Set_Group_Id);
  begin
    result := z_Hdf_Surveys.To_Map(r_Survey,
                                   z.Survey_Id,
                                   z.Quiz_Set_Group_Id,
                                   z.Survey_Number,
                                   z.Survey_Date,
                                   z.Status,
                                   z.Note);
  
    Result.Put('name', r_Quiz_Set_Group.Name);
    Result.Put('status_name', Status_Name(r_Survey.Status));
    Result.Put('statuses', Fazo.Zip_Matrix(Survey_Statuses));
    Result.Put('quiz_sets', Load_Sv_Quiz_Sets(r_Survey.Survey_Id));
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Edit(p Hashmap) is
    v_Survey Hdf_Pref.Survey_Rt;
  begin
    Fill_Record(v_Survey, p);
  
    Hdf_Api.Survey_Save(v_Survey);
  end;

end Ui_Helpdesk24;
/
