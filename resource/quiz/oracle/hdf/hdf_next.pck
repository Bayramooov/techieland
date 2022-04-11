create or replace package Hdf_Next is
  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Survey_Id return number;
  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Sv_Quiz_Set_Id return number;
  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Sv_Quiz_Id return number;
  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Sv_Quiz_Unit_Id return number;
end Hdf_Next;
/
create or replace package body Hdf_Next is
  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Survey_Id return number is
  begin
    return Hdf_Surveys_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Sv_Quiz_Set_Id return number is
  begin
    return Hdf_Survey_Quiz_Sets_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Sv_Quiz_Id return number is
  begin
    return Hdf_Survey_Quizs_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------  
  Function Hdf_Sv_Quiz_Unit_Id return number is
  begin
    return Hdf_Survey_Quiz_Answers_Sq.Nextval;
  end;

end Hdf_Next;
/
