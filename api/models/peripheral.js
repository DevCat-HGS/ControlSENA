const mongoose = require('mongoose');

const peripheralSchema = new mongoose.Schema({
  types: {
    type: Map,
    of: Boolean,
    default: {}
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