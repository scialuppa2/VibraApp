require('dotenv').config();

module.exports = {
  port: process.env.PORT || 3000,
  dbUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/vibra',
  jwtSecret: process.env.JWT_SECRET || 'my_jwt_secret',
};

