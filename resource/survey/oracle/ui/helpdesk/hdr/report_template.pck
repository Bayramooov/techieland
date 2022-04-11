create or replace package Ui_Helpdesk33 is
  ----------------------------------------------------------------------------------------------------
  Procedure Save_Report_Template(p Hashmap);
end Ui_Helpdesk33;
/
create or replace package body Ui_Helpdesk33 is
  ----------------------------------------------------------------------------------------------------
  Function t
  (
    i_Message varchar2,
    i_P1      varchar2 := null,
    i_P2      varchar2 := null,
    i_P3      varchar2 := null,
    i_P4      varchar2 := null,
    i_P5      varchar2 := null
  ) return varchar2 is
  begin
    return b.Translate('UI-Helpdesk33:' || i_Message, i_P1, i_P2, i_P3, i_P4, i_P5);
  end;

  ----------------------------------------------------------------------------------------------------  
  Procedure Save_Report_Template(p Hashmap) is
    r_Template Hdr_Templates%rowtype;
  begin
    r_Template            := z_Hdr_Templates.To_Row(p,
                                                    z.Template_Id,
                                                    z.Name,
                                                    z.Description,
                                                    z.State,
                                                    z.Setting);
    r_Template.Company_Id := Ui.Company_Id;
    if r_Template.Template_Id is null then
      r_Template.Template_Id := Hdr_Next.Template_Id;
    end if;
  
    Hdr_Api.Template_Save(r_Template);
  end;

end Ui_Helpdesk33;
/
