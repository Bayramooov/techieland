const jwt = require('jsonwebtoken');
const { promisify } = require('util');
const verify = promisify(jwt.verify);

async function verify_user(token) {
  if (token == null) throw 'no access_token provided';
  try {
    return await verify(token, 'techieland');
  } catch {
    throw 'invalid access_token';
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// TODO
function create_user(payload) {
  if (
    !payload.name ||
    !payload.email ||
    !payload.password
  ) throw new Error('not enougt credentials');
  // let passwordHash = scryptSync(payload.password, 'techieland', 64).toString('hex');
  // TODO: Salt must be implemented
  let passwordHash = pbkdf2Sync(payload.password, 'techieland', 100000, 512, 'sha512').toString('hex');
  return {
    id: Date.now().toString(),
    name: payload.name,
    email: payload.email,
    password: passwordHash
  };
}

function sign(user) {
  return jwt.sign(user, 'techieland');
}

function verify(email, password) {
  const user = users.find(user => user.email === email);
  if (user == null) {
    throw new Error(`user not found, email: ${email}`);
  }
  const oldPasswordHash = Buffer.from(user.password, 'hex');
  // const passwordHash = scryptSync(password, 'techieland', 64);
  // TODO: Salt must be implemented
  const passwordHash = pbkdf2Sync(password, 'techieland', 100000, 512, 'sha512');

  if (!timingSafeEqual(oldPasswordHash, passwordHash)) {
    throw new Error('wrong password');
  }
  return sign(user);
}


function register(req, res) {
  try {
    var user = create_user(req.body);
    users.push(user);
  } catch (err) {
    console.error(err);
    res.setHeader('set-cookie', `access_token=-1; Max-Age=-1`);
    res.setHeader('set-cookie', `error_message=${err}; Max-Age=60`);
    return res.redirect('/register');
  }
  res.setHeader('set-cookie', `access_token=${sign(user)}; Max-Age=60`);
  return res.redirect('/');
}

function login(req, res) {
  try {
    var access_token = verify(req.body.email, req.body.password);
  } catch (err) {
    console.error(err);
    res.setHeader('set-cookie', 'access_token=-1; Max-Age=-1');
    res.setHeader('set-cookie', `error_message=${err}; Max-Age=60`);
    return res.redirect('/login');
  }
  res.setHeader('set-cookie', `access_token=${access_token}; Max-Age=60`);
  return res.redirect('/');
}

function logout(req, res) {
  res.setHeader('set-cookie', 'access_token=-1; Max-Age=-1');
  return res.redirect('/login');
}

////////////////////////////////////////////////////////////////////////////////////////////////////
module.exports = async (req, res, next) => {
  try {
    var user = await verify_user(req.cookies.access_token);
    var has_token = true;
  } catch (err) {
    console.error(err);
    has_token = false;
  }
  let uri_auth = ['/login', '/register'].includes(req.url);
  if (!has_token) {
    if (!uri_auth) return res.redirect('/login');
    else return next();
  }
  req.user = user;
  if (!uri_auth) return next();
  else return res.redirect('/');
}
