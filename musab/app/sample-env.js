/**
 * Sample environment module to provide
 * application credentials.
 * 
 * All the credentials must be filled
 * and the sample-env.js file must be
 * renamed into env.js.
 * 
 * Warning! env.js must be ignored in the
 * .gitignore as it contains
 * sensitive information
 */

module.exports = {
  // server port
  port: null,
  
  // database credentials
  connection_limit: 100,
  host: '',
  user: '',
  password: '',
  database: '',
  debug: false,

  // TODO: depricated
  base_path: __dirname,

  // TODO: dependents
  projects: [
    {
      name: '',
      path: ''
    }
  ]
}
