export default class Route {
  constructor(path, action) {
    // auto-load mode
    // if (!path) return this;

    // TODO: input validations must be done!!!
    return (async (trusted_path, trusted_action) => {
      let query = `select t.*,
                          q.action_id,
                          q.action,
                          q.action_kind,
                          q.pass_parameter,
                          (select w.path
                             from musab_routes w
                            where exists (select 1
                                     from musab_route_actions k
                                    where k.action_id = q.redirect_id
                                      and k.path_code = w.path_code)) redirect_path,
                          q.state action_state
                     from musab_routes t
                     join musab_route_actions q
                       on q.path_code = t.path_code
                    where t.path = ?
                      and q.action = ?`;
      try {
        var result = await db.call(db.mysql.format(query, [trusted_path, trusted_action]));
      } catch (error) {
        console.error(error);
        return this;
      }
      // if (typeof result !== 'object') console.error('multiple rows returned');
      result = JSON.parse(JSON.stringify(result))[0];
      // route
      this.path_code = result.path_code;
      this.path = result.path;
      this.access_kind = result.access_kind;
      this.grant = result.grant;
      this.state = result.state;
      
      // route action
      this.action_id = result.action_id;
      this.action = result.action;
      this.action_kind = result.action_kind;
      this.pass_parameter = result.pass_parameter;
      this.redirect_path = result.redirect_path;
      this.action_state = result.action_state;
      
      return this;
    })(path, action);
  }
}
