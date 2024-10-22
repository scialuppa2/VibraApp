const User = require("../models/user");
const jwt = require("jsonwebtoken");
const config = require("../config/config");

exports.register = async (req, res) => {
  try {
    const { username, phone, email, password, profilePictureUrl } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already in use" });
    }

    const newUser = new User({
      username,
      phone,
      email,
      password: password,
      profilePicture: req.file ? `/uploads/${req.file.filename}` : (profilePictureUrl || '/uploads/default_profile.jpg'),
    });

    await newUser.save();

    res.status(201).json({
      message: "User registered successfully",
      user: {
        username,
        phone,
        email,
        profilePicture: newUser.profilePicture
      }
    });
  } catch (err) {
    console.error("Error during registration:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};



exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      console.log("User not found");
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const passwordMatch = await user.comparePassword(password, user.password.toString());

    if (!passwordMatch) {
      console.log("Password mismatch");
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const token = jwt.sign({ userId: user._id }, config.jwtSecret, {
      expiresIn: "1h",
    });

    res.status(200).json({
      token,
      userId: user.id,
      username: user.username,
      phone: user.phone,
      email: user.email,
      profilePicture: user.profilePicture,
    });
  } catch (err) {
    console.error("Error during login:", err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

