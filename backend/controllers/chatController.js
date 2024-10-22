const mongoose = require("mongoose");
const Chat = require("../models/chat");

exports.createChat = async (req, res) => {
  try {
    const chat = new Chat(req.body);
    await chat.save();
    res.status(201).json(chat);
    console.log("Received chat data:", chat);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.getChatById = async (req, res) => {
  const chat = await Chat.findById(req.params.id).populate("messages");
  if (!chat) {
    return res.status(404).json({ error: "Chat not found" });
  }
  res.status(200).json(chat);
};

exports.getChatsByUserId = async (req, res) => {
  const { userId } = req.params;
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    return res.status(400).json({ error: "Invalid user ID" });
  }
  try {
    const chats = await Chat.find({ "participants.user_id": userId }).populate("messages");
    res.status(200).json(chats);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.deleteChat = async (req, res) => {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ error: "Invalid chat ID" });
  }

  try {
    const chat = await Chat.findByIdAndDelete(id);
    if (!chat) {
      return res.status(404).json({ error: "Chat not found" });
    }

    if (chat.participants.length > 2) {
      return res.status(400).json({ error: "Cannot delete a group chat" });
    }

    res.status(200).json({ message: "Chat deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.leaveGroup = async (req, res) => {
  const { id } = req.params;
  const { userId } = req.body;

  try {
    const userIdObject = new mongoose.Types.ObjectId(userId);

    const result = await Chat.updateOne(
      { _id: id },
      { $pull: { participants: { user_id: userIdObject } } }
    );

    if (result.modifiedCount === 0) {
      return res.status(404).json({ message: "Chat not found or user not in the chat" });
    }

    res.status(200).json({ message: "Successfully left the group" });
  } catch (error) {
    console.error("Server Error:", error);
    res.status(500).json({ message: "Server error", error });
  }
};

exports.addUserToChat = async (req, res) => {
  const { id } = req.params;
  const { userId, username, phone, profilePicture } = req.body;

  try {
    const chat = await Chat.findById(id);

    if (!chat) {
      return res.status(404).json({ message: "Chat not found" });
    }

    if (chat.participants.some(participant => participant.user_id.toString() === userId)) {
      return res.status(400).json({ message: "User already in the chat" });
    }

    chat.participants.push({
      user_id: userId,
      username: username,
      phone: phone,
      profilePicture: profilePicture
    });

    await chat.save();

    res.status(200).json({ message: "User added to the group successfully" });
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};

exports.searchChats = async (req, res) => {
  const { query } = req.query;

  if (!query) {
    return res.status(400).json({ error: "Query parameter is required" });
  }

  try {
    const regex = new RegExp(query, 'i');
    const chats = await Chat.find({
      $or: [
        { title: { $regex: regex } },
        { 'participants.username': { $regex: regex } }
      ]
    }).populate("messages");
    
    res.status(200).json(chats);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
