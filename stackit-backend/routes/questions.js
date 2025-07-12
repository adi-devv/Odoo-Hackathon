const express = require('express');
const router = express.Router();

// POST /api/v1/questions
router.post('/', (req, res) => {
  res.json({ message: 'Question created!', data: req.body });
});

module.exports = router;