import dotenv from 'dotenv';
import mongoose from 'mongoose';
dotenv.config();
import express from 'express';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 4500;

// Middlewares
app.use(cors());
app.use(express.json());

// MongoDB connection
mongoose.connect("mongodb://localhost:27017/yummify", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log("Connection to MongoDB successful"))
.catch((err) => console.error("Connection to MongoDB failed:", err));

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
