create or replace package Hd_Next is
  ----------------------------------------------------------------------------------------------------
  Function Quiz_Set_Group_Id return number;
  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Set_Id return number;
  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Id return number;
  ----------------------------------------------------------------------------------------------------  
  Function Option_Id return number;
end Hd_Next;
/
create or replace package body Hd_Next is
  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Set_Group_Id return number is
  begin
    return Hd_Quiz_Set_Groups_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Set_Id return number is
  begin
    return Hd_Quiz_Sets_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Quiz_Id return number is
  begin
    return Hd_Quizs_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Option_Id return number is
  begin
    return Hd_Quiz_Options_Sq.Nextval;
  end;

end Hd_Next;
/
