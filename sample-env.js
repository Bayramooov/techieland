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
  // Server port
  port: '',

  // Default Relational Database Management System to use
  rdbms: {
    mysql: true,
    pgsql: false,
    orcl: false
  },
  
  // Mysql - database credentials
  mysql: {
    connection_limit: 100,
    host: '',
    user: '',
    password: '',
    database: '',
    debug: false
  },
  
  // PostgreSql - database credentials
  pgsql: {
    host: '',
    user: '',
    password: '',
    database: ''
  },
  
  // Oracle - database credentials
  orcl: {
    host: '',
    user: '',
    password: '',
    database: ''
  },

  // Projects: core, license...
  dependents: [
    {
      name: '',
      path: ''
    }
  ]
}