const express = require("express");
const bcrypt = require("bcrypt");
const User = require("../models/User");
const validateFields = require("../middleware/validateFields");

const router = express.Router();

/**
 * POST /api/auth/register
 * Body: { name, email, password }
 */
router.post(
  "/register",
  validateFields(["name", "email", "password"]),
  async (req, res) => {
    try {
      const { name, email, password } = req.body;

      // Check if user already exists
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({
          error: "Email already registered",
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create new user
      const user = new User({
        name,
        email,
        password: hashedPassword,
      });

      await user.save();

      res.status(201).json({
        message: "User registered successfully",
      });
    } catch (error) {
      res.status(500).json({
        error: "Server error during registration",
      });
    }
  }
);

/**
 * POST /api/auth/login
 * Body: { email, password }
 */
router.post(
  "/login",
  validateFields(["email", "password"]),
  async (req, res) => {
    try {
      const { email, password } = req.body;

      // Find user by email
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(400).json({
          error: "Invalid email or password",
        });
      }

      // Compare password
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({
          error: "Invalid email or password",
        });
      }

      res.json({
        success: true,
        userId: user._id,
      });
    } catch (error) {
      res.status(500).json({
        error: "Server error during login",
      });
    }
  }
);

module.exports = router;
