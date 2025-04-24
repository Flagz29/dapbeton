require("dotenv").config();
const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/authRoutes");
const productRoutes = require('./routes/product');
const cartRoutes = require('./routes/cart');



const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/uploads", express.static("uploads")); // Untuk menyimpan foto profil

// Rute API
app.use("/api/auth", authRoutes); // Rute autentikasi
app.use('/api', cartRoutes);
app.use('/api/', productRoutes);


// Jalankan server
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
