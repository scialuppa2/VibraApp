const express = require("express");
const http = require("http");
const socketIo = require("socket.io");
const config = require("./config/config");
const mongoose = require("./config/database");
const authRoutes = require("./routes/authRoutes");
const userRoutes = require("./routes/userRoutes");
const messageRoutes = require("./routes/messageRoutes");
const chatRoutes = require("./routes/chatRoutes");
const path = require("path");
const cors = require("cors");
const Message = require('./models/message');
const Chat = require('./models/chat');
const User = require('./models/user');
const messageController = require("./controllers/messageController");


const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    allowedHeaders: ["my-custom-header"],
    credentials: true,
  },
});

app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "DELETE"],
  })
);

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/messages", messageRoutes);
app.use("/api/chats", chatRoutes);

io.on("connection", (socket) => {
  console.log("New client connected:", socket.id);

  socket.on("joinRoom", (roomId) => {
    console.log(`Client ${socket.id} is trying to join room: ${roomId}`);
    socket.join(roomId);
    console.log(`Client ${socket.id} joined room: ${roomId}`);
  });

  socket.on("sendMessage", async (data) => {
    try {
      const { chatId, message } = data;
  
      if (!message) {
        console.error("Message is undefined");
        return;
      }
  
      const { sender_id, content, sender_username, filePath } = message;
  
      if (!sender_id || !content || !sender_username) {
        console.error("Message properties are missing");
        return;
      }
  
      if (
        !mongoose.Types.ObjectId.isValid(sender_id) ||
        !mongoose.Types.ObjectId.isValid(chatId)
      ) {
        console.log("Invalid ID format");
        return;
      }
  
      const messageData = {
        content: content || '',
        chat_id: chatId,
        sender_id,
        sender_username,
        file_url: filePath,
        original_file_name: filePath,
      };
  
      const newMessage = new Message(messageData);
      await newMessage.save();
  
      console.log("Message saved with ID:", newMessage._id);
  
      await Chat.findByIdAndUpdate(chatId, { $push: { messages: newMessage._id } });
  
      const sender = await User.findById(newMessage.sender_id);
      if (!sender) {
        console.log("Sender not found");
        return;
      }
  
      console.log("Message sent to chat:", newMessage.chat_id.toString());
      io.to(newMessage.chat_id.toString()).emit("newMessage", newMessage);
    } catch (e) {
      console.error("Error while sending or receiving message", e);
    }
  });
  

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

messageController.setSocket(io);

const PORT = config.port || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
