/**
 * "run once share everywhere" objects globally declared.
 * no need to use `require('./...')`
 * 
 * database initialization (pool) is located here in order not to
 * run the initialization everytime needed in controller files.
 * here it will be initialized only once.
 */

const env = require('./env.js');
const mysql = require('mysql');
const pool = mysql.createPool({
  connectionLimit: env.connection_limit,
  host: env.host,
  user: env.user,
  password: env.password,
  database: env.database,
  debug: env.debug
});
const call = query => {
  return new Promise((res, rej) => {
    db.pool.query(query, (err, rows) => {
      if (err) rej(err);
      else if (!rows.length) rej(new Error('no data found'));
      res(rows);
    });
  });
}
const db = {
  mysql: mysql,
  pool: pool,
  call: call
}

global.env = env;
global.db = db;
