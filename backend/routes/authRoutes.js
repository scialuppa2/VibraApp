const express = require('express');
const authController = require('../controllers/authController');
const upload = require('../middlewares/upload');
const router = express.Router();

router.post('/register', upload.single('profilePicture'), authController.register);
router.post('/login', authController.login);

module.exports = router;
