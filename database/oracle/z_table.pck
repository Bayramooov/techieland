create or replace package z_Table is
  ----------------------------------------------------------------------------------------------------
  Function Get_Pk(i_Table_Name varchar2) return Matrix_Varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Get_Pk_Params(i_Table_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Get_Pk_Where(i_Table_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Gen_Load(i_Table_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Build_Header(i_Table_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Build_Body(i_Table_Name varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Procedure Run;
  ----------------------------------------------------------------------------------------------------
  Procedure Run(i_Table_Name varchar2);
end z_Table;
/
create or replace package body z_Table is
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
  Function New_Line return varchar2 is
  begin
    return Chr(10);
  end;

  ----------------------------------------------------------------------------------------------------
  Function Break_Line return varchar2 is
    v_Line varchar2(200);
  begin
    v_Line := New_Line;
  
    for i in 1 .. 100
    loop
      v_Line := v_Line || '-';
    end loop;
  
    v_Line := v_Line || New_Line;
  
    return v_Line;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Pk(i_Table_Name varchar2) return Matrix_Varchar2 is
    result Matrix_Varchar2;
  begin
    select Array_Varchar2(w.Column_Name, w.Data_Type)
      bulk collect
      into result
      from User_Constraints t
      join User_Cons_Columns q
        on q.Owner = t.Owner
       and q.Constraint_Name = t.Constraint_Name
       and q.Table_Name = t.Table_Name
      join User_Tab_Columns w
        on w.Table_Name = q.Table_Name
       and w.Column_Name = q.Column_Name
     where Lower(t.Table_Name) = Lower(i_Table_Name)
       and t.Constraint_Type = 'P'
       and Lower(Substr(t.Constraint_Name, -2, 2)) = 'pk'
     order by q.Position;
  
    return result;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Pk_Params(i_Table_Name varchar2) return varchar2 is
    v_Columns Matrix_Varchar2;
    v_Params  varchar2(5000);
  begin
    v_Columns := Get_Pk(i_Table_Name);
  
    for i in 1 .. v_Columns.Count
    loop
      v_Params := v_Params || 'i_' || v_Columns(i) (1) || ' ' || v_Columns(i) (2) || ',';
    end loop;
  
    v_Params := Substr(v_Params, 0, Length(v_Params) - 1);
  
    return v_Params;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Get_Pk_Where(i_Table_Name varchar2) return varchar2 is
    v_Columns Matrix_Varchar2;
    v_Where   varchar2(5000);
  begin
    v_Columns := Get_Pk(i_Table_Name);
  
    for i in 1 .. v_Columns.Count
    loop
      v_Where := v_Where || 't.' || v_Columns(i) (1) || ' = i_' || v_Columns(i) (1) || ' and ';
    end loop;
  
    v_Where := Substr(v_Where, 0, Length(v_Where) - 4);
  
    return v_Where;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Load_Header(i_Table_Name varchar2) return varchar2 is
  begin
    return Break_Line || 'Function Load(' || Get_Pk_Params(i_Table_Name) || ') return ' || i_Table_Name || '%rowtype';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Gen_Load(i_Table_Name varchar2) return varchar2 is
  begin
    return Gen_Load_Header(i_Table_Name) || ' is r_row ' || i_Table_Name || '%rowtype; begin select * into r_row from ' || i_Table_Name || ' t where ' || Get_Pk_Where(i_Table_Name) || '; return r_row; end;';
  end;

  ----------------------------------------------------------------------------------------------------
  Function Build_Header(i_Table_Name varchar2) return varchar2 is
    v_Package varchar2(15000);
  begin
    v_Package := 'create or replace package z_' || i_Table_Name || ' is';
  
    v_Package := v_Package || Gen_Load_Header(i_Table_Name) || ';' || New_Line;
  
    v_Package := v_Package || 'end z_' || i_Table_Name || ';';
  
    return v_Package;
  end;

  ----------------------------------------------------------------------------------------------------
  Function Build_Body(i_Table_Name varchar2) return varchar2 is
    v_Package varchar2(15000);
  begin
    v_Package := 'create or replace package body z_' || i_Table_Name || ' is';
  
    v_Package := v_Package || Gen_Load(i_Table_Name) || New_Line;
  
    v_Package := v_Package || New_Line || 'end z_' || i_Table_Name || ';';
  
    return v_Package;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run is
  begin
    for r in (select *
                from User_Tables t)
    loop
      execute immediate Build_Header(r.Table_Name);
      execute immediate Build_Body(r.Table_Name);
    end loop;
  end;

  ----------------------------------------------------------------------------------------------------
  Procedure Run(i_Table_Name varchar2) is
  begin
    for r in (select *
                from User_Tables t
               where i_Table_Name is null
                  or Lower(t.Table_Name) like '%' || Lower(i_Table_Name) || '%')
    loop
      execute immediate Build_Header(r.Table_Name);
      execute immediate Build_Body(r.Table_Name);
    end loop;
  end;

end z_Table;
/
