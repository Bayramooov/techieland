create or replace package Ui_Helpdesk29 is
  ----------------------------------------------------------------------------------------------------  
  Function Model(p Hashmap) return Hashmap;
end Ui_Helpdesk29;
/
create or replace package body Ui_Helpdesk29 is
  ----------------------------------------------------------------------------------------------------  
  Function Model(p Hashmap) return Hashmap is
  begin
    return Ui_Helpdesk24.Edit_Model(p);
  end;

end Ui_Helpdesk29;
/
