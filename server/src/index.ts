import express from 'express';

const app = express();

app.post('/buzzer', (req, res) => {
  res.send(`hello`);
});

const port = 4278;
app.listen(port, () => {
  console.log(`listening at http://localhost:${port}`);
});
