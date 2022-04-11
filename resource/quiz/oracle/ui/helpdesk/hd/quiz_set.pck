create or replace package Ui_Helpdesk15 is
  ----------------------------------------------------------------------------------------------------
  Function Add_Model return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Edit_Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Add(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Edit(p Hashmap) return Hashmap;
end Ui_Helpdesk15;
/
create or replace package body Ui_Helpdesk15 is
  ----------------------------------------------------------------------------------------------------
  Function Add_Model return Hashmap is
  begin
    return Fazo.Zip_Map('state', 'A');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Edit_Model(p Hashmap) return Hashmap is
    r_Data Hd_Quiz_Sets%rowtype;
  begin
    r_Data := z_Hd_Quiz_Sets.Load(i_Company_Id  => Ui.Company_Id,
                                  i_Quiz_Set_Id => p.r_Number('quiz_set_id'));
  
    return z_Hd_Quiz_Sets.To_Map(r_Data, z.Quiz_Set_Id, z.Name, z.Description, z.State);
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Add(p Hashmap) return Hashmap is
    r_Data Hd_Quiz_Sets%rowtype;
  begin
    r_Data := z_Hd_Quiz_Sets.To_Row(p, z.Name, z.Description, z.State);
  
    r_Data.Company_Id  := Ui.Company_Id;
    r_Data.Quiz_Set_Id := Hd_Next.Quiz_Set_Id;
  
    Hd_Api.Quiz_Set_Save(r_Data);
  
    return z_Hd_Quiz_Sets.To_Map(r_Data, z.Quiz_Set_Id, z.Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Edit(p Hashmap) return Hashmap is
    r_Data Hd_Quiz_Sets%rowtype;
  begin
    r_Data := z_Hd_Quiz_Sets.Lock_Load(i_Company_Id  => Ui.Company_Id,
                                       i_Quiz_Set_Id => p.r_Number('quiz_set_id'));
  
    z_Hd_Quiz_Sets.To_Row(r_Data, p, z.Name, z.Description, z.State);
    Hd_Api.Quiz_Set_Save(r_Data);
  
    return z_Hd_Quiz_Sets.To_Map(r_Data, z.Quiz_Set_Id, z.Name);
  end;

end Ui_Helpdesk15;
/
