create or replace package Ui_Helpdesk13 is
  ----------------------------------------------------------------------------------------------------
  Function Add_Model return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Add(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Edit_Model(p Hashmap) return Hashmap;
  ----------------------------------------------------------------------------------------------------
  Function Edit(p Hashmap) return Hashmap;
end Ui_Helpdesk13;
/
create or replace package body Ui_Helpdesk13 is
  ----------------------------------------------------------------------------------------------------
  Function Add_Model return Hashmap is
  begin
    return Fazo.Zip_Map('state', 'A');
  end;

  ----------------------------------------------------------------------------------------------------
  Function Add(p Hashmap) return Hashmap is
    r_Data Hd_Quiz_Set_Groups%rowtype;
  begin
    r_Data := z_Hd_Quiz_Set_Groups.To_Row(p, z.Name, z.State);
  
    r_Data.Company_Id        := Ui.Company_Id;
    r_Data.Quiz_Set_Group_Id := Hd_Next.Quiz_Set_Group_Id;
  
    Hd_Api.Quiz_Set_Group_Save(r_Data);
  
    return z_Hd_Quiz_Set_Groups.To_Map(r_Data, z.Quiz_Set_Group_Id, z.Name);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Edit_Model(p Hashmap) return Hashmap is
    r_Data Hd_Quiz_Set_Groups%rowtype;
  begin
    r_Data := z_Hd_Quiz_Set_Groups.Load(i_Company_Id        => Ui.Company_Id,
                                        i_Quiz_Set_Group_Id => p.r_Number('quiz_set_group_id'));
  
    return z_Hd_Quiz_Set_Groups.To_Map(r_Data, z.Quiz_Set_Group_Id, z.Name, z.State);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Edit(p Hashmap) return Hashmap is
    r_Data Hd_Quiz_Set_Groups%rowtype;
  begin
    r_Data := z_Hd_Quiz_Set_Groups.Lock_Load(i_Company_Id        => Ui.Company_Id,
                                             i_Quiz_Set_Group_Id => p.r_Number('quiz_set_group_id'));
  
    z_Hd_Quiz_Set_Groups.To_Row(r_Data, p, z.Name, z.State);
  
    Hd_Api.Quiz_Set_Group_Save(r_Data);
  
    return z_Hd_Quiz_Set_Groups.To_Map(r_Data, z.Quiz_Set_Group_Id, z.Name);
  end;

end Ui_Helpdesk13;
/
