const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
mongoose.connect('mongodb://localhost:27017/equipment_control', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB successfully');
}).catch((error) => {
  console.error('MongoDB connection error:', error);
});

// Routes
const usersRouter = require('./routes/users');
const equipmentRouter = require('./routes/equipment');
const securityGuardsRouter = require('./routes/securityGuards');
const accessLogsRouter = require('./routes/accessLogs');
const peripheralsRouter = require('./routes/peripherals');

// Register routes
app.use('/api/users', usersRouter);
app.use('/api/equipment', equipmentRouter);
app.use('/api/security-guards', securityGuardsRouter);
app.use('/api/access-logs', accessLogsRouter);
app.use('/api/peripherals', peripheralsRouter);

// Error handling middleware
app.use((err, res) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

const PORT = 3000; //process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});