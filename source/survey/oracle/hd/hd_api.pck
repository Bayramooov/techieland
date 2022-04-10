create or replace package Hd_Api is
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Group_Save(i_Quiz_Set_Group Hd_Quiz_Set_Groups%rowtype);
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Group_Delete
  (
    i_Company_Id        number,
    i_Quiz_Set_Group_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Save(i_Quiz_Set Hd_Quiz_Sets%rowtype);
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Delete
  (
    i_Company_Id  number,
    i_Quiz_Set_Id number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Save(i_Quiz Hd_Pref.Quiz_Rt);
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Delete
  (
    i_Company_Id number,
    i_Quiz_Id    number
  );
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Bind_Save(i_Hd_Quiz_Set_Bind Hd_Quiz_Set_Binds%rowtype);
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Bind_Delete
  (
    i_Company_Id  number,
    i_Quiz_Set_Id number,
    i_Quiz_Id     number
  );
  ----------------------------------------------------------------------------------------------------    
  Procedure Quiz_Set_Group_Bind_Save(i_Hd_Quiz_Set_Group_Bind Hd_Quiz_Set_Group_Binds%rowtype);
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Group_Bind_Delete
  (
    i_Company_Id        number,
    i_Quiz_Set_Group_Id number,
    i_Quiz_Set_Id       number
  );
end Hd_Api;
/
create or replace package body Hd_Api is
  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Group_Save(i_Quiz_Set_Group Hd_Quiz_Set_Groups%rowtype) is
  begin
    z_Hd_Quiz_Set_Groups.Save_Row(i_Quiz_Set_Group);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Group_Delete
  (
    i_Company_Id        number,
    i_Quiz_Set_Group_Id number
  ) is
  begin
    z_Hd_Quiz_Set_Groups.Delete_One(i_Company_Id        => i_Company_Id,
                                    i_Quiz_Set_Group_Id => i_Quiz_Set_Group_Id);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Save(i_Quiz_Set Hd_Quiz_Sets%rowtype) is
  begin
    z_Hd_Quiz_Sets.Save_Row(i_Quiz_Set);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Delete
  (
    i_Company_Id  number,
    i_Quiz_Set_Id number
  ) is
  begin
    z_Hd_Quiz_Sets.Delete_One(i_Company_Id => i_Company_Id, i_Quiz_Set_Id => i_Quiz_Set_Id);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Save(i_Quiz Hd_Pref.Quiz_Rt) is
  begin
    Hd_Core.Quiz_Save(i_Quiz);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Delete
  (
    i_Company_Id number,
    i_Quiz_Id    number
  ) is
  begin
    z_Hd_Quizs.Delete_One(i_Company_Id => i_Company_Id, i_Quiz_Id => i_Quiz_Id);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Bind_Save(i_Hd_Quiz_Set_Bind Hd_Quiz_Set_Binds%rowtype) is
  begin
    z_Hd_Quiz_Set_Binds.Save_Row(i_Hd_Quiz_Set_Bind);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Bind_Delete
  (
    i_Company_Id  number,
    i_Quiz_Set_Id number,
    i_Quiz_Id     number
  ) is
  begin
    z_Hd_Quiz_Set_Binds.Delete_One(i_Company_Id  => i_Company_Id,
                                   i_Quiz_Set_Id => i_Quiz_Set_Id,
                                   i_Quiz_Id     => i_Quiz_Id);
  end;

  ----------------------------------------------------------------------------------------------------    
  Procedure Quiz_Set_Group_Bind_Save(i_Hd_Quiz_Set_Group_Bind Hd_Quiz_Set_Group_Binds%rowtype) is
  begin
    z_Hd_Quiz_Set_Group_Binds.Save_Row(i_Hd_Quiz_Set_Group_Bind);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Quiz_Set_Group_Bind_Delete
  (
    i_Company_Id        number,
    i_Quiz_Set_Group_Id number,
    i_Quiz_Set_Id       number
  ) is
  begin
    z_Hd_Quiz_Set_Group_Binds.Delete_One(i_Company_Id        => i_Company_Id,
                                         i_Quiz_Set_Group_Id => i_Quiz_Set_Group_Id,
                                         i_Quiz_Set_Id       => i_Quiz_Set_Id);
  end;

end Hd_Api;
/
