const mysql = require('mysql');
const env = require('../../env');
const { readFileSync } = require('fs');
var path = require('path');

const pool = mysql.createPool({
  connectionLimit: env.connection_limit,
  host: env.host,
  user: env.user,
  password: env.password,
  database: env.database,
  debug: env.debug
});


module.exports = (req, res, next) => {
  let q = mysql.format(
    'SELECT * FROM ?? where ?? = ?',
    ["FORMS", "URL", req.url]
    );
    
    pool.query(q, (err, rows) => {
      if (err) {
        console.error(err);
        return;
      }
      if (!rows.length) {
        next();
        return;
      }
      else {
        var x = path.normalize(__dirname + '../../../page' + req.url + '.html');
        let page = String(readFileSync(x, 'utf-8'));

        console.log(rows);
        
        let htmlrows = ``;
        for (row of rows) {
          let form_kind;
          let form_grant;
          let state;

          switch (row.form_kind) {
            case 'A': form_kind = 'Auth'; break;
            case 'P': form_kind = 'Public'; break;
            case 'D': form_kind = 'Development'; break;
            // default: form_kind = '';
          }

          switch (row.form_grant) {
            case 'A': form_grant = 'All'; break;
            case 'H': form_grant = 'Filial head'; break;
            case 'F': form_grant = 'Filial'; break;
            default: form_grant = '';
          }

          switch (row.state) {
            case 'R': state = 'Ready'; break;
            case 'N': state = 'Not ready'; break;
            default: state = '';
          }
          
          htmlrows += `
            <div class="row">
              <div class="col">${ row.form_id || '' }</div>
              <div class="col">${ row.url || '' }</div>
              <div class="col">${ form_kind || '' }</div>
              <div class="col">${ form_grant || '' }</div>
              <div class="col">${ state || '' }</div>
            </div>
          `;
        }

        console.log(htmlrows);

        let result = page.interpolate({
          title: 'forms',
          grid: htmlrows
        });
          

        res.send(result);
        return;
    }
  });
  
  // res.send('ok');
}






function model() {

}
