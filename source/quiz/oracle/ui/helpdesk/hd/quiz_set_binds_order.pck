create or replace package Ui_Helpdesk21 is
  ----------------------------------------------------------------------------------------------------
  Function Model(p Hashmap) return Arraylist;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Order(p Hashmap);
  ----------------------------------------------------------------------------------------------------
end Ui_Helpdesk21;
/
create or replace package body Ui_Helpdesk21 is
  ----------------------------------------------------------------------------------------------------
  Function Model(p Hashmap) return Arraylist is
    v_Quiz_Set_Id number := p.r_Number('quiz_set_id');
    v_Matrix      Matrix_Varchar2;
  begin
    select Array_Varchar2(q.Quiz_Id,
                          (select k.Name
                             from Hd_Quizs k
                            where k.Company_Id = q.Company_Id
                              and k.Quiz_Id = q.Quiz_Id),
                          q.Order_No)
      bulk collect
      into v_Matrix
      from Hd_Quiz_Set_Binds q
     where q.Company_Id = Ui.Company_Id
       and q.Quiz_Set_Id = v_Quiz_Set_Id
     order by q.Order_No;
  
    return Fazo.Zip_Matrix(v_Matrix);
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Set_Order(p Hashmap) is
    r_Data        Hd_Quiz_Set_Binds%rowtype;
    v_Quiz_Set_Id number := p.r_Number('quiz_set_id');
    v_List        Arraylist := p.r_Arraylist('quizs');
    v_List_Item   Hashmap;
  begin
    for i in 1 .. v_List.Count
    loop
      v_List_Item := Treat(v_List.r_Hashmap(i) as Hashmap);
    
      r_Data          := z_Hd_Quiz_Set_Binds.Lock_Load(i_Company_Id  => Ui.Company_Id,
                                                       i_Quiz_Set_Id => v_Quiz_Set_Id,
                                                       i_Quiz_Id     => v_List_Item.r_Number('quiz_id'));
      r_Data.Order_No := v_List_Item.o_Number('order_no');
    
      Hd_Api.Quiz_Set_Bind_Save(r_Data);
    end loop;
  end;

end Ui_Helpdesk21;
/
