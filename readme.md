# **MUSAB TABLES**

### Content:

1. [Route](#route)
   1. [URL terminology](#URL-terminology)
   1. [Route: Columns](#Route-Columns)
   1. [Route: Constraints](#Route-Constraints)
1. Roles

## Route

Route - is the table of all the routes which can be handled by the server. All the other requested routes will be responded with `404-Not-Found` error.

### URL terminology

- `https://john.Doe@api.techieland.uz:443/musab/route+edit$save?route_id=374&action=save#top` is URI (uniform resource identifier).
- `https://john.Doe@api.techieland.uz:443/musab/route+edit` is URL (uniform resource locator).
- `https://john.Doe@api.techieland.uz:443` is ORIGIN.
- `https` is SCHEME or PROTOCOL.
- `john.Doe@api.techieland.uz:443` is AUTHORITY.
- `john.Doe` is USERINFO.
- `api.techieland.uz` is HOST.
- `api` is SUBDOMAIN.
- `techieland.uz` is DOMAIN.
- `techieland` is TLD (top level domain).
- `uz` is SLD (second-level-domain).
- `443` is PORT.
- `/musab/route` is PATH.
- `route` is URN (uniform resource name).
- `+edit` is MODE (musab: +add/+edit modes of the same path).
- `:save` is ACTION (public).
- `$save` is ACTION (grant).
- `?route_id=374&action=save` is QUERY.
- `#top` is FRAGMENT (hash).

### Route: Columns

<dl>
  <dt><i>route</i></dt>
  <dd>Route - is PATH + MODE + ACTION combination. It is Unique and primary key of the table.</dd>

  <dt><i>path</i></dt>
  <dd>Path - is structured as the directory architecture and it is the location of its controller file respectively. URN is the file-name of the controller file.</dd>

  <dt><i>mode</i></dt>
  <dd>Mode - all the different modes of the same path (same controller file) to react differently (+add, +edit).</dd>

  <dt><i>action</i></dt>
  <dd>
    Action - is the preffered action in that URL. It can start with <b>$</b> which means grant action, or it can start with <b>:</b> which means public action.<br>
    Action is null when route kind is (P)ath
  </dd>

  <dt><i>route_kind</i></dt>
  <dd>
    Route kind - can be either <b>(P)ath</b>, <b>(A)ction</b> or <b>(R)edirect</b>.<br>
    <b>(P)ath</b> - request doesn't contain any action, it contains only path + mode. So, the response would be a HTML document (Content-Type:text/html) in the corresponding path.<br>
    <b>(A)ction</b> - requesting an action to be run in the path. So the response would be the result (Content-Type:application/json) of the called function.<br>
    <b>(R)edirect</b> - Redirection to a differenct path. So, response would be the parent redirection route (Content-Type:text/html).<br>
  </dd>

  <dt><i>parent_route</i></dt>
  <dd>Parent route - is a route_kind = (P)ath route which is a parent of all the (A)ction & (R)edirect routes</dd>

  <dt><i>function</i></dt>
  <dd>Function - is a function name in the controller file which needs to be run when corresponding action will be called.</dd>

  <dt><i>pass_parameter</i></dt>
  <dd>Pass parameter - is a column which can be <b>(Y)es</b> which means function accepts parameter. So, the parameter must be sent in the HTTP POST request as PAYLOAD. Either it can be <b>(N)o</b> which means function doesn't accept parameters.</dd>

  <dt><i>redirect_route</i></dt>
  <dd>Redirect route - is the route for redirection. It is only available when Route-kind is set to (R)edirect</dd>

  <dt><i>privacy</i></dt>
  <dd>Privacy - can be either <b>(A)uthentication</b> which can be reached by authentication only or <b>(P)ublic</b> which can be reached by anybody without authentication.</dd>

  <dt><i>access</i></dt>
  <dd>
    Access - can be set to <b>(A)ll</b>, <b>(H)ead-filial</b> or <b>(F)ilial</b>.<br>
    Additionally, grant can be binded to the <a href='#roles'>roles</a> but only in the access scope.
  </dd>

  <dt><i>grant</i></dt>
  <dd>Grant - means whether the route can be granted or it is public (in the access scope)</dd>

  <dt><i>state</i></dt>
  <dd>route can be switched off (set to (P)assive) for a while when maintenance is on-going by company head users. And can be switched on back (set to (A)ctive)</dd>
</dl>
