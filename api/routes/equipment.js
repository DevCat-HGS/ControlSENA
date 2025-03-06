const express = require('express');
const router = express.Router();
const Equipment = require('../models/equipment');
const User = require('../models/user');

// Get all equipment
router.get('/', async (req, res) => {
  try {
    const equipment = await Equipment.find().populate('userId');
    res.json(equipment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get one equipment by ID
router.get('/:id', getEquipment, (req, res) => {
  res.json(res.equipment);
});

// Get equipment by QR code
router.get('/qr/:qrCode', async (req, res) => {
  try {
    const equipment = await Equipment.findOne({ qrCode: req.params.qrCode }).populate('userId');
    if (equipment == null) {
      return res.status(404).json({ message: 'Equipment not found' });
    }
    res.json(equipment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get equipment by user ID
router.get('/user/:userId', async (req, res) => {
  try {
    const equipment = await Equipment.find({ userId: req.params.userId }).populate('userId');
    res.json(equipment);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create equipment
router.post('/', async (req, res) => {
  // Verify that the user exists
  try {
    const user = await User.findById(req.body.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  const equipment = new Equipment({
    qrCode: req.body.qrCode,
    name: req.body.name,
    description: req.body.description,
    userId: req.body.userId,
    registrationDate: req.body.registrationDate || new Date()
  });

  try {
    const newEquipment = await equipment.save();
    res.status(201).json(newEquipment);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update equipment
router.patch('/:id', getEquipment, async (req, res) => {
  if (req.body.qrCode != null) {
    res.equipment.qrCode = req.body.qrCode;
  }
  if (req.body.name != null) {
    res.equipment.name = req.body.name;
  }
  if (req.body.description != null) {
    res.equipment.description = req.body.description;
  }
  if (req.body.userId != null) {
    // Verify that the user exists
    try {
      const user = await User.findById(req.body.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.equipment.userId = req.body.userId;
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  }

  try {
    const updatedEquipment = await res.equipment.save();
    res.json(updatedEquipment);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete equipment
router.delete('/:id', getEquipment, async (req, res) => {
  try {
    await res.equipment.deleteOne();
    res.json({ message: 'Equipment deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Middleware to get equipment by ID
async function getEquipment(req, res, next) {
  let equipment;
  try {
    equipment = await Equipment.findById(req.params.id).populate('userId');
    if (equipment == null) {
      return res.status(404).json({ message: 'Equipment not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.equipment = equipment;
  next();
}

module.exports = router;