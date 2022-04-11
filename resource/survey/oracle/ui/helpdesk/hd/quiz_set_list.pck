create or replace package Ui_Helpdesk16 is
  ----------------------------------------------------------------------------------------------------  
  Function Query return Fazo_Query;
  ----------------------------------------------------------------------------------------------------  
  Procedure Del(p Hashmap);
  ----------------------------------------------------------------------------------------------------  
end Ui_Helpdesk16;
/
create or replace package body Ui_Helpdesk16 is
  ----------------------------------------------------------------------------------------------------  
  Function Query return Fazo_Query is
    q Fazo_Query;
  begin
    q := Fazo_Query('hd_quiz_sets', Fazo.Zip_Map('company_id', Ui.Company_Id), true);
  
    q.Number_Field('quiz_set_id');
    q.Varchar2_Field('name', 'state', 'description');
  
    q.Option_Field('state_name',
                   'state',
                   Array_Varchar2('A', 'P'),
                   Array_Varchar2(Ui.t_Active, Ui.t_Passive));
  
    q.Map_Field('child_quiz_count',
                '(select count(*)
                    from hd_quiz_set_binds w
                   where w.company_id = :company_id
                     and w.quiz_set_id = $quiz_set_id)',
                     fazo_schema.fazo_util.c_f_Number);
  
    return q;
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Del(p Hashmap) is
    v_Quiz_Set_Ids Array_Number := p.r_Array_Number('quiz_set_id');
  begin
    for i in 1 .. v_Quiz_Set_Ids.Count
    loop
      Hd_Api.Quiz_Set_Delete(i_Company_Id => Ui.Company_Id, i_Quiz_Set_Id => v_Quiz_Set_Ids(i));
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Validation is
  begin
    update Hd_Quiz_Sets
       set Company_Id  = null,
           Quiz_Set_Id = null,
           name        = null,
           State       = null,
           Description = null;
  
    update Hd_Quiz_Set_Binds
       set Company_Id  = null,
           Quiz_Set_Id = null,
           Quiz_Id     = null,
           Order_No    = null;
  
  end;

end Ui_Helpdesk16;
/
