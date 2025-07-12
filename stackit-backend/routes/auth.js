const express = require('express');
const router = express.Router();

router.post('/register', (req, res) => {
  // registration logic here
  res.json({ message: 'Register endpoint works!' });
});

module.exports = router; 