require('./global');
const express = require('express');
const app = express();

// middlewares
app.use(require('./middleware/parse-url'));
app.use(require('./middleware/response'));

// 404 not found
app.all('*', (req, res) => {
  res.status(404).send('Something went wrong!');
});

app.listen(env.port, () => console.log(`Server is listening on port ${env.port}`));
