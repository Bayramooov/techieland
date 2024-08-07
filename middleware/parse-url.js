const Route = require('../model/route');

module.exports = (req, res, next) => {
  const send = (status_code, result) => {
    req.send = {
      status_code: status_code,
      result: result,
    };
    next();
  }

  (async () => {
    try {
      var route = await Route.load(req._parsedUrl.pathname);
    } catch (err) {
      console.error(err);

      if (/no data found/.test(err.message)) {
        return send(404);
      }
      
      return send(500);
    }

    if (
      route.route_kind == Route.kind_path ||
      route.state == Route.state_passive
    ) {
      return send(400);
    }

    try {
      // TODO: req.query this is only passed by url. Body should be also implemented
      var load = await require(`../ui${route.path}`)[route.function](req.query);
    } catch (err) {
      return send(400);
    }

    return send(200, load);
  })();
}
