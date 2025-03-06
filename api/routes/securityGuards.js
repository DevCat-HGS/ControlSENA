const express = require('express');
const router = express.Router();
const SecurityGuard = require('../models/securityGuard');

// Get all security guards
router.get('/', async (req, res) => {
  try {
    const securityGuards = await SecurityGuard.find().select('-password'); // Exclude password from response
    res.json(securityGuards);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get one security guard by ID
router.get('/:id', getSecurityGuard, (req, res) => {
  // Remove password from response
  const securityGuardWithoutPassword = {
    _id: res.securityGuard._id,
    username: res.securityGuard.username,
    firstName: res.securityGuard.firstName,
    lastName: res.securityGuard.lastName,
    registrationDate: res.securityGuard.registrationDate
  };
  res.json(securityGuardWithoutPassword);
});

// Get security guard by username (for login)
router.get('/username/:username', async (req, res) => {
  try {
    const securityGuard = await SecurityGuard.findOne({ username: req.params.username });
    if (securityGuard == null) {
      return res.status(404).json({ message: 'Security guard not found' });
    }
    res.json(securityGuard);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create security guard (register)
router.post('/', async (req, res) => {
  // Check if username already exists
  try {
    const existingGuard = await SecurityGuard.findOne({ username: req.body.username });
    if (existingGuard) {
      return res.status(400).json({ message: 'Username already exists' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  const securityGuard = new SecurityGuard({
    username: req.body.username,
    password: req.body.password, // In a real app, this should be hashed
    firstName: req.body.firstName,
    lastName: req.body.lastName,
    registrationDate: req.body.registrationDate || new Date()
  });

  try {
    const newSecurityGuard = await securityGuard.save();
    // Remove password from response
    const securityGuardWithoutPassword = {
      _id: newSecurityGuard._id,
      username: newSecurityGuard.username,
      firstName: newSecurityGuard.firstName,
      lastName: newSecurityGuard.lastName,
      registrationDate: newSecurityGuard.registrationDate
    };
    res.status(201).json(securityGuardWithoutPassword);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Login route
router.post('/login', async (req, res) => {
  try {
    const securityGuard = await SecurityGuard.findOne({ username: req.body.username });
    if (securityGuard == null) {
      return res.status(404).json({ message: 'Security guard not found' });
    }
    
    // In a real app, you should use proper password hashing and verification
    if (securityGuard.password !== req.body.password) {
      return res.status(401).json({ message: 'Invalid password' });
    }
    
    // Remove password from response
    const securityGuardWithoutPassword = {
      _id: securityGuard._id,
      username: securityGuard.username,
      firstName: securityGuard.firstName,
      lastName: securityGuard.lastName,
      registrationDate: securityGuard.registrationDate
    };
    
    res.json(securityGuardWithoutPassword);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update security guard
router.patch('/:id', getSecurityGuard, async (req, res) => {
  if (req.body.username != null) {
    res.securityGuard.username = req.body.username;
  }
  if (req.body.password != null) {
    res.securityGuard.password = req.body.password; // In a real app, this should be hashed
  }
  if (req.body.firstName != null) {
    res.securityGuard.firstName = req.body.firstName;
  }
  if (req.body.lastName != null) {
    res.securityGuard.lastName = req.body.lastName;
  }

  try {
    const updatedSecurityGuard = await res.securityGuard.save();
    // Remove password from response
    const securityGuardWithoutPassword = {
      _id: updatedSecurityGuard._id,
      username: updatedSecurityGuard.username,
      firstName: updatedSecurityGuard.firstName,
      lastName: updatedSecurityGuard.lastName,
      registrationDate: updatedSecurityGuard.registrationDate
    };
    res.json(securityGuardWithoutPassword);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete security guard
router.delete('/:id', getSecurityGuard, async (req, res) => {
  try {
    await res.securityGuard.deleteOne();
    res.json({ message: 'Security guard deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Middleware to get security guard by ID
async function getSecurityGuard(req, res, next) {
  let securityGuard;
  try {
    securityGuard = await SecurityGuard.findById(req.params.id);
    if (securityGuard == null) {
      return res.status(404).json({ message: 'Security guard not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.securityGuard = securityGuard;
  next();
}

module.exports = router;