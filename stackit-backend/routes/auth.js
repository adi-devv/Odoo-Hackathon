const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const router = express.Router();
const pool = require('../db'); // create a db.js for pg pool

// Register
router.post('/register', [
  body('username').notEmpty(),
  body('email').isEmail(),
  body('password').isLength({ min: 6 })
], async (req, res) => {
  // ... registration logic (hash password, insert user, return JWT)
});

// Login
router.post('/login', [
  body('email').isEmail(),
  body('password').notEmpty()
], async (req, res) => {
  // ... login logic (check password, return JWT)
});

// Get current user
router.get('/me', require('../middleware/authenticate'), async (req, res) => {
  // ... return user info from req.user
});

module.exports = router; 
