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

/**
 * some of the functionalities globally declared so as to use them everywhere,
 * without using `require('./...')` and running them everytime.
 * 
 * database connection (pool) initialised once only then declared globally,
 * so the connection is not called everytime
 * env object globally declared so as to use it everywhere withou
 */

global.env = env;
global.db = db;
