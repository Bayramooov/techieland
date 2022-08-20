module.exports = class Route {
  /**************************************************/
  static kind_path          = 'P';
  static kind_action        = 'A';
  static kind_redirect      = 'R';
  
  /**************************************************/
  static pass_parameter_yes = 'Y';
  static pass_parameter_no  = 'N';
  
  /**************************************************/
  static privacy_auth       = 'A';
  static privacy_public     = 'P';
  
  /**************************************************/
  static access_all         = 'A';
  static access_head        = 'H';
  static access_filial      = 'F';
  
  /**************************************************/
  static grant_yes          = 'Y';
  static grant_no           = 'N';
  
  /**************************************************/
  constructor(
    i_route,
    i_path,
    i_mode,
    i_action,
    i_route_kind,
    i_parent_route,
    i_function,
    i_pass_parameter,
    i_redirection_route,
    i_privacy,
    i_access,
    i_grant,
    i_state,
    ) {
    this.route = i_route;
    this.path = i_path;
    this.mode = i_mode;
    this.action = i_action;
    this.route_kind = i_route_kind;
    this.parent_route = i_parent_route;
    this.function = i_function;
    this.pass_parameter = i_pass_parameter;
    this.redirection_route = i_redirection_route;
    this.privacy = i_privacy;
    this.access = i_access;
    this.grant = i_grant;
    this.state = i_state;
  }

  /**************************************************/
  static load(route) {
    return (async route => {
      let query = `select t.*
                     from musab_route t
                    where t.route = ?
                      and t.state = 'A'`;
      try {
        var rows = await db.call(db.mysql.format(query, [route]));
      } catch (err) {
        return Promise.reject(err);
      }

      if (!rows.length) {
        return Promise.reject(new Error(`route='${route}', no data found`));
      }

      const result = JSON.parse(JSON.stringify(rows))[0];

      return new Route(
        result.route,
        result.path,
        result.mode,
        result.action,
        result.route_kind,
        result.parent_route,
        result.function,
        result.pass_parameter,
        result.redirection_route,
        result.privacy,
        result.access,
        result.grant,
        result.state
      );
    })(route);
  }

  /**************************************************/
  static load_children(route) {
    return (async route => {
      let query = `select *
                     from musab_route t
                    where t.parent_route = ?
                      and exists(select 1
                                   from musab_route q
                                  where q.route = t.parent_route
                                    and q.state = 'A')`;
      try {
        var rows = await db.call(db.mysql.format(query, [route]));
      } catch (err) {
        return Promise.reject(err);
      }

      if (!rows.length) {
        return Promise.reject(new Error(`parent_route='${route}', no data found`));
      }
      
      const result = JSON.parse(JSON.stringify(rows));
      
      return result;
    })(route);
  }
}
