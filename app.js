require('dotenv').config();
const {
  PORT,
  CONNECTIONLIMIT,
  HOST,
  USER,
  PASSWORD,
  DATABASE,
  DEBUG
} = process.env;

const express = require('express');
const mysql = require('mysql');

const app = express();
const pool = mysql.createPool({
  connectionLimit: CONNECTIONLIMIT,
  host: HOST,
  user: USER,
  password: PASSWORD,
  database: DATABASE,
  debug: false
});

console.log(typeof DEBUG, DEBUG);

app.use((req, res, next) => {
  let selectQuery = 'select * from ?? where ?? = ?';
  let query = mysql.format(selectQuery, ["forms", "url", req.url]);
  
  pool.query(query, (err, data) => {
    if(err) {
      console.error(err);
      return;
    }
    if (!data.length) {
      next();
      return;
    }
    else {
      res.send(`<pre style="font-size:30px">${JSON.stringify(data, false, 4)}</pre>`);
      return;
    }
  });
  
  // res.send('ok');
});

app.all('*', (req, res) => {
  res.status(404).send('404 not found');
});

app.listen(PORT, () => console.log(`Server is listening on port ${PORT}`));
