prompt ==== **start helpdesk** =====
prompt ==== HD ====
@@hd\hd_next.pck;
@@hd\hd_pref.pck;
@@hd\hd_util.pck;
@@hd\hd_core.pck;
@@hd\hd_api.pck;
prompt ==== HDF ====
@@hdf\hdf_next.pck;
@@hdf\hdf_pref.pck;
@@hdf\hdf_util.pck;
@@hdf\hdf_core.pck;
@@hdf\hdf_api.pck;
prompt ==== HDR ====
@@hdr\hdr_next.pck;
@@hdr\hdr_pref.pck;
@@hdr\hdr_api.pck;

prompt ==== SETUP ====
prompt ==== INIT ====
@@setup\init\project.sql;

prompt ==== UI ====
@@start_ui.sql;
@@start_uis.sql;

exec Fazo_Schema.Fazo_z.Compile_Invalid_Objects;

begin 
  md_core.gen_company_form_all;
  commit;
end;
/
  
