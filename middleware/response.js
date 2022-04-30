const error = {
  400: 'bad request',
  404: 'requested route not found',
};

class Response {
  constructor(status_code, result) {
    if (Object.keys(error).includes(String(status_code))) {
      this[''] = '(>_<)';
      this.ok = false;
      this.error_code = status_code;
      this.description = error[status_code];
      return;
    }
    this[''] = '(^‿^)'; 
    this.ok = true;
    this.result = result;
  }
}

module.exports = (req, res) => {
  ({ status_code, result } = req.send);
  res.status(status_code).json(new Response(status_code, result));
}
