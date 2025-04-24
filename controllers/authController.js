const pool = require("../db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken"); // Tambahkan ini
require("dotenv").config(); // Pastikan env digunakan

// REGISTER: Mendaftarkan user baru
exports.registerUser = async (req, res) => {
    try {
        const { nama, email, phone, password } = req.body;

        // Cek apakah email sudah terdaftar
        const userExist = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
        if (userExist.rows.length > 0) {
            return res.status(400).json({ error: "Email sudah terdaftar" });
        }

        // Hash password sebelum menyimpan ke database
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Simpan user ke database
        await pool.query(
            "INSERT INTO users (nama, email, phone, password) VALUES ($1, $2, $3, $4)",
            [nama, email, phone, hashedPassword]
        );

        res.status(201).json({ message: "Registrasi berhasil" });
    } catch (err) {
        console.error("Error saat registrasi:", err.message);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};

// LOGIN: Otentikasi user dan kirim token JWT
exports.loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);

        if (result.rows.length === 0) {
            return res.status(401).json({ error: "Email tidak ditemukan" });
        }

        const user = result.rows[0];
        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            return res.status(401).json({ error: "Password salah" });
        }

        console.log("🔥 User login berhasil:", user); // Debugging

        // Buat token JWT
        const token = jwt.sign(
            { id: user.id, email: user.email, nama: user.nama }, 
            process.env.SECRET_KEY, 
            { expiresIn: "1h" }
        );

        res.json({ token, userId: user.id, message: "Login berhasil" });
    } catch (error) {
        console.error("⚠ Error saat login:", error.message);
        res.status(500).json({ error: "Gagal login" });
    }
};

// MIDDLEWARE: Cek apakah token valid
exports.verifyToken = (req, res, next) => {
    const token = req.headers["authorization"]?.split(" ")[1];
  
    if (!token) return res.status(403).json({ error: "Token tidak ditemukan" });
  
    jwt.verify(token, process.env.SECRET_KEY, (err, decoded) => {
      if (err) return res.status(401).json({ error: "Token tidak valid" });
  
      console.log("Token decoded:", decoded); // 🟢 Pastikan ini ada "id"
      req.user = decoded;
      next();
    });
  };

// VERIFIKASI TOKEN: Pastikan token masih valid
exports.verifyUser = (req, res) => {
    res.json({ message: "Token valid", user: req.user });
};



//  GET: Mendapatkan semua user
exports.getUsers = async (req, res) => {
    try {
        const users = await pool.query("SELECT id, nama, email, phone FROM users");
        res.json(users.rows);
    } catch (err) {
        console.error("Error saat mengambil data users:", err.message);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};

//  PUT: Mengupdate user berdasarkan ID
exports.updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { nama, email, phone, umur, password } = req.body;

        // Cek apakah user ada
        const userExist = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
        if (userExist.rows.length === 0) {
            return res.status(404).json({ error: "User tidak ditemukan" });
        }

        let updateQuery = "UPDATE users SET nama = $1, email = $2, phone = $3, umur = $4 WHERE id = $5";
        let values = [nama, email, phone, umur, id];

        // Jika user juga ingin mengubah password
        if (password) {
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password, salt);
            updateQuery = "UPDATE users SET nama = $1, email = $2, phone = $3, umur = $4, password = $5 WHERE id = $6";
            values = [nama, email, phone, umur, hashedPassword, id];
        }

        await pool.query(updateQuery, values);

        res.json({ message: "User berhasil diperbarui" });
    } catch (err) {
        console.error("Error saat mengupdate user:", err.message);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};


// DELETE: Menghapus user berdasarkan ID dan mereset urutan ID
exports.deleteUser = async (req, res) => {
    try {
        const { id } = req.params;

        // Cek apakah user ada
        const userExist = await pool.query("SELECT * FROM users WHERE id = $1", [id]);
        if (userExist.rows.length === 0) {
            return res.status(404).json({ error: "User tidak ditemukan" });
        }

        // Hapus user berdasarkan ID
        await pool.query("DELETE FROM users WHERE id = $1", [id]);

        // Reset ulang ID agar tetap berurutan
        await pool.query("SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 0) + 1, false)");

        res.json({ message: "User berhasil dihapus dan ID direset" });
    } catch (err) {
        console.error("Error saat menghapus user:", err.message);
        res.status(500).json({ error: "Terjadi kesalahan pada server" });
    }
};


