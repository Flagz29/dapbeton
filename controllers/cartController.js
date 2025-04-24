const pool = require('../db');

// Ambil semua item cart milik user tertentu
exports.getCartByUser = async (req, res) => {
  const userId = req.params.userId;
  try {
    const result = await pool.query(
      `SELECT cart.*, products.name AS product_name, products.image, products.price
       FROM cart
       JOIN products ON cart.product_id = products.id
       WHERE cart.user_id = $1`,
      [userId]
    );
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Gagal mengambil cart:", error.message);
    res.status(500).json({ error: "Gagal mengambil cart" });
  }
};

// Tambah item ke cart
exports.addToCart = async (req, res) => {
  const { user_id, product_id, quantity } = req.body;

  if (!user_id || !product_id || !quantity) {
    return res.status(400).json({ error: "Semua field harus diisi" });
  }

  try {
    // Cek apakah item sudah ada di cart
    const existing = await pool.query(
      'SELECT * FROM cart WHERE user_id = $1 AND product_id = $2',
      [user_id, product_id]
    );

    if (existing.rows.length > 0) {
      // Update jumlah
      await pool.query(
        'UPDATE cart SET quantity = quantity + $1 WHERE user_id = $2 AND product_id = $3',
        [quantity, user_id, product_id]
      );
    } else {
      // Insert baru
      await pool.query(
        'INSERT INTO cart (user_id, product_id, quantity) VALUES ($1, $2, $3)',
        [user_id, product_id, quantity]
      );
    }

    res.status(201).json({ message: "Item ditambahkan ke cart" });
  } catch (error) {
    console.error("Gagal menambahkan ke cart:", error.message);
    res.status(500).json({ error: "Gagal menambahkan ke cart" });
  }
};

// Hapus item dari cart
exports.removeFromCart = async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM cart WHERE id = $1', [id]);
    res.status(200).json({ message: "Item berhasil dihapus dari cart" });
  } catch (error) {
    console.error("Gagal menghapus item dari cart:", error.message);
    res.status(500).json({ error: "Gagal menghapus item dari cart" });
  }
};

// Kosongkan seluruh cart user
exports.clearCart = async (req, res) => {
  const userId = req.params.userId;
  try {
    await pool.query('DELETE FROM cart WHERE user_id = $1', [userId]);
    res.status(200).json({ message: "Cart berhasil dikosongkan" });
  } catch (error) {
    console.error("Gagal mengosongkan cart:", error.message);
    res.status(500).json({ error: "Gagal mengosongkan cart" });
  }
};

exports.updateQuantity = async (req, res) => {
    const { userId, productId } = req.params;
    const { quantity } = req.body; // Pastikan body request berisi 'quantity'
  
    if (quantity < 1) {
      return res.status(400).json({ error: "Quantity harus lebih dari 0" });
    }
  
    try {
      // Update quantity item di cart
      const result = await pool.query(
        'UPDATE cart SET quantity = $1 WHERE user_id = $2 AND product_id = $3 RETURNING *',
        [quantity, userId, productId]
      );
  
      if (result.rowCount === 0) {
        return res.status(404).json({ error: "Item tidak ditemukan dalam keranjang" });
      }
  
      res.status(200).json({ message: "Quantity berhasil diperbarui", data: result.rows[0] });
    } catch (error) {
      console.error("Gagal memperbarui quantity:", error.message);
      res.status(500).json({ error: "Gagal memperbarui quantity" });
    }
  };
  