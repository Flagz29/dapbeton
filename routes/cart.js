const express = require('express');
const router = express.Router();
const pool = require('../db'); // koneksi PostgreSQL
const verifyToken = require('../middleware/authMiddleware'); // JWT middleware

router.get('/cart', verifyToken, async (req, res) => {
  const userId = req.user.id;
  const result = await pool.query(`
    SELECT c.id, c.product_id, p.title, p.price, p.image, c.quantity, c.selected
    FROM cart_items c
    JOIN products p ON p.id = c.product_id
    WHERE c.user_id = $1
  `, [userId]);

  res.json(result.rows);
});

router.put('/cart/:id', verifyToken, async (req, res) => {
  const { quantity, selected } = req.body;
  const cartId = req.params.id;

  await pool.query(`
    UPDATE cart_items
    SET quantity = $1, selected = $2
    WHERE id = $3
  `, [quantity, selected, cartId]);

  res.json({ message: 'Cart updated' });
});

router.delete('/cart/:id', verifyToken, async (req, res) => {
  await pool.query(`DELETE FROM cart_items WHERE id = $1`, [req.params.id]);
  res.json({ message: 'Item removed' });
});

router.post('/cart/:productId', verifyToken, async (req, res) => {
  const userId = req.user.id;
  const productId = parseInt(req.params.productId, 10);
  const { quantity } = req.body;

  try {
    // Pastikan produk ada
    const productCheck = await pool.query(
      'SELECT * FROM products WHERE id = $1',
      [productId]
    );

    if (productCheck.rows.length === 0) {
      return res.status(404).json({ message: 'Produk tidak ditemukan' });
    }

    // Cek apakah produk sudah ada di keranjang user
    const existing = await pool.query(
      'SELECT id, quantity FROM cart_items WHERE user_id = $1 AND product_id = $2',
      [userId, productId]
    );

    if (existing.rows.length > 0) {
      // Kalau sudah ada, update quantity
      const newQty = existing.rows[0].quantity + quantity;
      await pool.query(
        'UPDATE cart_items SET quantity = $1 WHERE id = $2',
        [newQty, existing.rows[0].id]
      );
      return res.json({ message: 'Quantity diperbarui di keranjang' });
    }

    // Kalau belum ada, tambahkan item baru
    await pool.query(
      'INSERT INTO cart_items (user_id, product_id, quantity, selected) VALUES ($1, $2, $3, true)',
      [userId, productId, quantity]
    );

    res.json({ message: 'Produk berhasil ditambahkan ke keranjang' });
  } catch (err) {
    console.error('Gagal menambahkan ke keranjang:', err);
    res.status(500).json({ message: 'Kesalahan server' });
  }
});

router.delete('/cart', verifyToken, async (req, res) => {
  const userId = req.user.id;

  try {
    await pool.query('DELETE FROM cart_items WHERE user_id = $1', [userId]);
    res.json({ message: 'Semua item berhasil dihapus dari keranjang' });
  } catch (err) {
    console.error('Gagal menghapus semua item:', err);
    res.status(500).json({ message: 'Kesalahan server' });
  }
});

module.exports = router;