exports.getProfile = async (req, res) => {
    const { id } = req.params;

    try {
        const result = await pool.query(
            "SELECT id, nama, email, phone, umur, COALESCE(profile_picture, '') AS profile_picture FROM users WHERE id = $1",
            [id]
        );

        if (result.rows.length > 0) {
            res.json(result.rows[0]);
        } else {
            res.status(404).json({ message: "User tidak ditemukan" });
        }
    } catch (error) {
        console.error("Error saat mengambil data profil:", error.message);
        res.status(500).json({ error: "Gagal mengambil data user" });
    }
};
// 📌 Buat Profil Baru
exports.createProfile = async (req, res) => {
    const { nama, email, phone, umur, profile_picture } = req.body;

    try {
        const result = await pool.query(
            "INSERT INTO users (nama, email, phone, umur, profile_picture) VALUES ($1, $2, $3, $4, $5) RETURNING *",
            [nama, email, phone, umur, profile_picture || ""]
        );

        res.status(201).json({
            message: "Profil berhasil dibuat",
            user: result.rows[0],
        });
    } catch (error) {
        console.error("❌ Error saat membuat profil:", error.message);
        res.status(500).json({ error: "Gagal membuat profil" });
    }
};

// 📌 Perbarui Profil
exports.updateProfile = async (req, res) => {
    const { id } = req.params;
    const { nama, email, phone, umur, profile_picture } = req.body;

    try {
        const result = await pool.query(
            "UPDATE users SET nama = $1, email = $2, phone = $3, umur = $4, profile_picture = $5 WHERE id = $6 RETURNING *",
            [nama, email, phone, umur, profile_picture || "", id]
        );

        if (result.rows.length > 0) {
            res.json({
                message: "Profil berhasil diperbarui",
                user: result.rows[0],
            });
        } else {
            res.status(404).json({ message: "User tidak ditemukan" });
        }
    } catch (error) {
        console.error("❌ Error saat memperbarui profil:", error.message);
        res.status(500).json({ error: "Gagal memperbarui profil" });
    }
};

// 📌 Hapus Profil
exports.deleteProfile = async (req, res) => {
    const { id } = req.params;

    try {
        const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING *", [id]);

        if (result.rows.length > 0) {
            res.json({ message: "Profil berhasil dihapus" });
        } else {
            res.status(404).json({ message: "User tidak ditemukan" });
        }
    } catch (error) {
        console.error("❌ Error saat menghapus profil:", error.message);
        res.status(500).json({ error: "Gagal menghapus profil" });
    }
};

// Tambah Produk ke Keranjang
exports.addToCart = async (req, res) => {
    try {
      const userId = req.user?.id;
      console.log("ISI REQ.BODY =>", req.body);

      // Cek apakah userId dari JWT tersedia
      if (!userId) {
        return res.status(401).json({ error: "User tidak terautentikasi" });
      }
  
      const { product_name, price, quantity, image } = req.body;
  
      // Validasi input
      if (!product_name || !price || !quantity || !image) {
        return res.status(400).json({ error: "Semua field harus diisi" });
      }
  
      // Insert ke database
      await pool.query(
        "INSERT INTO cart (user_id, product_name, price, quantity, image) VALUES ($1, $2, $3, $4, $5)",
        [userId, product_name, price, quantity, image]
      );
  
      return res.status(200).json({ message: "Produk berhasil ditambahkan ke keranjang" });
    } catch (error) {
      console.error("Gagal menambahkan ke keranjang:", error.message);
      return res.status(500).json({ error: "Gagal menambahkan ke keranjang" });
    }
  };
  
  
