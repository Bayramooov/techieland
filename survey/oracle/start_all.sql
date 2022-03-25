set define off;
prompt ==== **start table** ====
prompt ==== HD ====
@@hd\setup\hd_table.sql;
@@hd\setup\hd_sequence.sql;
prompt ==== HDF ====
@@hdf\setup\hdf_table.sql;
@@hdf\setup\hdf_sequence.sql;
prompt ==== HDR ====
@@hdr\setup\hdr_table.sql;
@@hdr\setup\hdr_sequence.sql;
exec fazo_z.run;
@@start.sql;
