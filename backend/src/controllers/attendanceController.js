const AttendanceModel = require('../models/attendanceModel');
const MemberModel = require('../models/memberModel');

const AttendanceController = {
  async list(req, res) {
    try {
      const records = await AttendanceModel.getAll();
      // Resolve member details for each record
      const members = await MemberModel.getAll();
      const enriched = records.map(r => ({
        ...r,
        presentMembersDetails: r.presentMemberIds.map(id => members.find(m => m.id === id)).filter(Boolean)
      }));
      res.json(enriched);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async getByDate(req, res) {
    try {
      const { date } = req.params; // expect YYYY-MM-DD
      const rec = await AttendanceModel.getByDate(date);
      if (!rec) return res.status(404).json({ error: 'not found' });
      const members = await MemberModel.getAll();
      res.json({ ...rec, presentMembersDetails: rec.presentMemberIds.map(id => members.find(m => m.id === id)).filter(Boolean) });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async create(req, res) {
    try {
      const { date, presentMemberIds } = req.body; // date should be YYYY-MM-DD
      if (!date || !presentMemberIds) return res.status(400).json({ error: 'date and presentMemberIds required' });
      const created = await AttendanceModel.create(date, presentMemberIds);
      res.status(201).json(created);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async update(req, res) {
    try {
      const { date } = req.params;
      const { presentMemberIds } = req.body;
      if (!presentMemberIds) return res.status(400).json({ error: 'presentMemberIds required' });
      const updated = await AttendanceModel.updateByDate(date, presentMemberIds);
      res.json(updated);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  },
  async remove(req, res) {
    try {
      const { date } = req.params;
      await AttendanceModel.deleteByDate(date);
      res.json({ ok: true });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
};

module.exports = AttendanceController;
