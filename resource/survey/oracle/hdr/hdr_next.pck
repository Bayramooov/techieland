create or replace package Hdr_Next is
  ----------------------------------------------------------------------------------------------------
  -- deleted
  ----------------------------------------------------------------------------------------------------
  Function Report_Template_Id return number;
  ----------------------------------------------------------------------------------------------------
  Function Template_Id return number;
end Hdr_Next;
/
create or replace package body Hdr_Next is
  --deleted
  ----------------------------------------------------------------------------------------------------
  Function Report_Template_Id return number is
  begin
    return Hdr_Report_Templates_Sq.Nextval;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Template_Id return number is
  begin
    return Hdr_Templates_Sq.Nextval;
  end;

end Hdr_Next;
/
