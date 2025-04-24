const pool = require('../../db');

const createUserTable = async () => {
  const query = `
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      phone VARCHAR(15) UNIQUE NOT NULL,
      password TEXT NOT NULL
    );
  `;

  try {
    await pool.query(query);
    console.log("Tabel users berhasil dibuat!");
  } catch (error) {
    console.error("Gagal membuat tabel users:", error);
  }
};

module.exports = { createUserTable };
