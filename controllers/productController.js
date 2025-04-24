const pool = require('../db');

// Ambil semua produk beton
exports.getAllProducts = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Gagal mengambil data produk:", error.message);
    res.status(500).json({ error: "Gagal mengambil produk" });
  }
};

// Ambil produk berdasarkan ID
exports.getProductById = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Produk tidak ditemukan" });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error("Gagal mengambil detail produk:", error.message);
    res.status(500).json({ error: "Gagal mengambil detail produk" });
  }
};

// Tambah produk baru (jika diperlukan untuk admin)
exports.addProduct = async (req, res) => {
  const { product_name, description, image, price } = req.body;

  if (!product_name || !description || !image || !price) {
    return res.status(400).json({ error: "Semua field harus diisi" });
  }

  try {
    await pool.query(
      'INSERT INTO products (product_name, description, image, price) VALUES ($1, $2, $3, $4)',
      [product_name, description, image, price]
    );
    res.status(201).json({ message: "Produk berhasil ditambahkan" });
  } catch (error) {
    console.error("Gagal menambahkan produk:", error.message);
    res.status(500).json({ error: "Gagal menambahkan produk" });
  }
};
