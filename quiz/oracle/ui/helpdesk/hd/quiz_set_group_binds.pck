create or replace package Ui_Helpdesk18 is
  ----------------------------------------------------------------------------------------------------
  Function Query(p Hashmap) return Fazo_Query;
  ----------------------------------------------------------------------------------------------------
  Procedure Attach(p Hashmap);
  ----------------------------------------------------------------------------------------------------
  Procedure Detach(p Hashmap);
end Ui_Helpdesk18;
/
create or replace package body Ui_Helpdesk18 is
  ----------------------------------------------------------------------------------------------------
  Function Query(p Hashmap) return Fazo_Query is
    q       Fazo_Query;
    v_Query varchar2(4000);
  begin
    v_Query := 'select *
                  from hd_quiz_sets s
                 where s.company_Id = :company_id
                   and';
  
    if p.o_Varchar2('attached') = 'N' then
      v_Query := v_Query || ' not';
    end if;
  
    v_Query := v_Query || ' exists (select 1
                                      from hd_quiz_set_group_binds k
                                     where k.company_id = s.company_id
                                       and k.quiz_set_group_id = :quiz_set_group_id
                                       and k.quiz_set_id = s.quiz_set_id)';
  
    q := Fazo_Query(v_Query,
                    Fazo.Zip_Map('company_id',
                                 Ui.Company_Id,
                                 'quiz_set_group_id',
                                 p.r_Number('quiz_set_group_id')));
  
    q.Number_Field('quiz_set_id');
    q.Varchar2_Field('name', 'description', 'state');
    q.Option_Field('state_name',
                   'state',
                   Array_Varchar2('A', 'P'),
                   Array_Varchar2(Ui.t_Active, Ui.t_Passive));
  
    q.Map_Field('order_no',
                '(select k.order_no
                    from hd_quiz_set_group_binds k
                   where k.company_id = :company_id
                     and k.quiz_set_id = $quiz_set_id
                     and k.quiz_set_group_id = :quiz_set_group_id)',
                Fazo_Schema.Fazo_Util.c_f_Number);
    return q;
  end;

  -----------------------------------------------------------------------------------------------------
  Procedure Attach(p Hashmap) is
    r_Data         Hd_Quiz_Set_Group_Binds%rowtype;
    v_Quiz_Set_Ids Array_Number := p.r_Array_Number('quiz_set_ids');
  begin
    r_Data.Company_Id        := Ui.Company_Id;
    r_Data.Quiz_Set_Group_Id := p.r_Number('quiz_set_group_id');
  
    for i in 1 .. v_Quiz_Set_Ids.Count
    loop
      r_Data.Quiz_Set_Id := v_Quiz_Set_Ids(i);
    
      Hd_Api.Quiz_Set_Group_Bind_Save(r_Data);
    end loop;
  end;

  -----------------------------------------------------------------------------------------------------
  Procedure Detach(p Hashmap) is
    v_Quiz_Set_Ids      Array_Number := p.r_Array_Number('quiz_set_ids');
    v_Quiz_Set_Group_Id number := p.r_Number('quiz_set_group_id');
  begin
  
    for i in 1 .. v_Quiz_Set_Ids.Count
    loop
      Hd_Api.Quiz_Set_Group_Bind_Delete(i_Company_Id        => Ui.Company_Id,
                                        i_Quiz_Set_Group_Id => v_Quiz_Set_Group_Id,
                                        i_Quiz_Set_Id       => v_Quiz_Set_Ids(i));
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
  
    update Hd_Quiz_Set_Group_Binds
       set Company_Id        = null,
           Quiz_Set_Group_Id = null,
           Quiz_Set_Id       = null,
           Order_No          = null;
  end;

end Ui_Helpdesk18;
/
