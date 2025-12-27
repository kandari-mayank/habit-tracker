const express = require("express");
const Habit = require("../models/Habit");
const HabitLog = require("../models/HabitLog");
const validateFields = require("../middleware/validateFields");
const checkHabitOwner = require("../middleware/checkHabitOwner");

const router = express.Router();

const getWeekStartDate = (dateStr) => {
  const date = new Date(dateStr);
  const day = date.getDay(); // 0 (Sun) - 6 (Sat)
  const diff = date.getDate() - day; // start of week (Sunday)
  const weekStart = new Date(date.setDate(diff));
  return weekStart.toISOString().split("T")[0]; // YYYY-MM-DD
};


/**
 * POST /api/habits
 * Create a new habit
 */
router.post(
  "/",
  validateFields(["title", "frequency", "userId"]),
  async (req, res) => {
    try {
      const { title, description, frequency, userId } = req.body;

      const habit = new Habit({
        title,
        description,
        frequency,
        owner: userId,
      });

      await habit.save();

      res.status(201).json(habit);
    } catch (error) {
      res.status(500).json({
        error: "Failed to create habit",
      });
    }
  }
);

/**
 * GET /api/habits/:userId
 * Get all habits of a user
 * Optional query: ?status=active | archived
 */
router.get("/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const { status } = req.query;

    const filter = { owner: userId };
    if (status) {
      filter.status = status;
    }

    const habits = await Habit.find(filter).sort({ createdAt: -1 });

    res.json(habits);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch habits",
    });
  }
});

/**
 * PUT /api/habits/:habitId
 * Update habit (title, description, frequency, status)
 */
router.put(
  "/:habitId",
  validateFields(["userId"]),
  checkHabitOwner,
  async (req, res) => {
    try {
      const { title, description, frequency, status } = req.body;
      const habit = req.habit;

      if (title !== undefined) habit.title = title;
      if (description !== undefined) habit.description = description;
      if (frequency !== undefined) habit.frequency = frequency;
      if (status !== undefined) habit.status = status;

      await habit.save();

      res.json(habit);
    } catch (error) {
      res.status(500).json({
        error: "Failed to update habit",
      });
    }
  }
);

/**
 * DELETE /api/habits/:habitId
 * Delete habit and its logs
 */
router.delete(
  "/:habitId",
  validateFields(["userId"]),
  checkHabitOwner,
  async (req, res) => {
    try {
      const habitId = req.params.habitId;

      // Delete all logs related to habit
      await HabitLog.deleteMany({ habitId });

      // Delete habit itself
      await req.habit.deleteOne();

      res.json({
        message: "Habit deleted successfully",
      });
    } catch (error) {
      res.status(500).json({
        error: "Failed to delete habit",
      });
    }
  }
);

module.exports = router;

/**
 * POST /api/habits/:habitId/mark
 * Mark habit as completed for a date
 * Body: { userId, date }
 */
router.post(
  "/:habitId/mark",
  validateFields(["userId", "date"]),
  checkHabitOwner,
  async (req, res) => {
    try {
      const { date } = req.body;
      const habit = req.habit;

      // Prevent marking archived habits
      if (habit.status === "archived") {
        return res.status(400).json({
          error: "Cannot mark an archived habit",
        });
      }

      // Prevent future dates
      const today = new Date().toISOString().split("T")[0];
      if (date > today) {
        return res.status(400).json({
          error: "Cannot mark future dates",
        });
      }

      let logDate = date;

      // Weekly habit → normalize to week start
      if (habit.frequency === "weekly") {
        logDate = getWeekStartDate(date);
      }

      // Find existing log
      let log = await HabitLog.findOne({
        habitId: habit._id,
        date: logDate,
      });

      if (log) {
        // Toggle completion
        log.completed = !log.completed;
      } else {
        // Create new log
        log = new HabitLog({
          habitId: habit._id,
          date: logDate,
          completed: true,
        });
      }

      await log.save();

      res.json(log);
    } catch (error) {
      res.status(500).json({
        error: "Failed to mark habit completion",
      });
    }
  }
);

/**
 * GET /api/habits/:habitId/logs
 * Get all logs for a habit
 */
router.get(
  "/:habitId/logs",
  validateFields(["userId"]),
  checkHabitOwner,
  async (req, res) => {
    try {
      const logs = await HabitLog.find({
        habitId: req.habit._id,
      }).sort({ date: 1 });

      res.json(logs);
    } catch (error) {
      res.status(500).json({
        error: "Failed to fetch habit logs",
      });
    }
  }
);

/**
 * GET /api/habits/:habitId/stats
 * Get simple statistics for a habit
 */
router.get(
  "/:habitId/stats",
  validateFields(["userId"]),
  checkHabitOwner,
  async (req, res) => {
    try {
      const habitId = req.habit._id;

      // Fetch all logs for this habit
      const logs = await HabitLog.find({ habitId });

      const totalDaysTracked = logs.length;
      const daysCompleted = logs.filter((log) => log.completed).length;

      const completionRate =
        totalDaysTracked === 0
          ? 0
          : Math.round((daysCompleted / totalDaysTracked) * 100);

      res.json({
        totalDaysTracked,
        daysCompleted,
        completionRate,
      });
    } catch (error) {
      res.status(500).json({
        error: "Failed to calculate statistics",
      });
    }
  }
);
