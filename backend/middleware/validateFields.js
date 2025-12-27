const validateFields = (requiredFields) => {
  return (req, res, next) => {
    requiredFields.forEach((field) => {
      const value =
        req.body?.[field] ??
        req.query?.[field] ??
        req.params?.[field];

      if (!value) {
        return res.status(400).json({
          error: `${field} is required`,
        });
      }
    });

    next();
  };
};

module.exports = validateFields;
