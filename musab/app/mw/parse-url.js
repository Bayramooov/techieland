module.exports = (req, res, next) => {
  let query = db.mysql.format('SELECT * FROM ?? where ?? = ?', ['MUSAB_ROUTES', 'PATH', req.url]);
  
  db.pool.query(query, (err, rows) => {
    if (err) { console.error(err); return; }
    else if (!rows.length || rows.length > 1) { next(); return; }
    
    var route = rows[0];
    // validation... TODO
    if (route.state == 'P') { next(); return; }

    let load = require(`../ui${route.path}`)['model']();
    load.then(result => console.log('Success!', req.url));
    // TODO: response must be send in JSON format
    // load.then(result => res.json(result));
    load.then(result => res.send(`<pre>${ JSON.stringify(result, false, 4) }</pre>`));
  });
}
