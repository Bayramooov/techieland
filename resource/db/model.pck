create or replace package Model is
  ----------------------------------------------------------------------------------------------------
  Function Load(Country_Id number) return Countries%rowtype;
end Model;
/
create or replace package body Model is
  ----------------------------------------------------------------------------------------------------
  Function Load(Country_Id number) return Countries%rowtype is
    Country Countries%rowtype;
  begin
    select *
      into Country
      from Countries c
     where c.Country_Id = Country_Id;
  
    return Country;
  end;

end Model;
/
