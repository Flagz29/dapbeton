const express = require('express');
const router = express.Router();
const pool = require('../db'); // koneksi PostgreSQL
const verifyToken = require('../middleware/authMiddleware'); // JWT middleware

// 🔸 Tambah item ke cart
router.post('/cart', verifyToken, async (req, res) => {
  try {
    const { product_name, price, quantity, image } = req.body;
    const user_id = req.user.id;

    const newCart = await pool.query(
      'INSERT INTO carts (user_id, product_name, price, quantity, image) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [user_id, product_name, price, quantity, image]
    );

    res.json(newCart.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// 🔸 Hapus 1 item dari cart (pakai id cart)
router.delete('/cart/:id', verifyToken, async (req, res) => {
  try {
    const cartId = req.params.id;
    const userId = req.user.id;

    const deleted = await pool.query(
      'DELETE FROM carts WHERE id = $1 AND user_id = $2 RETURNING *',
      [cartId, userId]
    );

    if (deleted.rows.length === 0) {
      return res.status(404).json({ message: 'Cart item not found' });
    }

    res.json({ message: 'Item berhasil dihapus dari keranjang' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// 🔸 Hapus semua cart user
router.delete('/cart', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    await pool.query('DELETE FROM carts WHERE user_id = $1', [userId]);
    res.json({ message: 'Semua item di keranjang berhasil dihapus' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// 🔸 Lihat Isi Keranjang
router.get('/cart', verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;

    const carts = await pool.query('SELECT * FROM carts WHERE user_id = $1', [userId]);

    if (carts.rows.length === 0) {
      return res.status(404).json({ message: 'Keranjang Anda kosong' });
    }

    res.json(carts.rows);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// 🔸 Update Quantity Item di Keranjang
router.put('/cart/:id', verifyToken, async (req, res) => {
  try {
    const cartId = req.params.id;
    const { quantity } = req.body;
    const userId = req.user.id;

    // Cek apakah cart item ada
    const cartItem = await pool.query(
      'SELECT * FROM carts WHERE id = $1 AND user_id = $2',
      [cartId, userId]
    );

    if (cartItem.rows.length === 0) {
      return res.status(404).json({ message: 'Cart item tidak ditemukan' });
    }

    // Update quantity
    const updatedCart = await pool.query(
      'UPDATE carts SET quantity = $1 WHERE id = $2 RETURNING *',
      [quantity, cartId]
    );

    res.json(updatedCart.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

module.exports = router;
