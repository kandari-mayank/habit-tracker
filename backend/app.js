// app.js

const express = require("express");
const dotenv = require("dotenv");
const logger = require("./middleware/logger");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const habitRoutes = require("./routes/habitRoutes");
const cors = require("cors");


dotenv.config();

const app = express();

// Middleware
app.use(express.json());
app.use(logger);
app.use(cors());


// Routes
app.use("/api/auth", authRoutes);
app.use("/api/habits", habitRoutes);


// Test route
app.get("/", (req, res) => {
  res.send("Smart Habit Tracker Backend is running");
});

const PORT = process.env.PORT || 3000;

// Start server ONLY after DB connects
const startServer = async () => {
  await connectDB();

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
  });
};

startServer();

