create or replace package Hdr_Api is
  ----------------------------------------------------------------------------------------------------  
  Procedure Template_Save(i_Template Hdr_Templates%rowtype);
end Hdr_Api;
/
create or replace package body Hdr_Api is
  ----------------------------------------------------------------------------------------------------  
  Procedure Template_Save(i_Template Hdr_Templates%rowtype) is
  begin
    z_Hdr_Templates.Save_Row(i_Template);
  end;
end Hdr_Api;
/
