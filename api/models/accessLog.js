const mongoose = require('mongoose');

const accessLogSchema = new mongoose.Schema({
  equipmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Equipment',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  accessType: {
    type: String,
    enum: ['entry', 'exit'],
    required: true
  }
});

module.exports = mongoose.model('AccessLog', accessLogSchema);