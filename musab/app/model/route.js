export default class Route {
  static kind_path          = 'P';
  static kind_action        = 'A';
  static kind_redirect      = 'R';
  static pass_parameter_yes = 'Y';
  static pass_parameter_no  = 'N';
  static privacy_auth       = 'A';
  static privacy_public     = 'P';
  static access_all         = 'A';
  static access_head        = 'H';
  static access_filial      = 'F';
  static grant_yes          = 'Y';
  static grant_no           = 'N';
  static state_active       = 'A';
  static state_passive      = 'P';

  constructor(
    i_route,
    i_path,
    i_case,
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
    this.case = i_case;
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

  static load(path) {
    // validity(path);
    return (async path => {
      let query = `select t.*
                     from musab_routes t
                    where t.route = ?`;
      try {
        var result = await db.call(db.mysql.format(query, [path]));
      } catch (error) {
        console.error(error);
        return this;
      }
      result = JSON.parse(JSON.stringify(result))[0];
      
      return new Route(
        result.route,
        result.path,
        result.case,
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
    })(path);
  }
}
