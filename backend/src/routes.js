const express = require('express');
const router = express.Router();

const MemberController = require('./controllers/memberController');
const AttendanceController = require('./controllers/attendanceController');
const AuthController = require('./controllers/authController');

// Members
router.get('/members', MemberController.list);
router.post('/members', MemberController.create);
router.delete('/members/:id', MemberController.remove);
router.put('/members/:id', MemberController.update);

// Attendance
router.get('/attendance', AttendanceController.list);
router.get('/attendance/:date', AttendanceController.getByDate);
router.post('/attendance', AttendanceController.create);
router.put('/attendance/:date', AttendanceController.update);
router.delete('/attendance/:date', AttendanceController.remove);

// Report: simple member attendance percentage
router.get('/report', async (req, res) => {
  try {
    const AttendanceModel = require('./models/attendanceModel');
    const MemberModel = require('./models/memberModel');
    const records = await AttendanceModel.getAll();
    const members = await MemberModel.getAll();

    const counts = {};
    members.forEach(m => counts[m.id] = 0);

    records.forEach(r => {
      r.presentMemberIds.forEach(id => {
        if (counts[id] !== undefined) counts[id] += 1;
      });
    });

    const totalSessions = records.length || 1;
    const result = {};
    members.forEach(m => {
      const percent = (counts[m.id] / totalSessions) * 100;
      result[`${m.id} ${m.name}`] = Math.round(percent * 10) / 10;
    });

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Auth
router.post('/login', AuthController.login);

module.exports = router;
