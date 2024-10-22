const mongoose = require('mongoose');

const chatSchema = new mongoose.Schema({
  title: String,
  participants: [{
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    username: String,
    phone: String,
    profilePicture: String,
  }],
  messages: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Message' }],
}, { timestamps: true });

module.exports = mongoose.model('Chat', chatSchema);
