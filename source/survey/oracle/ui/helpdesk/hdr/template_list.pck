create or replace package Ui_Helpdesk37 is
  ----------------------------------------------------------------------------------------------------
  Function Query return Fazo_Query;
  ----------------------------------------------------------------------------------------------------  
  Procedure Del(p Hashmap);
end Ui_Helpdesk37;
/
create or replace package body Ui_Helpdesk37 is
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
    return b.Translate('UI-Helpdesk37:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Query return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hdr_templates', Fazo.Zip_Map('company_id', Ui.Company_Id), true);
  
    q.Number_Field('template_id');
    q.Varchar2_Field('name', 'description', 'template_kind', 'state');
    q.Option_Field('state_name',
                   'state',
                   Array_Varchar2('A', 'P'),
                   Array_Varchar2(Ui.t_Active, Ui.t_Passive));
    q.Option_Field('template_kind_name',
                   'template_kind',
                   Array_Varchar2('F', 'Q', 'D'),
                   Array_Varchar2(t('across filials'), --
                                  t('across quizs'), --
                                  t('across documents')));
    return q;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Del(p Hashmap) is
    v_Template_Ids Array_Number := p.r_Array_Number('template_ids');
  begin
    for i in 1 .. v_Template_Ids.Count
    loop
      z_Hdr_Templates.Delete_One(i_Company_Id => Ui.Company_Id, i_Template_Id => v_Template_Ids(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Validation is
  begin
    update Hdr_Templates
       set Company_Id  = null,
           Template_Id = null,
           name        = null,
           Description = null,
           State       = null;
  end;
end Ui_Helpdesk37;
/
