const express = require('express');
const router = express.Router();
const AccessLog = require('../models/accessLog');
const Equipment = require('../models/equipment');
const User = require('../models/user');

// Get all access logs
router.get('/', async (req, res) => {
  try {
    const accessLogs = await AccessLog.find()
      .populate('equipmentId')
      .populate('userId');
    res.json(accessLogs);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get one access log by ID
router.get('/:id', getAccessLog, (req, res) => {
  res.json(res.accessLog);
});

// Get access logs by equipment ID
router.get('/equipment/:equipmentId', async (req, res) => {
  try {
    const accessLogs = await AccessLog.find({ equipmentId: req.params.equipmentId })
      .populate('equipmentId')
      .populate('userId');
    res.json(accessLogs);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get access logs by user ID
router.get('/user/:userId', async (req, res) => {
  try {
    const accessLogs = await AccessLog.find({ userId: req.params.userId })
      .populate('equipmentId')
      .populate('userId');
    res.json(accessLogs);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get latest access log for an equipment
router.get('/latest/equipment/:equipmentId', async (req, res) => {
  try {
    const accessLog = await AccessLog.findOne({ equipmentId: req.params.equipmentId })
      .sort({ timestamp: -1 })
      .populate('equipmentId')
      .populate('userId');
    
    if (accessLog == null) {
      return res.status(404).json({ message: 'No access logs found for this equipment' });
    }
    
    res.json(accessLog);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create access log
router.post('/', async (req, res) => {
  // Verify that the equipment exists
  try {
    const equipment = await Equipment.findById(req.body.equipmentId);
    if (!equipment) {
      return res.status(404).json({ message: 'Equipment not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  // Verify that the user exists
  try {
    const user = await User.findById(req.body.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  const accessLog = new AccessLog({
    equipmentId: req.body.equipmentId,
    userId: req.body.userId,
    timestamp: req.body.timestamp || new Date(),
    accessType: req.body.accessType
  });

  try {
    const newAccessLog = await accessLog.save();
    res.status(201).json(newAccessLog);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update access log
router.patch('/:id', getAccessLog, async (req, res) => {
  if (req.body.equipmentId != null) {
    // Verify that the equipment exists
    try {
      const equipment = await Equipment.findById(req.body.equipmentId);
      if (!equipment) {
        return res.status(404).json({ message: 'Equipment not found' });
      }
      res.accessLog.equipmentId = req.body.equipmentId;
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  }
  
  if (req.body.userId != null) {
    // Verify that the user exists
    try {
      const user = await User.findById(req.body.userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.accessLog.userId = req.body.userId;
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  }
  
  if (req.body.timestamp != null) {
    res.accessLog.timestamp = req.body.timestamp;
  }
  
  if (req.body.accessType != null) {
    res.accessLog.accessType = req.body.accessType;
  }

  try {
    const updatedAccessLog = await res.accessLog.save();
    res.json(updatedAccessLog);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete access log
router.delete('/:id', getAccessLog, async (req, res) => {
  try {
    await res.accessLog.deleteOne();
    res.json({ message: 'Access log deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Middleware to get access log by ID
async function getAccessLog(req, res, next) {
  let accessLog;
  try {
    accessLog = await AccessLog.findById(req.params.id)
      .populate('equipmentId')
      .populate('userId');
    if (accessLog == null) {
      return res.status(404).json({ message: 'Access log not found' });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.accessLog = accessLog;
  next();
}

module.exports = router;