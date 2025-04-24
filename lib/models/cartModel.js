const pool = require("../../db");

// Buat Tabel Cart jika belum ada
const createCartTable = async () => {
  const query = `
    CREATE TABLE IF NOT EXISTS cart (
      id SERIAL PRIMARY KEY,
      user_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL,
      quantity INTEGER DEFAULT 1,
      created_at TIMESTAMP DEFAULT NOW()
    )
  `;
  try {
    await pool.query(query);
    console.log("✅ Tabel 'cart' siap digunakan");
  } catch (error) {
    console.error("❌ Gagal membuat tabel cart:", error.message);
  }
};

module.exports = { createCartTable };
