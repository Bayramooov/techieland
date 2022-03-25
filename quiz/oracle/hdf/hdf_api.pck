create or replace package Hdf_Api is
  ----------------------------------------------------------------------------------------------------
  Function Gen_Document_Number
  (
    i_Company_Id number,
    i_Filial_Id  number,
    i_Table      Fazo_Schema.w_Table_Name,
    i_Column     Fazo_Schema.w_Column_Name
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Save(i_Survey Hdf_Pref.Survey_Rt);
end Hdf_Api;
/
create or replace package body Hdf_Api is
  ----------------------------------------------------------------------------------------------------
  Function Gen_Document_Number
  (
    i_Company_Id number,
    i_Filial_Id  number,
    i_Table      Fazo_Schema.w_Table_Name,
    i_Column     Fazo_Schema.w_Column_Name
  ) return varchar2 is
  begin
    return Hdf_Core.Gen_Document_Number(i_Company_Id => i_Company_Id,
                                        i_Filial_Id  => i_Filial_Id,
                                        i_Table      => i_Table,
                                        i_Column     => i_Column);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Survey_Save(i_Survey Hdf_Pref.Survey_Rt) is
  begin
    Hdf_Core.Survey_Save(i_Survey);
  end;

end Hdf_Api;
/
