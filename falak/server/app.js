const express = require('express');
const mysql = require('mysql');
const env = require('./env.js');

const app = express();
const pool = mysql.createPool({
  connectionLimit: env.connection_limit,
  host: env.host,
  user: env.user,
  password: env.password,
  database: env.database,
  debug: env.debug
});

app.use(require('./server/middlewares/parse-url.js'));

// app.use((req, res, next) => {
//   let selectQuery = 'select * from ?? where ?? = ?';
//   let query = mysql.format(selectQuery, ["forms", "url", req.url]);
  
//   pool.query(query, (err, data) => {
//     if(err) {
//       console.error(err);
//       return;
//     }
//     if (!data.length) {
//       next();
//       return;
//     }
//     else {
//       res.send(`<pre style="font-size:30px">${JSON.stringify(data, false, 4)}</pre>`);
//       return;
//     }
//   });
  
//   // res.send('ok');
// });

app.all('*', (req, res) => {
  res.status(404).send('404 not found');
});

app.listen(env.port, () => console.log(`Server is listening on port ${env.port}`));
