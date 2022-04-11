create or replace package Ui_Helpdesk7 is
  ----------------------------------------------------------------------------------------------------  
  Function Query return Fazo_Query;
  ----------------------------------------------------------------------------------------------------  
  Procedure Del(p Hashmap);
end Ui_Helpdesk7;
/
create or replace package body Ui_Helpdesk7 is
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
    return b.Translate('UI-HELPDESK7:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Query return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hd_quizs', Fazo.Zip_Map('company_id', Ui.Company_Id), true);
  
    q.Varchar2_Field('name',
                     'state',
                     'data_kind',
                     'quiz_kind',
                     'select_multiple',
                     'select_form',
                     'is_required');
    q.Number_Field('quiz_id', 'min_scale', 'max_scale');
  
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
                                  t('dk_short text'),
                                  t('dk_long text'),
                                  t('dk_boolean')));
  
    q.Option_Field('quiz_kind_name',
                   'quiz_kind',
                   Array_Varchar2(Hd_Pref.c_Qk_Manual,
                                  Hd_Pref.c_Qk_Select,
                                  Hd_Pref.c_Qk_Select_By_Value),
                   Array_Varchar2(t('qk_manual'), --
                                  t('qk_select'),
                                  t('qk_select by value')));
  
    q.Option_Field('select_multiple_name',
                   'select_multiple',
                   Array_Varchar2('Y', 'N'),
                   Array_Varchar2(Ui.t_Yes, Ui.t_No));
  
    q.Option_Field('select_form_name',
                   'select_form',
                   Array_Varchar2(Hd_Pref.c_Sf_Check_Box,
                                  Hd_Pref.c_Sf_Radio_Button,
                                  Hd_Pref.c_Sf_Drop_Down),
                   Array_Varchar2(t('sf_check_box'),
                                  t('sf_radio-button'),
                                  t('sf_select with value')));
  
    q.Option_Field('is_required_name',
                   'is_required',
                   Array_Varchar2('Y', 'N'),
                   Array_Varchar2(Ui.t_Yes, Ui.t_No));
    return q;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Del(p Hashmap) is
    v_Quiz_Ids Array_Number := p.r_Array_Number('quiz_id');
  begin
    for i in 1 .. v_Quiz_Ids.Count
    loop
      Hd_Api.Quiz_Delete(i_Company_Id => Ui.Company_Id, i_Quiz_Id => v_Quiz_Ids(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Validation is
  begin
    update Hd_Quizs
       set Quiz_Id         = null,
           name            = null,
           State           = null,
           Data_Kind       = null,
           Select_Multiple = null,
           Select_Form     = null,
           Min_Scale       = null,
           Max_Scale       = null,
           Quiz_Kind       = null;
  end;

end Ui_Helpdesk7;
/
