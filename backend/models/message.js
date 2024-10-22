const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
    content: {
        type: String,
        required: function() {
            return !this.file_url;
        }
    },
    chat_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Chat', required: true },
    sender_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    sender_username: String,
    file_url: String,
    original_file_name: String,
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Message', messageSchema);
