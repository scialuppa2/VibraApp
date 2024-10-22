const express = require('express');
const router = express.Router();
const upload = require('../middlewares/upload');
const authMiddleware = require('../middlewares/authMiddleware');
const messageController = require('../controllers/messageController');

router.post('/',authMiddleware, upload.single('file'), messageController.createMessage);
router.get('/:chatId',authMiddleware, messageController.getMessagesByChatId);
router.get('/:chatId/search',authMiddleware, messageController.searchMessages);
router.get('/:messageId',authMiddleware, messageController.getMessageById);

module.exports = router;
