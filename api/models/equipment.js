const mongoose = require('mongoose');

const equipmentSchema = new mongoose.Schema({
  qrCode: {
    type: String,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  peripherals: [{
    types: {
      type: Map,
      of: Boolean,
      default: {}
    },
    serialNumber: String,
    isAssigned: {
      type: Boolean,
      default: true
    }
  }],
  serialNumber: String,
  assignmentDate: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Equipment', equipmentSchema);