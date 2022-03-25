create or replace package Ui_Helpdesk39 is
  ----------------------------------------------------------------------------------------------------
  Function Query_Filials return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Function Query_Quizs return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Function Query_Quiz_Options return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Function Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Procedure Run(p Hashmap);
end Ui_Helpdesk39;
/
create or replace package body Ui_Helpdesk39 is
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
    return b.Translate('UI-Helpdesk39:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Query_Filials return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('select *
                       from md_filials t
                      where t.company_id = :company_id
                        and t.filial_id <> :filial_head
                        and state = ''A''
                        and exists (select 1
                               from md_user_filials k
                              where k.company_id = t.company_id
                                and k.user_id = :user_id
                                and k.filial_id = t.filial_id)',
                    Fazo.Zip_Map('company_id',
                                 Ui.Company_Id,
                                 'filial_head',
                                 Ui.Filial_Head,
                                 'user_id',
                                 Ui.User_Id));
  
    q.Number_Field('filial_id');
    q.Varchar2_Field('name');
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Query_Quizs return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('select *
                       from hd_quizs t
                      where t.company_id = :company_id',
                    Fazo.Zip_Map('company_id', Ui.Company_Id));
  
    q.Number_Field('quiz_id');
    q.Varchar2_Field('name', 'data_kind', 'quiz_kind');
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Query_Quiz_Options return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('select *
                       from hd_quiz_options t
                      where t.company_id = :company_id
                      order by t.order_no',
                    Fazo.Zip_Map('company_id', Ui.Company_Id));
  
    q.Number_Field('quiz_id', 'option_id', 'order_no');
    q.Varchar2_Field('name', 'value');
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Parse_Filter
  (
    i_Quiz_List  Arraylist,
    o_Quiz_Ids   out Array_Number,
    o_Option_Ids out Matrix_Number
  ) is
    v_Quiz       Hashmap;
    v_Quiz_Id    number;
    v_Option_Ids Array_Number;
    v_List       Array_Number;
    v_List_Count number;
  begin
    o_Quiz_Ids   := Array_Number();
    o_Option_Ids := Matrix_Number();
  
    for r in 1 .. i_Quiz_List.Count
    loop
      v_Quiz       := Treat(i_Quiz_List.r_Hashmap(r) as Hashmap);
      v_Quiz_Id    := v_Quiz.r_Number('quiz_id');
      v_Option_Ids := Array_Number();
      v_List       := v_Quiz.r_Array_Number('options');
      v_List_Count := v_List.Count;
    
      select t.Option_Id
        bulk collect
        into v_Option_Ids
        from Hd_Quiz_Options t
       where t.Company_Id = Ui.Company_Id
         and t.Quiz_Id = v_Quiz_Id
         and (v_List_Count = 0 or
             t.Option_Id in (select Column_Value
                                from table(v_List)))
       order by t.Order_No, t.Name, t.Option_Id;
    
      Fazo.Push(o_Quiz_Ids, v_Quiz_Id);
      Fazo.Push(o_Option_Ids, v_Option_Ids);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Parse_Setting
  (
    i_Template   Hdr_Templates%rowtype,
    o_Quiz_Ids   out Array_Number,
    o_Option_Ids out Matrix_Number
  ) is
    v_Setting    Hashmap;
    v_Quiz_List  Arraylist;
    v_Quiz       Hashmap;
    v_Quiz_Id    number;
    v_Option_Ids Array_Number;
    v_List       Array_Number;
    v_List_Count number;
  
  begin
    o_Quiz_Ids   := Array_Number();
    o_Option_Ids := Matrix_Number();
    v_Setting    := Fazo.Parse_Map(i_Template.Setting);
    v_Quiz_List  := v_Setting.r_Arraylist('quizs');
  
    for r in 1 .. v_Quiz_List.Count
    loop
      v_Quiz       := Treat(v_Quiz_List.r_Hashmap(r) as Hashmap);
      v_Quiz_Id    := v_Quiz.r_Number('quiz_id');
      v_Option_Ids := Array_Number();
      v_List       := v_Quiz.r_Array_Number('options');
      v_List_Count := v_List.Count;
    
      select t.Option_Id
        bulk collect
        into v_Option_Ids
        from Hd_Quiz_Options t
       where t.Company_Id = Ui.Company_Id
         and t.Quiz_Id = v_Quiz_Id
         and (v_List_Count = 0 or
             t.Option_Id in (select Column_Value
                                from table(v_List)))
       order by t.Order_No, t.Name, t.Option_Id;
    
      Fazo.Push(o_Quiz_Ids, v_Quiz_Id);
      Fazo.Push(o_Option_Ids, v_Option_Ids);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Model(p Hashmap) return Hashmap is
    r_Template   Hdr_Templates%rowtype;
    v_Quiz_Ids   Array_Number;
    v_Option_Ids Matrix_Number;
    result       Hashmap;
  begin
    r_Template := z_Hdr_Templates.Load(i_Company_Id  => Ui.Company_Id,
                                       i_Template_Id => p.r_Number('template_id'));
  
    Parse_Setting(r_Template, v_Quiz_Ids, v_Option_Ids);
  
    result := Fazo.Zip_Map('st_draft',
                           Hdf_Pref.c_Ss_Draft,
                           'st_new',
                           Hdf_Pref.c_Ss_New,
                           'st_processing',
                           Hdf_Pref.c_Ss_Processing,
                           'st_completed',
                           Hdf_Pref.c_Ss_Completed);
    -- todo
    Result.Put('begin_date', Trunc(sysdate, 'MON'));
    Result.Put('end_date', Trunc(sysdate));
    Result.Put('setting_quiz_ids', v_Quiz_Ids);
    Result.Put('template_name', r_Template.Name);
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Print_Header_Info
  (
    a              in out b_Table,
    i_Name         varchar2,
    i_Filial_Names varchar2,
    i_Begin_Date   date,
    i_End_Date     date,
    i_f_Quiz_Ids   Array_Number,
    i_f_Option_Ids Matrix_Number
  ) is
    v_Filter_Text varchar2(4000 char);
  begin
    a.Current_Style('root');
    a.New_Row;
    a.Data(i_Name, i_Style_Name => 'root bold h1');
  
    if Ui.Is_Filial_Head then
      a.New_Row;
      a.Data(t('included filials: $1', i_Filial_Names), i_Style_Name => 'root h2');
    end if;
  
    if i_f_Quiz_Ids.Count > 0 then
      for i in 1 .. i_f_Quiz_Ids.Count
      loop
        a.New_Row;
        v_Filter_Text := z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_f_Quiz_Ids(i)).Name || ': ';
        for j in 1 .. i_f_Option_Ids(i).Count
        loop
          v_Filter_Text := v_Filter_Text || z_Hd_Quiz_Options.Load(i_Company_Id => Ui.Company_Id, i_Option_Id => i_f_Option_Ids(i)(j)).Name || ' ';
        end loop;
        a.Data(v_Filter_Text, i_Style_Name => 'root h2');
      end loop;
    end if;
  
    a.New_Row;
    a.Data(t('time interval: from $1 to $2', i_Begin_Date, i_End_Date), i_Style_Name => 'root h2');
    a.New_Row;
    a.Data(t('date: $1', to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss')), i_Style_Name => 'root h2');
    a.New_Row;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Filial
  (
    a                in out b_Table,
    i_Begin_Date     date,
    i_End_Date       date,
    i_Statuses       Array_Varchar2,
    i_Filial_Ids     Array_Number,
    i_s_Quiz_Ids     Array_Number,
    i_s_Option_Ids   Matrix_Number,
    i_f_Quiz_Ids     Array_Number,
    i_All_Quiz_Ids   Array_Number,
    i_All_Option_Ids Array_Number
  ) is
    x                  b_Table;
    v_Calc             Calc := Calc;
    v_Row_Count        number := 0;
    v_f_Quiz_Ids_Count number := i_f_Quiz_Ids.Count;
  begin
    for r in (with Filtered_Surveys as
                 (select *
                   from (select t.Company_Id,
                                t.Survey_Id, --
                                t.Filial_Id,
                                d.Quiz_Id,
                                w.Option_Id,
                                w.Answer,
                                count(distinct case
                                         when d.Quiz_Id member of i_f_Quiz_Ids then
                                          d.Quiz_Id
                                       end) Over(partition by t.Survey_Id) Cnt
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
                          where t.Company_Id = Ui.Company_Id
                            and t.Filial_Id in (select Column_Value
                                                  from table(i_Filial_Ids))
                            and t.Status member of
                          i_Statuses
                            and t.Survey_Date between i_Begin_Date and i_End_Date
                            and d.Quiz_Id in (select Column_Value
                                                from table(i_All_Quiz_Ids))
                            and (w.Option_Id is null or
                                w.Option_Id in (select Column_Value
                                                   from table(i_All_Option_Ids)))
                            and (w.Answer is not null or w.Option_Id is not null)) q
                  where q.Cnt = v_f_Quiz_Ids_Count)
                select t.Filial_Id, --
                       t.Quiz_Id,
                       t.Option_Id,
                       max(k.Data_Kind) Data_Kind,
                       max(k.Quiz_Kind) Quiz_Kind,
                       count(1) Cnt,
                       sum(case
                              when k.Data_Kind = Hd_Pref.c_Dk_Number and k.Quiz_Kind = Hd_Pref.c_Qk_Manual then
                               t.Answer
                            end) Summ
                  from Filtered_Surveys t
                  join Hd_Quizs k
                    on t.Company_Id = k.Company_Id
                   and t.Quiz_Id = k.Quiz_Id
                 group by t.Filial_Id, t.Quiz_Id, t.Option_Id)
    
    loop
      if r.Data_Kind = Hd_Pref.c_Dk_Number and r.Quiz_Kind = Hd_Pref.c_Qk_Manual then
        v_Calc.Plus('all', r.Summ);
        v_Calc.Plus('O', r.Quiz_Id, Nvl(r.Option_Id, -1), r.Summ);
        v_Calc.Plus('Q', r.Filial_Id, r.Quiz_Id, Nvl(r.Option_Id, -1), r.Summ);
      else
        v_Calc.Plus('all', r.Cnt);
        v_Calc.Plus('O', r.Quiz_Id, Nvl(r.Option_Id, -1), r.Cnt);
        v_Calc.Plus('Q', r.Filial_Id, r.Quiz_Id, Nvl(r.Option_Id, -1), r.Cnt);
      end if;
    end loop;
  
    -- header
    a.Current_Style('header h4');
    a.New_Row;
    a.Data(t('#'));
    a.Data(t('filials'));
  
    for i in 1 .. i_s_Quiz_Ids.Count
    loop
      if i_s_Option_Ids(i).Count = 0 then
        a.Data(z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_s_Quiz_Ids(i)).Name);
      else
        x := b_Report.New_Table(a);
        x.New_Row;
        x.Data(z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_s_Quiz_Ids(i)).Name,
               i_Colspan       => i_s_Option_Ids(i).Count);
        x.New_Row;
      
        for j in 1 .. i_s_Option_Ids(i).Count
        loop
          x.Data(z_Hd_Quiz_Options.Load(i_Company_Id => Ui.Company_Id, i_Option_Id => i_s_Option_Ids(i)(j)).Name);
        end loop;
      
        a.Data(x);
      end if;
    end loop;
  
    -- body
    a.Current_Style('body');
    for r in (select t.Filial_Id, t.Name
                from Md_Filials t
               where t.Company_Id = Ui.Company_Id
                 and t.Filial_Id <> Ui.Filial_Head
                 and t.Filial_Id in (select Column_Value
                                       from table(i_Filial_Ids))
               order by t.Order_No, Lower(t.Name), t.Filial_Id)
    loop
      a.New_Row;
      v_Row_Count := v_Row_Count + 1;
      a.Data(v_Row_Count, i_Style_Name => 'body number');
      a.Data(r.Name);
    
      for i in 1 .. i_s_Quiz_Ids.Count
      loop
        if i_s_Option_Ids(i).Count = 0 then
          a.Data(Nullif(v_Calc.Get_Value('Q', r.Filial_Id, i_s_Quiz_Ids(i), -1), 0),
                 i_Style_Name => 'body number');
        else
          x := b_Report.New_Table(a);
          x.New_Row;
        
          for j in 1 .. i_s_Option_Ids(i).Count
          loop
            x.Data(Nullif(v_Calc.Get_Value('Q',
                                           r.Filial_Id,
                                           i_s_Quiz_Ids(i),
                                           i_s_Option_Ids(i) (j)),
                          0),
                   i_Style_Name => 'body number');
          end loop;
        
          a.Data(x);
        end if;
      end loop;
    end loop;
  
    -- footer
    a.Current_Style('footer');
    a.New_Row;
    a.Data(t('grand total'), 'footer right', i_Colspan => 2);
  
    for i in 1 .. i_s_Quiz_Ids.Count
    loop
      if i_s_Option_Ids(i).Count = 0 then
        a.Data(Nullif(v_Calc.Get_Value('O', i_s_Quiz_Ids(i), -1), 0),
               i_Style_Name => 'footer number');
      else
        x := b_Report.New_Table(a);
        x.New_Row;
      
        for j in 1 .. i_s_Option_Ids(i).Count
        loop
          x.Data(Nullif(v_Calc.Get_Value('O', i_s_Quiz_Ids(i), i_s_Option_Ids(i) (j)), 0),
                 i_Style_Name => 'footer number');
        end loop;
      
        a.Data(x);
      end if;
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Quiz
  (
    a                in out b_Table,
    i_Begin_Date     date,
    i_End_Date       date,
    i_Statuses       Array_Varchar2,
    i_Filial_Ids     Array_Number,
    i_Col_Quiz_Id    number,
    i_Row_Quiz_Id    number,
    i_Col_Option_Ids Array_Number,
    i_Row_Option_Ids Array_Number,
    i_f_Quiz_Ids     Array_Number,
    i_All_Quiz_Ids   Array_Number,
    i_All_Option_Ids Array_Number
  ) is
    x                  b_Table;
    v_Calc             Calc := Calc();
    v_Row_Count        number := 0;
    v_f_Quiz_Ids_Count number := i_f_Quiz_Ids.Count;
  begin
    for r in (with Filtered_Surveys as
                 (select *
                   from (select t.Survey_Id, --
                                t.Filial_Id,
                                d.Quiz_Id,
                                w.Option_Id,
                                w.Answer,
                                count(distinct case
                                         when d.Quiz_Id member of i_f_Quiz_Ids then
                                          d.Quiz_Id
                                       end) Over(partition by t.Survey_Id) Cnt
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
                          where t.Company_Id = Ui.Company_Id
                            and t.Filial_Id in (select Column_Value
                                                  from table(i_Filial_Ids))
                            and t.Status member of
                          i_Statuses
                            and t.Survey_Date between i_Begin_Date and i_End_Date
                            and d.Quiz_Id in (select Column_Value
                                                from table(i_All_Quiz_Ids))
                            and (w.Option_Id is null or
                                w.Option_Id in (select Column_Value
                                                   from table(i_All_Option_Ids)))
                            and (w.Answer is not null or w.Option_Id is not null)) q
                  where q.Cnt = v_f_Quiz_Ids_Count)
                
                select Q1.Option_Id Q1_Option_Id, --
                       Q2.Option_Id Q2_Option_Id,
                       count(1) count
                  from Filtered_Surveys Q1
                  join Filtered_Surveys Q2
                    on Q2.Survey_Id = Q1.Survey_Id
                   and Q1.Quiz_Id = i_Col_Quiz_Id
                   and Q2.Quiz_Id = i_Row_Quiz_Id
                 group by Q1.Option_Id, Q2.Option_Id)
    loop
      v_Calc.Plus('t', r.Q1_Option_Id, r.Q2_Option_Id, r.Count);
      v_Calc.Plus('gt_by_row', r.Q1_Option_Id, r.Count);
      v_Calc.Plus('gt_by_col', r.Q2_Option_Id, r.Count);
      v_Calc.Plus('gt', r.Count);
    end loop;
  
    -- header
    a.Current_Style('header h4');
    a.New_Row;
    a.Data(t('#'));
    a.Data(z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_Col_Quiz_Id).Name);
  
    x := b_Report.New_Table(a);
    x.New_Row;
    x.Data(z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_Row_Quiz_Id).Name,
           i_Colspan       => i_Row_Option_Ids.Count);
    x.New_Row();
  
    for r in (select t.Name
                from Hd_Quiz_Options t
               where t.Company_Id = Ui.Company_Id
                 and t.Quiz_Id = i_Row_Quiz_Id
                 and t.Option_Id in (select Column_Value
                                       from table(i_Row_Option_Ids))
               order by t.Order_No, Lower(t.Name), t.Option_Id)
    loop
      x.Data(r.Name);
    end loop;
  
    a.Data(x);
    a.Data(t('grand total'));
  
    -- body
    a.Current_Style('body');
    for Q1 in (select t.Option_Id, t.Name
                 from Hd_Quiz_Options t
                where t.Company_Id = Ui.Company_Id
                  and t.Quiz_Id = i_Col_Quiz_Id
                  and t.Option_Id in (select Column_Value
                                        from table(i_Col_Option_Ids))
                order by t.Order_No, Lower(t.Name), t.Option_Id)
    loop
      a.New_Row;
      v_Row_Count := v_Row_Count + 1;
      a.Data(v_Row_Count, i_Style_Name => 'body number');
      a.Data(Q1.Name);
    
      x := b_Report.New_Table(a);
      x.New_Row;
      for Q2 in (select t.Option_Id, t.Name
                   from Hd_Quiz_Options t
                  where t.Company_Id = Ui.Company_Id
                    and t.Quiz_Id = i_Row_Quiz_Id
                    and t.Option_Id in (select Column_Value
                                          from table(i_Row_Option_Ids))
                  order by t.Order_No, Lower(t.Name), t.Option_Id)
      loop
        x.Data(Nullif(v_Calc.Get_Value('t', Q1.Option_Id, Q2.Option_Id), 0),
               i_Style_Name => 'body number');
      end loop;
      a.Data(x);
      a.Data(Nullif(v_Calc.Get_Value('gt_by_row', Q1.Option_Id), 0),
             i_Style_Name => 'body middle number');
    end loop;
  
    -- footer
    a.Current_Style('footer');
    a.New_Row;
    a.Data(t('grand total'), 'footer right', i_Colspan => 2);
  
    x := b_Report.New_Table(a);
    x.New_Row;
    for Q2 in (select t.Option_Id, t.Name
                 from Hd_Quiz_Options t
                where t.Company_Id = Ui.Company_Id
                  and t.Quiz_Id = i_Row_Quiz_Id
                  and t.Option_Id in (select Column_Value
                                        from table(i_Row_Option_Ids))
                order by t.Order_No, Lower(t.Name), t.Option_Id)
    loop
      x.Data(Nullif(v_Calc.Get_Value('gt_by_col', Q2.Option_Id), 0),
             i_Style_Name => 'footer number');
    end loop;
    a.Data(x);
    a.Data(Nullif(v_Calc.Get_Value('gt'), 0), i_Style_Name => 'footer number');
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run_Document
  (
    a              in out b_Table,
    i_Begin_Date   date,
    i_End_Date     date,
    i_Statuses     Array_Varchar2,
    i_Filial_Ids   Array_Number,
    i_s_Quiz_Ids   Array_Number,
    i_s_Option_Ids Matrix_Number,
    i_f_Quiz_Ids   Array_Number,
    i_f_Option_Ids Array_Number
  ) is
    v_Calc               Calc := Calc;
    v_Row_Count          number := 0;
    v_f_Quiz_Ids_Count   number := i_f_Quiz_Ids.Count;
    v_f_Option_Ids_Count number := i_f_Option_Ids.Count;
    v_Cache              Fazo.Boolean_Id_Aat;
  
    --------------------------------------------------
    Function Is_Number(i_Quiz_Id number) return boolean is
      r_Quiz Hd_Quizs%rowtype;
    begin
      return v_Cache(i_Quiz_Id);
    
    exception
      when No_Data_Found then
        r_Quiz := z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_Quiz_Id);
        if r_Quiz.Data_Kind = Hd_Pref.c_Dk_Number and r_Quiz.Quiz_Kind = Hd_Pref.c_Qk_Manual then
          v_Cache(i_Quiz_Id) := true;
          return true;
        else
          v_Cache(i_Quiz_Id) := false;
          return false;
        end if;
    end;
  
    --------------------------------------------------
    Function Get_Answer
    (
      i_Survey_Id number,
      i_Quiz_Id   number
    ) return varchar2 is
      v_Answers    Array_Varchar2;
      v_Option_Ids Array_Number;
    begin
      select Nvl(w.Answer,
                 (select g.Name
                    from Hd_Quiz_Options g
                   where g.Company_Id = Ui.Company_Id
                     and g.Option_Id = w.Option_Id)),
             w.Option_Id
        bulk collect
        into v_Answers, v_Option_Ids
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
       where t.Company_Id = Ui.Company_Id
         and t.Survey_Id = i_Survey_Id
         and d.Quiz_Id = i_Quiz_Id
         and (w.Answer is not null or w.Option_Id is not null);
    
      for i in 1 .. v_Answers.Count
      loop
        if Is_Number(i_Quiz_Id) then
          v_Calc.Plus(i_Quiz_Id, to_number(v_Answers(i)));
        end if;
      
        if v_Option_Ids(i) is not null then
          v_Calc.Plus('A', i_Quiz_Id, v_Option_Ids(i), 1);
          v_Calc.Plus('A', i_Quiz_Id, -1, 1);
        end if;
      end loop;
    
      return Fazo.Gather(v_Answers, ', ');
    end;
  begin
    -- header
    a.Current_Style('header');
    a.New_Row;
    a.Data(t('#'));
    a.Data(t('survey id'));
    a.Data(t('survey number'));
    a.Data(t('status'));
    a.Data(t('survey date'));
    a.Data(t('filial_name'));
  
    for i in 1 .. i_s_Quiz_Ids.Count
    loop
      a.Data(z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_s_Quiz_Ids(i)).Name);
    end loop;
  
    -- body
    a.Current_Style('body');
  
    for r in (with Filtered_Surveys as
                 (select *
                   from (select t.Survey_Id, --
                                t.Filial_Id,
                                t.Survey_Number,
                                t.Survey_Date,
                                t.Status,
                                d.Quiz_Id,
                                w.Option_Id,
                                w.Answer,
                                count(distinct case
                                         when d.Quiz_Id member of i_f_Quiz_Ids then
                                          d.Quiz_Id
                                       end) Over(partition by t.Survey_Id) Cnt
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
                          where t.Company_Id = Ui.Company_Id
                            and t.Filial_Id in (select Column_Value
                                                  from table(i_Filial_Ids))
                            and t.Status member of
                          i_Statuses
                            and t.Survey_Date between i_Begin_Date and i_End_Date
                            and (v_f_Quiz_Ids_Count = 0 or
                                d.Quiz_Id in (select Column_Value
                                                 from table(i_f_Quiz_Ids)))
                            and (w.Option_Id is null or v_f_Option_Ids_Count = 0 or
                                w.Option_Id in (select Column_Value
                                                   from table(i_f_Option_Ids)))) q
                  where q.Cnt = v_f_Quiz_Ids_Count)
                select t.*
                  from Hdf_Surveys t
                 where exists (select 1
                          from Filtered_Surveys k
                         where t.Company_Id = Ui.Company_Id
                           and t.Survey_Id = k.Survey_Id))
    loop
      v_Row_Count := v_Row_Count + 1;
    
      a.New_Row;
      a.Data(v_Row_Count, 'body number');
      a.Data(r.Survey_Id, 'body right');
      a.Data(r.Survey_Number);
      a.Data(r.Status, 'body center');
      a.Data(r.Survey_Date, 'body center');
      a.Data(z_Md_Filials.Load(i_Company_Id => Ui.Company_Id, i_Filial_Id => r.Filial_Id).Name);
    
      for i in 1 .. i_s_Quiz_Ids.Count
      loop
        if Is_Number(i_s_Quiz_Ids(i)) then
          a.Data(Get_Answer(r.Survey_Id, i_s_Quiz_Ids(i)), 'body number');
        else
          a.Data(Get_Answer(r.Survey_Id, i_s_Quiz_Ids(i)));
        end if;
      end loop;
    end loop;
  
    -- footer
    a.Current_Style('footer');
    a.New_Row;
    a.Data(t('total'), 'footer right', i_Colspan => 6);
  
    a.Current_Style('footer number');
  
    for i in 1 .. i_s_Quiz_Ids.Count
    loop
      a.Data(Nullif(v_Calc.Get_Value(i_s_Quiz_Ids(i)), 0));
    end loop;
  
    -- table of grand totals
    a.New_Row;
    a.New_Row;
    a.New_Row;
    a.Data(t('total by quizs'), 'root bold h4', i_Colspan => 3);
    a.Current_Style('header');
    a.New_Row;
    a.Data(t('quiz'));
    a.Data(t('option'));
    a.Data(t('count'));
  
    a.Current_Style('body');
  
    for i in 1 .. i_s_Quiz_Ids.Count
    loop
      if i_s_Option_Ids(i).Count > 0 then
        for j in 1 .. i_s_Option_Ids(i).Count
        loop
          a.New_Row;
          if j = 1 then
            a.Data(z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id, i_Quiz_Id => i_s_Quiz_Ids(i)).Name,
                   i_Rowspan       => i_s_Option_Ids(i).Count + 1);
          end if;
          a.Data(z_Hd_Quiz_Options.Load(i_Company_Id => Ui.Company_Id, i_Option_Id => i_s_Option_Ids(i)(j)).Name);
          a.Data(v_Calc.Get_Value('A', i_s_Quiz_Ids(i), i_s_Option_Ids(i) (j)), 'body number');
        end loop;
        a.New_Row;
        a.Data(t('total'), 'footer right');
        a.Data(v_Calc.Get_Value('A', i_s_Quiz_Ids(i), -1), 'footer number');
      end if;
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run(p Hashmap) is
    r_Template Hdr_Templates%rowtype;
  
    v_Filial_Ids       Array_Number := p.o_Array_Number('filial_ids');
    v_Filial_Names     varchar2(4000 char);
    t_All_Filial_Names varchar2(100) := t('all available filials');
  
    v_s_Quiz_Ids   Array_Number;
    v_s_Option_Ids Matrix_Number;
  
    v_f_Quiz_Ids       Array_Number := Array_Number();
    v_f_Option_Ids     Matrix_Number;
    v_f_All_Option_Ids Array_Number := Array_Number();
  
    v_All_Quiz_Ids   Array_Number := Array_Number();
    v_All_Option_Ids Array_Number := Array_Number();
  
    Main b_Table;
    a    b_Table;
  begin
    r_Template := z_Hdr_Templates.Load(i_Company_Id  => Ui.Company_Id,
                                       i_Template_Id => p.r_Number('template_id'));
  
    if Ui.Is_Filial_Head then
      select cast(collect(to_number(t.Filial_Id) order by t.Order_No, Lower(t.Name), t.Filial_Id) as
                  Array_Number),
             case
               when v_Filial_Ids is null then
                t_All_Filial_Names
               else
                Listagg(t.Name, ', ' on Overflow Truncate '...') Within
                group(order by t.Order_No, Lower(t.Name), t.Filial_Id)
             end
        into v_Filial_Ids, v_Filial_Names
        from Md_Filials t
       where t.Company_Id = Ui.Company_Id
         and t.Filial_Id <> Ui.Filial_Head
         and (v_Filial_Ids is null or
             t.Filial_Id in (select Column_Value
                                from table(v_Filial_Ids)))
         and State = 'A'
         and exists (select 1
                from Md_User_Filials k
               where k.Company_Id = t.Company_Id
                 and k.User_Id = Ui.User_Id
                 and k.Filial_Id = t.Filial_Id);
    else
      v_Filial_Ids := Array_Number(Ui.Filial_Id);
    end if;
  
    Parse_Setting(r_Template, v_s_Quiz_Ids, v_s_Option_Ids);
    Parse_Filter(Fazo.Parse_Array(p.o_Varchar2('quizs')), v_f_Quiz_Ids, v_f_Option_Ids);
  
    v_All_Quiz_Ids := set(v_s_Quiz_Ids multiset union v_f_Quiz_Ids);
  
    for i in 1 .. v_s_Option_Ids.Count
    loop
      v_All_Option_Ids := v_All_Option_Ids multiset union v_s_Option_Ids(i);
    end loop;
  
    for i in 1 .. v_f_Option_Ids.Count
    loop
      v_All_Option_Ids   := v_All_Option_Ids multiset union v_f_Option_Ids(i);
      v_f_All_Option_Ids := v_f_All_Option_Ids multiset union v_f_Option_Ids(i);
    end loop;
  
    b_Report.Open_Book_With_Styles(i_Report_Type => p.r_Varchar2('rt'),
                                   i_File_Name   => replace(r_Template.Name, ' ', '-') || '(' ||
                                                    to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss') || ')');
  
    -- h1, h2, h3, h4, h5, h6
    b_Report.New_Style(i_Style_Name => 'h1', i_Font_Size => '12');
    b_Report.New_Style(i_Style_Name => 'h2', i_Font_Size => '11');
    b_Report.New_Style(i_Style_Name => 'h3', i_Font_Size => '10');
    b_Report.New_Style(i_Style_Name => 'h4', i_Font_Size => '9');
    b_Report.New_Style(i_Style_Name => 'h5', i_Font_Size => '8');
    b_Report.New_Style(i_Style_Name => 'h6', i_Font_Size => '7');
  
    Main := b_Report.New_Table();
    a    := b_Report.New_Table();
  
    Print_Header_Info(Main,
                      r_Template.Name,
                      v_Filial_Names,
                      p.r_Date('begin_date'),
                      p.r_Date('end_date'),
                      v_f_Quiz_Ids,
                      v_f_Option_Ids);
  
    case r_Template.Template_Kind
      when Hdr_Pref.c_Across_Filials then
        Run_Filial(a                => a,
                   i_Begin_Date     => p.r_Date('begin_date'),
                   i_End_Date       => p.r_Date('end_date'),
                   i_Statuses       => p.r_Array_Varchar2('statuses'),
                   i_Filial_Ids     => v_Filial_Ids,
                   i_s_Quiz_Ids     => v_s_Quiz_Ids,
                   i_s_Option_Ids   => v_s_Option_Ids,
                   i_f_Quiz_Ids     => v_f_Quiz_Ids,
                   i_All_Quiz_Ids   => v_All_Quiz_Ids,
                   i_All_Option_Ids => v_All_Option_Ids);
      
      when Hdr_Pref.c_Across_Quizs then
        Run_Quiz(a                => a,
                 i_Begin_Date     => p.r_Date('begin_date'),
                 i_End_Date       => p.r_Date('end_date'),
                 i_Statuses       => p.r_Array_Varchar2('statuses'),
                 i_Filial_Ids     => v_Filial_Ids,
                 i_Col_Quiz_Id    => v_s_Quiz_Ids(1),
                 i_Row_Quiz_Id    => v_s_Quiz_Ids(2),
                 i_Col_Option_Ids => v_s_Option_Ids(1),
                 i_Row_Option_Ids => v_s_Option_Ids(2),
                 i_f_Quiz_Ids     => v_f_Quiz_Ids,
                 i_All_Quiz_Ids   => v_All_Quiz_Ids,
                 i_All_Option_Ids => v_All_Option_Ids);
      
      when Hdr_Pref.c_Across_Documents then
        Run_Document(a              => a,
                     i_Begin_Date   => p.r_Date('begin_date'),
                     i_End_Date     => p.r_Date('end_date'),
                     i_Statuses     => p.r_Array_Varchar2('statuses'),
                     i_Filial_Ids   => v_Filial_Ids,
                     i_s_Quiz_Ids   => v_s_Quiz_Ids,
                     i_s_Option_Ids => v_s_Option_Ids,
                     i_f_Quiz_Ids   => v_f_Quiz_Ids,
                     i_f_Option_Ids => v_f_All_Option_Ids);
    end case;
    Main.New_Row;
    Main.Data(a);
  
    b_Report.Add_Sheet(replace(r_Template.Name, ' ', '-'), Main);
    b_Report.Close_Book;
  end;
end Ui_Helpdesk39;
/
