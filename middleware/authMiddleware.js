const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
    // Ambil token dari header request
    const token = req.header('Authorization');

    if (!token) {
        return res.status(401).json({ message: 'Akses ditolak. Token tidak tersedia.' });
    }

    try {
        // Verifikasi token
        const decoded = jwt.verify(token.replace("Bearer ", ""), process.env.SECRET_KEY); // Ganti dengan secret key yang aman
        req.user = decoded; // Simpan data pengguna dari token
        next();
    } catch (error) {
        res.status(400).json({ message: 'Token tidak valid.' });
    }
};
