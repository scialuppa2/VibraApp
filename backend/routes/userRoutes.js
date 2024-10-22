const express = require('express');
const userController = require('../controllers/userController');
const authMiddleware = require('../middlewares/authMiddleware');
const router = express.Router();

router.get('/',authMiddleware, userController.getUsers);
router.get('/:id',authMiddleware, userController.getUserById);
router.put('/:id',authMiddleware, userController.updateUser);
router.delete('/:id',authMiddleware, userController.deleteUser);
router.post('/:id/uploadProfilePicture',authMiddleware, userController.uploadProfilePicture);

module.exports = router;
