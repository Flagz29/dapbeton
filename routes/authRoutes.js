const express = require("express");

const {
  registerUser, loginUser, getUsers, updateUser, deleteUser,
  verifyToken, verifyUser, getProfile, createProfile,
  deleteProfile, updateProfile, addToCart
} = require("../controllers/authController");

const {
  getAllProducts, getProductById, addProduct
} = require("../controllers/productController"); // <- pastikan baris ini ada


const router = express.Router();

router.post("/register", registerUser);
router.post("/login", loginUser);
router.get("/users", getUsers);
router.put("/users/:id", updateUser);
router.delete("/users/:id", deleteUser);
router.get("/verify", verifyToken, verifyUser);
router.get("/profile/:id", getProfile); 
router.post("/profile/:id", createProfile);
router.delete("/profile/:id", deleteProfile);
router.put("/profile/:id", updateProfile);
router.post("/cart", verifyToken, addToCart); 
// Produk
router.get("/products", getAllProducts);
router.get("/products/:id", getProductById);
router.post("/products", addProduct); // Opsional, hanya untuk admin


module.exports = router;
