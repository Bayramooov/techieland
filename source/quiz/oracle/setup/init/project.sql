begin
  z_Md_Projects.update_one(i_PROJECT_CODE => md_pref.c_Pc_Core, i_VISIBLE => option_varchar2('N'));
  z_Md_Projects.Save_One(i_Project_Code      => 'helpdesk',
                         i_Path_Prefix_Set   => 'helpdesk',
                         i_Module_Prefix_Set => 'hd',
                         i_Intro_Form        => '/helpdesk/intro/dashboard',
                         i_Visible           => 'Y',
                         i_Parent_Code       => 'core');
  commit;
end;
/
