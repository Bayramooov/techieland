create or replace package Ui_Helpdesk17 is
  ----------------------------------------------------------------------------------------------------
  Function Query(p Hashmap) return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Procedure Attach(p Hashmap);
  ----------------------------------------------------------------------------------------------------
  Procedure Detach(p Hashmap);
  ----------------------------------------------------------------------------------------------------
end Ui_Helpdesk17;
/
create or replace package body Ui_Helpdesk17 is
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
    return b.Translate('UI-HELPDESK17:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Query(p Hashmap) return Fazo_Query is
    q       Fazo_Query;
    v_Query varchar2(4000);
  begin
    v_Query := 'select *
                  from hd_quizs q
                 where q.company_id = :company_id
                   and';
  
    if p.o_Varchar2('attached') = 'N' then
      v_Query := v_Query || ' not';
    end if;
  
    v_Query := v_Query || ' exists (select 1
                                      from hd_quiz_set_binds k
                                     where k.company_id = q.company_id
                                       and k.quiz_set_id = :quiz_set_id
                                       and k.quiz_id = q.quiz_id)';
  
    q := Fazo_Query(v_Query,
                    Fazo.Zip_Map('company_id',
                                 Ui.Company_Id,
                                 'quiz_set_id',
                                 p.r_Number('quiz_set_id')));
  
    q.Number_Field('quiz_id', 'min_scale', 'max_scale');
    q.Varchar2_Field('name', 'state', 'data_kind', 'quiz_kind', 'select_multiple', 'select_form');
  
    q.Option_Field('state_name',
                   'state',
                   Array_Varchar2('A', 'P'),
                   Array_Varchar2(Ui.t_Active, Ui.t_Passive));
  
    q.Option_Field('data_kind_name',
                   'data_kind',
                   Array_Varchar2(Hd_Pref.c_Dk_Number,
                                  Hd_Pref.c_Dk_Date,
                                  Hd_Pref.c_Dk_Short_Text,
                                  Hd_Pref.c_Dk_Long_Text,
                                  Hd_Pref.c_Dk_Boolean),
                   Array_Varchar2(t('dk_number'), --
                                  t('dk_date'),
                                  t('dk_short_text'),
                                  t('dk_long_text'),
                                  t('dk_boolean')));
  
    q.Option_Field('quiz_kind_name',
                   'quiz_kind',
                   Array_Varchar2(Hd_Pref.c_Qk_Manual,
                                  Hd_Pref.c_Qk_Select,
                                  Hd_Pref.c_Qk_Select_By_Value),
                   Array_Varchar2(t('qk_manual'), --
                                  t('qk_select'),
                                  t('qk_select_by_value')));
  
    q.Option_Field('select_multiple_name',
                   'select_multiple',
                   Array_Varchar2('Y', 'N'),
                   Array_Varchar2(Ui.t_Yes, Ui.t_No));
  
    q.Option_Field('select_form_name',
                   'select_form',
                   Array_Varchar2(Hd_Pref.c_Sf_Check_Box,
                                  Hd_Pref.c_Sf_Radio_Button,
                                  Hd_Pref.c_Sf_Drop_Down),
                   Array_Varchar2(t('sf_check-box'), --
                                  t('sf_radio_button'),
                                  t('sf_drop-down')));
  
    q.Map_Field('order_no',
                '(select order_no
                    from hd_quiz_set_binds
                   where company_id = :company_id
                     and quiz_set_id = :quiz_set_id
                     and quiz_id = $quiz_id)',
                fazo_schema.fazo_util.c_f_Number);
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Attach(p Hashmap) is
    r_Data     Hd_Quiz_Set_Binds%rowtype;
    v_Quiz_Ids Array_Number := p.r_Array_Number('quiz_ids');
  begin
    r_Data.Company_Id  := Ui.Company_Id;
    r_Data.Quiz_Set_Id := p.r_Number('quiz_set_id');
    
    for i in 1 .. v_Quiz_Ids.Count
    loop
      r_Data.Quiz_Id  := v_Quiz_Ids(i);
      Hd_Api.Quiz_Set_Bind_Save(r_Data);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Detach(p Hashmap) is
    v_Quiz_Ids    Array_Number := p.r_Array_Number('quiz_ids');
    v_Quiz_Set_Id number := p.r_Number('quiz_set_id');
  begin
    for i in 1 .. v_Quiz_Ids.Count
    loop
      Hd_Api.Quiz_Set_Bind_Delete(i_Company_Id  => Ui.Company_Id,
                                  i_Quiz_Set_Id => v_Quiz_Set_Id,
                                  i_Quiz_Id     => v_Quiz_Ids(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Validation is
  begin
    update Hd_Quizs
       set Company_Id      = null,
           Quiz_Id         = null,
           name            = null,
           State           = null,
           Data_Kind       = null,
           Quiz_Kind       = null,
           Select_Multiple = null,
           Select_Form     = null,
           Min_Scale       = null,
           Max_Scale       = null;
  
    update Hd_Quiz_Set_Binds
       set Company_Id  = null,
           Quiz_Set_Id = null,
           Quiz_Id     = null,
           Order_No    = null;
  end;

end Ui_Helpdesk17;
/
