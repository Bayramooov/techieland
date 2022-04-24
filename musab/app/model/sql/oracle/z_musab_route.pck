create or replace package z_Musab_Route is
end z_Musab_Route;
/
create or replace package body z_Musab_Route is
  ----------------------------------------------------------------------------------------------------
  Function Load(i_Route varchar2) return Musab_Route%rowtype is
    r_Musab_Route Musab_Route%rowtype;
  begin
    select *
      into r_Musab_Route
      from Musab_Route t
     where t.Route = i_Route;
  
    return r_Musab_Route;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Take(i_Route varchar2) return Musab_Route%rowtype is
    r_Musab_Route Musab_Route%rowtype;
  begin
    select *
      into r_Musab_Route
      from Musab_Route t
     where t.Route = i_Route;
  
    return r_Musab_Route;
  exception
    when No_Data_Found then
      return r_Musab_Route;
  end;

end z_Musab_Route;
/
