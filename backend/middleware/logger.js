// middleware/logger.js

const logger = (req, res, next) => {
  const time = new Date().toISOString();
  console.log(`[${time}] ${req.method} ${req.url}`);
  next(); // VERY IMPORTANT: move to next middleware/route
};

module.exports = logger;
