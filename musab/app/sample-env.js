/**
 * Sample environment module to provide
 * application credentials.
 * 
 * All the credentials must be filled
 * and the sample-env.js file must be
 * renamed into env.js.
 * 
 * Warning! file must be ignored in the
 * .gitignore file as it contains
 * sensitive information
 */

module.exports = {
  // server port
  port: null,
  
  // database credentials
  connection_limit: null,
  host: '',
  user: '',
  password: '',
  database: '',
  debug: null,

  // TODO: depricated
  base_path: __dirname,

  // dependents
  projects: [
    {
      name: '',
      path: ''
    }
  ]
}
