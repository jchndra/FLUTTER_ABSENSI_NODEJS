const MemberModel = require('../models/memberModel');

const MemberController = {
  async list(req, res) {
    try {
      const members = await MemberModel.getAll();
      res.json(members);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async create(req, res) {
    try {
      const { id, name, photoUrl } = req.body;
      if (!id || !name) return res.status(400).json({ error: 'id and name required' });
      const created = await MemberModel.create({ id, name, photoUrl });
      res.status(201).json(created);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async update(req, res) {
    try {
      const { id } = req.params;
      const changes = req.body || {};
      // Basic validation: require at least one updatable field
      if (!changes.name && !changes.photoUrl) {
        return res.status(400).json({ error: 'nothing to update' });
      }
      const updated = await MemberModel.update(id, changes);
      res.json(updated);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async remove(req, res) {
    try {
      const { id } = req.params;
      await MemberModel.remove(id);
      res.json({ ok: true });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
};

module.exports = MemberController;
