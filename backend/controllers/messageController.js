const mongoose = require('mongoose');
const User = require('../models/user');
const Message = require('../models/message');
const Chat = require('../models/chat');
let io;

exports.setSocket = (socketIoInstance) => {
  io = socketIoInstance;
};

exports.createMessage = async (req, res) => {
    try {
        const { content, chat_id, sender_id, sender_username } = req.body;
        const file = req.file;

        if (!mongoose.Types.ObjectId.isValid(chat_id) || !mongoose.Types.ObjectId.isValid(sender_id)) {
            return res.status(400).json({ error: 'Invalid chat_id or sender_id format' });
        }

        const sender = await User.findById(sender_id);
        if (!sender) {
            return res.status(404).json({ error: 'Sender not found' });
        }

        if (!content && !file) {
            return res.status(400).json({ error: 'Message content or file is required' });
        }

        const messageData = {
            content: content || '',
            chat_id,
            sender_id,
            sender_username: sender.username,
            file_url: file ? `/uploads/${file.filename}` : undefined,
            original_file_name: file ? file.originalname : undefined,
        };

        const message = new Message(messageData);
        await message.save();

        await Chat.findByIdAndUpdate(chat_id, { $push: { messages: message._id } });

        if (io) {
            io.to(chat_id).emit('newMessage', message);
        }

        res.status(201).json(message);
    } catch (err) {
        console.error('Error creating message:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

exports.getMessagesByChatId = async (req, res) => {
    try {
        const { chatId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(chatId)) {
            return res.status(400).json({ error: 'Invalid chatId format' });
        }

        const messages = await Message.find({ chat_id: chatId }).sort({ createdAt: 1 });

        res.status(200).json(messages);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};

exports.getMessageById = async (req, res) => {
    try {
        const { messageId } = req.params;

        if (!mongoose.Types.ObjectId.isValid(messageId)) {
            return res.status(400).json({ error: 'Invalid messageId format' });
        }

        const message = await Message.findById(messageId);

        if (!message) {
            return res.status(404).json({ error: 'Message not found' });
        }

        res.status(200).json(message);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};

exports.searchMessages = async (req, res) => {
    try {
        const { chatId } = req.params;
        const { query } = req.query; // Prendi il query string dalla richiesta

        if (!mongoose.Types.ObjectId.isValid(chatId)) {
            return res.status(400).json({ error: 'Invalid chatId format' });
        }

        const messages = await Message.find({
            chat_id: chatId,
            $or: [
                { content: { $regex: query, $options: 'i' } },
                { original_file_name: { $regex: query, $options: 'i' } }
            ]
        }).sort({ createdAt: 1 });

        res.status(200).json(messages);
    } catch (err) {
        res.status(500).json({ error: 'Internal server error' });
    }
};