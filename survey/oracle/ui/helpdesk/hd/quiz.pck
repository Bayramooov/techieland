create or replace package Ui_Helpdesk14 is
  ----------------------------------------------------------------------------------------------------  
  Function Quizs_Query return Fazo_Query;
  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Sets_Query return Fazo_Query;
  ----------------------------------------------------------------------------------------------------  
  Function Add_Model return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Function Add(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Function Edit_Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Function Edit(p Hashmap) return Hashmap;
end Ui_Helpdesk14;
/
create or replace package body Ui_Helpdesk14 is

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
    return b.Translate('UI-HELPDESK14:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Data_Kinds return Arraylist is
  begin
    return Fazo.Zip_Matrix(Matrix_Varchar2(Array_Varchar2(Hd_Pref.c_Dk_Number, t('dk_number')),
                                           Array_Varchar2(Hd_Pref.c_Dk_Date, t('dk_date')),
                                           Array_Varchar2(Hd_Pref.c_Dk_Short_Text,
                                                          t('dk_short text')),
                                           Array_Varchar2(Hd_Pref.c_Dk_Long_Text, t('dk_long text')),
                                           Array_Varchar2(Hd_Pref.c_Dk_Boolean, t('dk_boolean'))));
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Data_Kind_Name(i_Data_Kind varchar2) return varchar2 is
  begin
    return case i_Data_Kind when Hd_Pref.c_Dk_Number then t('dk_number') --
    when Hd_Pref.c_Dk_Date then t('dk_date') --
    when Hd_Pref.c_Dk_Short_Text then t('dk_short text') --
    when Hd_Pref.c_Dk_Long_Text then t('dk_long text') --
    when Hd_Pref.c_Dk_Boolean then t('dk_boolean') end;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Quizs_Query return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hd_quizs', Fazo.Zip_Map('company_id', Ui.Company_Id), true);
    q.Number_Field('quiz_id');
    q.Varchar2_Field('name');
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Sets_Query return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hd_quiz_sets', Fazo.Zip_Map('company_id', Ui.Company_Id), true);
    q.Number_Field('quiz_set_id');
    q.Varchar2_Field('name');
  
    return q;
  end;
  ----------------------------------------------------------------------------------------------------  
  Function Add_Model return Hashmap is
    result Hashmap;
  begin
    result := Fazo.Zip_Map('state',
                           'A',
                           'is_required',
                           'Y',
                           'data_kind',
                           Hd_Pref.c_Dk_Number,
                           'data_kind_name',
                           t('dk_number'),
                           'quiz_kind',
                           Hd_Pref.c_Qk_Manual);
  
    Result.Put('data_kinds', Data_Kinds);
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Fill_Record
  (
    p      Hashmap,
    o_Quiz in out nocopy Hd_Pref.Quiz_Rt
  ) is
    r_Quiz                  Hd_Quizs%rowtype;
    r_Option                Hd_Pref.Option_Rt;
    r_Option_Child_Quiz     Hd_Pref.Option_Quiz_Rt;
    r_Option_Child_Quiz_Set Hd_Pref.Option_Quiz_Set_Rt;
    v_List                  Arraylist;
    v_List_Item             Hashmap;
    v_Child_Quizs           Arraylist;
    v_Child_Quiz_Sets       Arraylist;
    v_Option_Id             number;
  begin
    r_Quiz := z_Hd_Quizs.To_Row(p,
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
  
    if r_Quiz.Quiz_Id is null then
      r_Quiz.Quiz_Id := Hd_Next.Quiz_Id;
    end if;
  
    Hd_Util.Quiz_New(o_Quiz            => o_Quiz,
                     i_Company_Id      => Ui.Company_Id,
                     i_Quiz_Id         => r_Quiz.Quiz_Id,
                     i_Name            => r_Quiz.Name,
                     i_State           => r_Quiz.State,
                     i_Data_Kind       => r_Quiz.Data_Kind,
                     i_Quiz_Kind       => r_Quiz.Quiz_Kind,
                     i_Select_Multiple => r_Quiz.Select_Multiple,
                     i_Select_Form     => r_Quiz.Select_Form,
                     i_Min_Scale       => r_Quiz.Min_Scale,
                     i_Max_Scale       => r_Quiz.Max_Scale,
                     i_Is_Required     => r_Quiz.Is_Required);
  
    v_List := Nvl(p.o_Arraylist('options'), Arraylist());
  
    for i in 1 .. v_List.Count
    loop
      v_List_Item := Treat(v_List.r_Hashmap(i) as Hashmap);
    
      v_Option_Id := v_List_Item.o_Number('option_id');
      if (v_Option_Id is null) then
        v_Option_Id := Hd_Next.Option_Id;
      end if;
    
      Hd_Util.Option_New(o_Option    => r_Option,
                         i_Option_Id => v_Option_Id,
                         i_Name      => v_List_Item.r_Varchar2('name'),
                         i_Order_No  => i,
                         i_State     => v_List_Item.r_Varchar2('state'),
                         i_Value     => v_List_Item.o_Varchar2('value'));
    
      v_Child_Quizs := Nvl(v_List_Item.o_Arraylist('child_quizs'), Arraylist());
    
      for j in 1 .. v_Child_Quizs.Count
      loop
        Hd_Util.Option_Quiz_New(o_Option_Quiz   => r_Option_Child_Quiz,
                                i_Child_Quiz_Id => Treat(v_Child_Quizs.r_Hashmap(j) as Hashmap).r_Number('child_quiz_id'));
      
        Hd_Util.Option_Add_Child_Quiz(o_Option => r_Option, i_Option_Quiz => r_Option_Child_Quiz);
      end loop;
    
      v_Child_Quiz_Sets := Nvl(v_List_Item.o_Arraylist('child_quiz_sets'), Arraylist());
    
      for j in 1 .. v_Child_Quiz_Sets.Count
      loop
        Hd_Util.Option_Quiz_Set_New(o_Option_Quiz_Set   => r_Option_Child_Quiz_Set,
                                    i_Child_Quiz_Set_Id => Treat(v_Child_Quiz_Sets.r_Hashmap(j) as Hashmap) .
                                                            r_Number('child_quiz_set_id'));
      
        Hd_Util.Option_Add_Child_Quiz_Set(o_Option          => r_Option,
                                          i_Option_Quiz_Set => r_Option_Child_Quiz_Set);
      end loop;
    
      Hd_Util.Quiz_Add_Option(o_Quiz, r_Option);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Add(p Hashmap) return Hashmap is
    r_Record Hd_Pref.Quiz_Rt;
  begin
    Fill_Record(p, r_Record);
  
    Hd_Api.Quiz_Save(r_Record);
  
    return Fazo.Zip_Map('quiz_id', r_Record.Quiz_Id, 'name', r_Record.Name);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Edit_Model(p Hashmap) return Hashmap is
    result              Hashmap := Hashmap();
    r_Quiz              Hd_Quizs%rowtype;
    v_Options           Arraylist := Arraylist();
    v_Option            Hashmap;
    v_Option_Child      Hashmap;
    v_Option_Child_List Arraylist;
    ----------------------------------------------------     
    Function Quiz_Name
    (
      i_Id        number,
      i_For_Quizs boolean := true
    ) return varchar2 is
      v_Quiz_Name Hd_Quizs.Name%type;
    begin
      if i_For_Quizs then
        select h.Name
          into v_Quiz_Name
          from Hd_Quizs h
         where h.Company_Id = Ui.Company_Id
           and h.Quiz_Id = i_Id;
      else
        select h.Name
          into v_Quiz_Name
          from Hd_Quiz_Sets h
         where h.Company_Id = Ui.Company_Id
           and h.Quiz_Set_Id = i_Id;
      end if;
      return v_Quiz_Name;
    end;
  begin
    r_Quiz := z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => p.r_Number('quiz_id'));
  
    result := z_Hd_Quizs.To_Map(r_Quiz,
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
  
    Result.Put('data_kinds', Data_Kinds);
    Result.Put('data_kind_name', Data_Kind_Name(r_Quiz.Data_Kind));
  
    for Opt in (select *
                  from Hd_Quiz_Options h
                 where h.Company_Id = Ui.Company_Id
                   and h.Quiz_Id = r_Quiz.Quiz_Id)
    loop
      v_Option := z_Hd_Quiz_Options.To_Map(Opt,
                                           z.Option_Id,
                                           z.Quiz_Id,
                                           z.Name,
                                           z.State,
                                           z.Order_No,
                                           z.Value);
    
      v_Option_Child_List := Arraylist();
      for Child_Quiz in (select *
                           from Hd_Option_Quizs h
                          where h.Company_Id = Opt.Company_Id
                            and h.Option_Id = Opt.Option_Id)
      loop
        v_Option_Child := z_Hd_Option_Quizs.To_Map(Child_Quiz,
                                                   z.Quiz_Id,
                                                   z.Option_Id,
                                                   z.Child_Quiz_Id);
      
        v_Option_Child.Put('child_quiz_name', Quiz_Name(Child_Quiz.Child_Quiz_Id));
        v_Option_Child_List.Push(v_Option_Child);
      end loop;
      v_Option.Put('child_quizs', v_Option_Child_List);
    
      v_Option_Child_List := Arraylist();
      for Child_Quiz_Set in (select *
                               from Hd_Option_Quiz_Sets
                              where Company_Id = Opt.Company_Id
                                and Option_Id = Opt.Option_Id)
      loop
        v_Option_Child := z_Hd_Option_Quiz_Sets.To_Map(Child_Quiz_Set,
                                                       z.Quiz_Id,
                                                       z.Option_Id,
                                                       z.Child_Quiz_Set_Id);
        v_Option_Child.Put('child_quiz_set_name',
                           Quiz_Name(Child_Quiz_Set.Child_Quiz_Set_Id, false));
        v_Option_Child_List.Push(v_Option_Child);
      end loop;
      v_Option.Put('child_quiz_sets', v_Option_Child_List);
      v_Options.Push(v_Option);
    end loop;
  
    Result.Put('options', v_Options);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Edit(p Hashmap) return Hashmap is
    r_Record Hd_Pref.Quiz_Rt;
  begin
    Fill_Record(p, r_Record);
  
    Hd_Api.Quiz_Save(r_Record);
  
    return Fazo.Zip_Map('quiz_id', r_Record.Quiz_Id, 'name', r_Record.Name);
  end;

end Ui_Helpdesk14;
/
