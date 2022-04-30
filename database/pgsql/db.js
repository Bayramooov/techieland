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

module.exports.mysql = mysql;
module.exports.pool = pool;
module.exports.call = call;
