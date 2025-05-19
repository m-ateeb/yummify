import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import cors from 'cors';




// Initialize Express
const app = express();
const PORT = process.env.PORT || 4500;
  
// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});