--1-ish
--***generate on smartup5 schema and run on sys schema
select 'grant select on smartup5.' || t.Table_Name || ' to smartup5x_helpdesk;'
  from User_Tables t;

--***generate on smartup5 schema and run on smartup5x_helpdesk schema
select 'create synonym old_' || t.Table_Name || ' for smartup5.' || t.Table_Name || ';'
  from User_Tables t;

--2-ish  
declare
begin
  Fazo_z.Drop_Object_If_Exists('migr_filials');
  Fazo_z.Drop_Object_If_Exists('migr_users');
end;
/

delete Hdf_Survey_Quiz_Sets;
delete Hdf_Surveys;
delete Hd_Quiz_Set_Group_Binds;
delete Hd_Quiz_Set_Binds;
delete Hd_Option_Quiz_Sets;
delete Hd_Option_Quizs;
delete Hd_Quiz_Sets;
delete Hd_Quiz_Set_Groups;
delete Hd_Quizs;

----------------------------------------------------------------------------------------------------  
--for saving old filial_ids to use in documents run in command window first
create table Migr_Filials(Old_Filial_Id number,
                          New_Filial_Id number,
                          constraint Migr_Filials_Pk Primary Key(Old_Filial_Id));

create table Migr_Users(Old_User_Id number,
                        New_User_Id number,
                        constraint Migr_Users_Pk Primary Key(Old_User_Id));

Exec Fazo_z.Run('migr_');
----------------------------------------------------------------------------------------------------  

--3-ish migr_helpdesk paketini yurgizish

--4-ish pastdagi blokni yurgizish
declare
begin
  Ui_Auth.Logon_As_System(121);
  --drop filials if attached in other tables
  delete Md_Company_Filial_Modules t
   where t.Company_Id = 121;
  delete Md_Company_Filial_Projects t
   where t.Company_Id = 121;
  delete Md_User_Filials t
   where t.Company_Id = 121
     and t.Filial_Id <> Md_Pref.Filial_Head(t.Company_Id);
  delete Md_User_Filials t
   where t.Company_Id = 121
     and t.User_Id not in (Md_Pref.User_System(t.Company_Id), Md_Pref.User_Admin(t.Company_Id));
  delete Md_Users t
   where t.Company_Id = 121
     and t.User_Id not in (Md_Pref.User_System(t.Company_Id), Md_Pref.User_Admin(t.Company_Id));
  delete Md_Filials t
   where t.Company_Id = 121
     and t.Filial_Id <> Md_Pref.Filial_Head(t.Company_Id);

  Migr_Helpdesk.Migration_Execute(121);
  commit;
end;
/
