const pool = require("../../db");

// Buat Tabel Products jika belum ada
const createProductTable = async () => {
  const query = `
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      description TEXT,
      image TEXT,
      stock INTEGER DEFAULT 0,
      created_at TIMESTAMP DEFAULT now()
    )
  `;
  try {
    await pool.query(query);
    console.log("✅ Tabel 'products' siap digunakan");
  } catch (error) {
    console.error("❌ Gagal membuat tabel products:", error.message);
  }
};

module.exports = { createProductTable };
