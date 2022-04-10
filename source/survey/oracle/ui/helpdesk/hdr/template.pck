create or replace package Ui_Helpdesk38 is
  ----------------------------------------------------------------------------------------------------
  Function Query_Quizs return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Function Query_Quiz_Options return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Function Add_Model return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Edit_Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Procedure save(p Hashmap);
end Ui_Helpdesk38;
/
create or replace package body Ui_Helpdesk38 is
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
    return b.Translate('UI-Helpdesk38:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
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
  Function Add_Model return Hashmap is
    result  Hashmap;
    Setting Hashmap := Hashmap();
  begin
    result := Fazo.Zip_Map('state', 'A', 'template_kind', Hdr_Pref.c_Across_Filials);
    Setting.Put('quizs', Arraylist());
    Result.Put('template_setting', Setting);
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Load_Template_Setting(i_Setting Hashmap) return Hashmap is
    r_Quiz       Hd_Quizs%rowtype;
    r_Option     Hd_Quiz_Options%rowtype;
    v_Quiz_List  Arraylist;
    v_Quiz       Hashmap;
    v_Quizs      Arraylist := Arraylist();
    v_Option_Ids Array_Number;
    v_Options    Arraylist;
    v_Data       Hashmap;
    result       Hashmap := Hashmap();
  begin
    v_Quiz_List := i_Setting.r_Arraylist('quizs');
  
    for i in 1 .. v_Quiz_List.Count
    loop
      v_Data := Treat(v_Quiz_List.r_Hashmap(i) as Hashmap);
      r_Quiz := z_Hd_Quizs.Load(i_Company_Id => Ui.Company_Id,
                                i_Quiz_Id    => v_Data.r_Number('quiz_id'));
    
      v_Quiz := Fazo.Zip_Map('quiz_id',
                             r_Quiz.Quiz_Id,
                             'quiz_data_kind',
                             r_Quiz.Data_Kind,
                             'quiz_kind',
                             r_Quiz.Quiz_Kind,
                             'quiz_name',
                             r_Quiz.Name);
    
      if r_Quiz.Quiz_Kind <> Hd_Pref.c_Qk_Manual then
        v_Option_Ids := v_Data.r_Array_Number('options');
        v_Options    := Arraylist();
      
        if v_Option_Ids.Count < 1 then
          v_Quiz.Put('is_all_options', 'Y');
        else
          for j in 1 .. v_Option_Ids.Count
          loop
            r_Option := z_Hd_Quiz_Options.Load(i_Company_Id => Ui.Company_Id,
                                               i_Option_Id  => v_Option_Ids(j));
          
            v_Options.Push(z_Hd_Quiz_Options.To_Map(r_Option, z.Option_Id, z.Name));
          end loop;
        
          v_Quiz.Put('is_all_options', 'N');
        end if;
      
        v_Quiz.Put('options', v_Options);
      end if;
    
      v_Quizs.Push(v_Quiz);
    end loop;
  
    Result.Put('quizs', v_Quizs);
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Edit_Model(p Hashmap) return Hashmap is
    r_Template Hdr_Templates%rowtype;
    v_Setting  Hashmap;
    result     Hashmap;
  begin
    r_Template := z_Hdr_Templates.Load(i_Company_Id  => Ui.Company_Id,
                                       i_Template_Id => p.r_Number('template_id'));
    v_Setting  := Fazo.Parse_Map(r_Template.Setting);
  
    result := z_Hdr_Templates.To_Map(r_Template,
                                     z.Template_Id,
                                     z.Name,
                                     z.Description,
                                     z.Template_Kind,
                                     z.State);
    Result.Put('template_setting', Load_Template_Setting(v_Setting));
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure save(p Hashmap) is
    r_Template Hdr_Templates%rowtype;
  begin
    r_Template            := z_Hdr_Templates.To_Row(p,
                                                    z.Template_Id,
                                                    z.Name,
                                                    z.Description,
                                                    z.Template_Kind,
                                                    z.State,
                                                    z.Setting);
    r_Template.Company_Id := Ui.Company_Id;
    if r_Template.Template_Id is null then
      r_Template.Template_Id := Hdr_Next.Template_Id;
    end if;
  
    Hdr_Api.Template_Save(r_Template);
  end;
end Ui_Helpdesk38;
/
