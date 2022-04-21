const Route = require('../model/route');

module.exports = (req, res, next) => {
  (async () => {
    try {
      var route = await Route.load(req.url);
    } catch (err) {
      console.error(err);
      res.status(400).send('<pre>' + 'Bad request!<br><br>' + err + '</pre>');
    }

    if (route.state == 'P') { next(); return; }

    try {
      var load = await require(`../ui${route.path}`)[route.function]();
    } catch (err) {
      console.error(err);
      res.status(400).send('<pre>' + 'Bad request!<br><br>' + err + '</pre>');
      return;
    }

    console.log('Success!', req.url)
    // TODO: response must be send in JSON format
    // load.then(result => res.json(result));
    res.send(`<pre>${ JSON.stringify(load, false, 4) }</pre>`)
  })();
}