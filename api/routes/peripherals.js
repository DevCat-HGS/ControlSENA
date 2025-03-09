const express = require('express');
const router = express.Router();
const Peripheral = require('../models/peripheral');
const Equipment = require('../models/equipment');

// Get all peripherals
router.get('/', async (req, res) => {
  try {
    const peripherals = await Peripheral.find().populate('equipmentId');
    res.json(peripherals);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get one peripheral by ID
router.get('/:id', getPeripheral, (req, res) => {
  res.json(res.peripheral);
});

// Get peripherals by equipment ID
router.get('/equipment/:equipmentId', async (req, res) => {
  try {
    const peripherals = await Peripheral.find({ equipmentId: req.params.equipmentId }).populate('equipmentId');
    res.json(peripherals);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get peripherals by type
router.get('/type/:type', async (req, res) => {
  try {
    // Create a query that checks if the type exists as a key in the types Map
    const query = {};
    query[`types.${req.params.type}`] = { $exists: true };
    const peripherals = await Peripheral.find(query).populate('equipmentId');
    res.json(peripherals);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create peripheral
router.post('/', async (req, res) => {
  // Verify that the equipment exists if equipmentId is provided
  if (req.body.equipmentId) {
    try {
      const equipment = await Equipment.findById(req.body.equipmentId);
      if (!equipment) {
        return res.status(404).json({ message: 'Equipment not found' });
      }
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  }

  const peripheral = new Peripheral({
    types: req.body.types || {},
    serialNumber: req.body.serialNumber,
    isAssigned: req.body.equipmentId ? true : false,
    equipmentId: req.body.equipmentId,
    registrationDate: req.body.registrationDate || new Date()
  });

  try {
    const newPeripheral = await peripheral.save();
    res.status(201).json(newPeripheral);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update peripheral
router.patch('/:id', getPeripheral, async (req, res) => {
  if (req.body.types != null) {
    res.peripheral.types = req.body.types;
  }
  if (req.body.serialNumber != null) {
    res.peripheral.serialNumber = req.body.serialNumber;
  }
  if (req.body.equipmentId != null) {
    // Verify that the equipment exists
    try {
      const equipment = await Equipment.findById(req.body.equipmentId);
      if (!equipment) {
        return res.status(404).json({ message: 'Equipment not found' });
      }
      res.peripheral.equipmentId = req.body.equipmentId;
      res.peripheral.isAssigned = true;
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  } else if (req.body.equipmentId === null) {
    // If equipmentId is explicitly set to null, unassign the peripheral
    res.peripheral.equipmentId = null;
    res.peripheral.isAssigned = false;
  }

  try {
    const updatedPeripheral = await res.peripheral.save();
    res.json(updatedPeripheral);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete peripheral
router.delete('/:id', getPeripheral, async (req, res) => {
  try {
    await res.peripheral.deleteOne();
    res.json({ message: 'Peripheral deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Middleware to get peripheral by ID
async function getPeripheral(req, res, next) {
  let peripheral;
  try {
    peripheral = await Peripheral.findById(req.params.id).populate('equipmentId');
    if (peripheral == null) {
      return res.status(404).json({ message: 'Peripheral not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.peripheral = peripheral;
  next();
}

module.exports = router;