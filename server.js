const express = require('express');
const multer  = require('multer');
const bodyParser = require('body-parser');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/')
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname)
  }
})

const upload = multer({storage: storage})
const app = express();

app.use(bodyParser.text({limit: '50mb'}));

app.post('/photo', upload.single('photo'), (req, res) => {
  console.log(req.body, req.file);
  res.send('OK');
});

app.post('/video', upload.single('movie'), (req, res) => {
  req.setTimeout(5 * 60 * 1000)
  console.log(req.body, req.file);
  res.send('OK');
})

var server = app.listen(3000, function () {
  console.log('Test server listening on port 3000!');
});

server.timeout = 5 * 60 * 10; 