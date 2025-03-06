const mongoose = require('mongoose');

const peripheralSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true
  },
  serialNumber: {
    type: String
  },
  isAssigned: {
    type: Boolean,
    required: true,
    default: false
  },
  equipmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Equipment'
  },
  registrationDate: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Peripheral', peripheralSchema);