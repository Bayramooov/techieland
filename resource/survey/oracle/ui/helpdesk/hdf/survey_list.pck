create or replace package Ui_Helpdesk23 is
  ----------------------------------------------------------------------------------------------------  
  Function Model return Hashmap;
  ----------------------------------------------------------------------------------------------------  
  Function Query return Fazo_Query;
end Ui_Helpdesk23;
/
create or replace package body Ui_Helpdesk23 is
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
    return b.Translate('UI-HELPDESK23:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Model return Hashmap is
    result           Hashmap;
    r_Quiz_Set_Group Hd_Quiz_Set_Groups%rowtype;
  begin
    select *
      into r_Quiz_Set_Group
      from Hd_Quiz_Set_Groups t
     where t.Company_Id = Ui.Company_Id
       and t.State = 'A'
       and Rownum = 1;
  
    result := z_Hd_Quiz_Set_Groups.To_Map(r_Quiz_Set_Group, z.Quiz_Set_Group_Id, z.Name);
  
    return result;
  
  exception
    when No_Data_Found then
      return Hashmap();
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Query return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hdf_surveys',
                    Fazo.Zip_Map('company_id', Ui.Company_Id, 'filial_id', Ui.Filial_Id),
                    true);
  
    q.Number_Field('survey_id', 'quiz_set_group_id', 'survey_number', 'created_by');
    q.Date_Field('survey_date', 'created_on');
    q.Varchar2_Field('survey_number', 'status', 'note');
    q.Option_Field('status_name',
                   'status',
                   Array_Varchar2(Hdf_Pref.c_Ss_Draft,
                                  Hdf_Pref.c_Ss_New,
                                  Hdf_Pref.c_Ss_Processing,
                                  Hdf_Pref.c_Ss_Completed),
                   Array_Varchar2(t('ss_draft'), --
                                  t('ss_new'),
                                  t('ss_processing'),
                                  t('ss_completed')));
  
    q.Refer_Field('quiz_set_group_name',
                  'quiz_set_group_id',
                  'hd_quiz_set_groups',
                  'quiz_set_group_id',
                  'name',
                  'select * from hd_quiz_set_groups t
                    where t.company_id = :company_id');
  
    q.Refer_Field('created_by_name',
                  'created_by',
                  'md_users',
                  'user_id',
                  'name',
                  'select * from md_users t
                    where t.company_id = :company_id');
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Validation is
  begin
    update Hdf_Surveys
       set Company_Id        = null,
           Survey_Id         = null,
           Filial_Id         = null,
           Quiz_Set_Group_Id = null,
           Survey_Number     = null,
           Survey_Date       = null,
           Status            = null,
           Note              = null,
           Created_By        = null,
           Created_On        = null;
  
    update Hd_Quiz_Set_Groups
       set Company_Id        = null,
           Quiz_Set_Group_Id = null,
           name              = null;
  
    update Md_Users
       set Company_Id = null,
           User_Id    = null,
           name       = null;
  end;

end Ui_Helpdesk23;
/
