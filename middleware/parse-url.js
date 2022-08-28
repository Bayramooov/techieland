module.exports = async (req, res, next) => {
const Route = require('../model/route');


// Calling Next() from here with a structured send-data
function send(status_code, result) {
  req.send = { status_code: status_code, result: result };
  next();
}


// Loading Route & Exception-handling
async function laodRoute(route) {
  try { var result = await Route.load(route); }
  catch (err) { 
    console.error(err);
    if (/no data found/.test(err.message))
      return send(404);
    return send(500);
  }
  return result;
}


// Loading Child routes & Exception-handling Route
async function loadRouteChildren (route) {
  try { var result = await Route.loadChildren(route); }
  catch (err) {
    console.error(err);
    if (/no data found/.test(err.message))
      return send(404);
    return send(500);
  }
  return result;
}


// Runs the controller in the ui/ path respectively
async function runController(path, call, pass) {
  // TODO: req.query this is only passed by url. Body should be also implemented
  try { var result = await require(`./../ui${ path }`)[call](pass); }
  catch (err) { return send(400); }
  return result;
}

// ///////////////////////////////////////////////////////////////////////
let route = await laodRoute(req._parsedUrl.pathname);

if (route.route_kind == Route.kind_action) {
  // TODO: req.query this is only passed by url. Body should be also implemented
  let result = await runController(route.path, route.function, req.body);
  send(200, result);

} else if (route.route_kind == Route.kind_path) {
  let actions = await loadRouteChildren(route.route);
  let formInfo = _.map(actions, a => _.pick(a, ['action','route_kind','pass_parameter']));
  send(200, { fi: formInfo });

} else send(500);


























}






// async function run(req, res, next) {
//   const send = (status_code, result) => {
//     req.send = {
//       status_code: status_code,
//       result: result,
//     };
//     next();
//   }

//   let route = await laodRoute(req._parsedUrl.pathname);

//   if (route.route_kind == Route.kind_path) {
//     let formInfo = await loadRouteChildren(route.route);
//     console.log(formInfo);
//     send(200, formInfo);
//   }

  
// }


// module.exports = (req, res, next) => {
//   const send = (status_code, result) => {
//     req.send = {
//       status_code: status_code,
//       result: result,
//     };
//     next();
//   }


//   (async () => {
//     try {
//       var route = await Route.load(req._parsedUrl.pathname);
//     } catch (err) {
//       console.error(err);

//       if (/no data found/.test(err.message)) {
//         return send(404);
//       }
      
//       return send(500);
//     }

//     if (
//       route.route_kind == Route.kind_path ||
//       route.state == Route.state_passive
//     ) {
//       return send(400);
//     }

//     try {
//       // TODO: req.query this is only passed by url. Body should be also implemented
//       var load = await require(`../ui${route.path}`)[route.function](req.query);
//     } catch (err) {
//       return send(400);
//     }

//     return send(200, load);
//   })();
// }


// module.exports = run;