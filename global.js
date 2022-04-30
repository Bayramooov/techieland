/**
 * "run once share everywhere" objects globally declared.
 * no need to use `require('./...')`
 * 
 * database initialization (pool) is located here in order not to
 * run the initialization everytime needed in controller files.
 * here it will be initialized only once.
 */

global.env = require('./env.js');

if (env.rdbms.mysql)
  global.db = require('./database/mysql/db');

else if (env.rdbms.pgsql)
    global.db = require('./database/pgsql/db');

else if (env.rdbms.orcl)
  global.db = require('./database/orcl/db');

else
  throw new Error('At least one RDBMS must be selected in env.js');
