const UserModel = require('../models/userModel');
const bcrypt = require('bcryptjs');

const AuthController = {
  // POST /api/login
  async login(req, res) {
    try {
      const { username, password } = req.body || {};
      if (!username || !password) return res.status(400).json({ error: 'username and password required' });

      const user = await UserModel.getByUsername(username);
      if (!user) return res.status(401).json({ error: 'invalid credentials' });

      const match = await bcrypt.compare(password, user.password_hash);
      if (!match) return res.status(401).json({ error: 'invalid credentials' });

      // Successful login: return minimal user info (no token for now)
      return res.json({ ok: true, user: { id: user.id, username: user.username, role: user.role } });
    } catch (err) {
      return res.status(500).json({ error: err.message });
    }
  }
};

module.exports = AuthController;
