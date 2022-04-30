const mysql = require('mysql');

const pool = mysql.createPool({
  connectionLimit: env.mysql.connection_limit,
  host: env.mysql.host,
  user: env.mysql.user,
  password: env.mysql.password,
  database: env.mysql.database,
  debug: env.mysql.debug
});

const call = query => {
  return new Promise((res, rej) => {
    db.pool.query(query, (err, rows) => {
      if (err) return rej(err);
      return res(rows);
    });
  });
}

module.exports.mysql = mysql;
module.exports.pool = pool;
module.exports.call = call;
