const Habit = require("../models/Habit");

const checkHabitOwner = async (req, res, next) => {
  try {
    const habitId = req.params.habitId;

    const userId =
      req.body?.userId ??
      req.query?.userId ??
      req.params?.userId;

    if (!userId) {
      return res.status(400).json({
        error: "userId is required",
      });
    }

    const habit = await Habit.findById(habitId);

    if (!habit) {
      return res.status(404).json({
        error: "Habit not found",
      });
    }

    if (habit.owner.toString() !== userId) {
      return res.status(403).json({
        error: "Not authorized",
      });
    }

    // attach habit for later use
    req.habit = habit;
    next();
  } catch (err) {
    res.status(500).json({
      error: "Owner check failed",
    });
  }
};

module.exports = checkHabitOwner;
