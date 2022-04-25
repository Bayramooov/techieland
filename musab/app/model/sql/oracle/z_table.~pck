create or replace package z_Table is
  /*
  user_all_tables
  user_col_comments
  user_constraints
  user_credentials
  user_dependencies
  user_jobs
  user_objects
  user_sequences
  user_synonyms
  user_tables
  user_tablespaces
  user_triggers
  user_trigger_cols
  user_trigger_ordering
  */
  ----------------------------------------------------------------------------------------------------
  Procedure Run(i_Table_Name varchar2);
end z_Table;
/
create or replace package body z_Table is
  ----------------------------------------------------------------------------------------------------
  /*
  select w.*
    from User_Constraints t
    join User_Cons_Columns q
      on q.Owner = t.Owner
     and q.Constraint_Name = t.Constraint_Name
     and q.Table_Name = t.Table_Name
    join User_Tab_Columns w
      on w.Table_Name = q.Table_Name
     and w.Column_Name = q.Column_Name
   where t.Table_Name = :Table_Name
     and t.Constraint_Type = 'P'
     and Lower(Substr(t.Constraint_Name, -2, 2)) = 'pk'
   order by q.Position;  
  */

  ----------------------------------------------------------------------------------------------------
  Function Gen_Load(i_Table_Name varchar2) return varchar2 is
    v_Code varchar2(5000);
  
    v_Columns Array_Number;
  begin
    v_Code := '
    Function Load(i_Route varchar2) return Musab_Route%rowtype is
    r_Musab_Route Musab_Route%rowtype;
  begin
    select *
      into r_Musab_Route
      from Musab_Route t
     where t.Route = i_Route;
  
    return r_Musab_Route;
  end;
    ';
  
    return v_Code;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Build(i_Table_Name varchar2) return varchar2 is
    v_Package varchar2(15000);
  begin
    v_Package := 'create or replace package body z_' || i_Table_Name || ' is' || Chr(10);
  
    v_Package := v_Package || Gen_Load(i_Table_Name);
  
    --------------------------------------------------
    v_Package := v_Package || 'end z_' || i_Table_Name || ';';
  
    return v_Package;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run(i_Table_Name varchar2) is
  begin
    for r in (select *
                from User_Tables t
               where i_Table_Name is null
                  or Lower(t.Table_Name) like '%' || Lower(i_Table_Name) || '%')
    loop
      execute immediate Build(r.Table_Name);
    end loop;
  end;

end z_Table;
/
