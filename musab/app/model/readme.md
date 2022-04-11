./
  sql/
    table.sql
    z-package.sql
  model1.js
  model2.js
  setup.exe*

setup.exe - we need executer file which runs the table.sql and z-package.sql to the database.

Modelx.js - each Model word is going to be the table name which contains the all the table logic as a Class. And it should be auto-generated when setup.exe called.

P.S.: setup.exe only sets up the database section, also setup.exe might be called in global setup.exe
