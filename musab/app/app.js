require('./global');
const express = require('express');
const env = require('./env');
const app = express();

// middlewares
app.use(require('./mw/parse-url'));

// 404 not found
app.all('*', (req, res) => {
  res.status(404).send('404 not found');
});

app.listen(env.port, () => console.log(`Server is listening on port ${env.port}`));
