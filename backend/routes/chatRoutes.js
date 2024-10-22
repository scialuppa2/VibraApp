const express = require('express');
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middlewares/authMiddleware');
const router = express.Router();

router.post('/',authMiddleware, chatController.createChat);
router.get('/:id',authMiddleware, chatController.getChatById);
router.get('/user/:userId',authMiddleware, chatController.getChatsByUserId);
router.get('/search',authMiddleware, chatController.searchChats);
router.post('/:id/leave',authMiddleware, chatController.leaveGroup);
router.post('/:id/add',authMiddleware, chatController.addUserToChat);
router.delete('/:id',authMiddleware, chatController.deleteChat);



module.exports = router;
