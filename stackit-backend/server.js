const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const db = new sqlite3.Database('db/stackit.db', (err) => {
  if (err) console.error('Database connection error:', err);
  else console.log('Connected to SQLite database');
});

const sendNotification = (userId, message, callback) => {
  db.run(
    'INSERT INTO notifications (user_id, message) VALUES (?, ?)',
    [userId, message],
    callback
  );
};

app.post('/register', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).send('Username and password required');
  db.run(
    'INSERT INTO users (username, password) VALUES (?, ?)',
    [username, password],
    function (err) {
      if (err) return res.status(400).send('Username already exists');
      res.status(201).send({ id: this.lastID, username });
    }
  );
});

app.post('/questions', (req, res) => {
  const { title, description, tags, user_id } = req.body;
  if (!title || !user_id) return res.status(400).send('Title and user_id required');
  db.run(
    'INSERT INTO questions (title, description, tags, user_id) VALUES (?, ?, ?, ?)',
    [title, description, JSON.stringify(tags), user_id],
    function (err) {
      if (err) return res.status(500).send('Error posting question');
      res.status(201).send({ id: this.lastID });
    }
  );
});

app.get('/questions', (req, res) => {
  db.all('SELECT q.*, u.username FROM questions q JOIN users u ON q.user_id = u.id', (err, rows) => {
    if (err) return res.status(500).send('Error fetching questions');
    res.json(rows.map(row => ({
      ...row,
      tags: JSON.parse(row.tags)
    })));
  });
});

app.post('/questions/:id/answers', (req, res) => {
  const { content, user_id } = req.body;
  const question_id = req.params.id;
  if (!content || !user_id) return res.status(400).send('Content and user_id required');
  db.run(
    'INSERT INTO answers (question_id, content, user_id) VALUES (?, ?, ?)',
    [question_id, content, user_id],
    function (err) {
      if (err) return res.status(500).send('Error posting answer');
      db.get('SELECT user_id FROM questions WHERE id = ?', [question_id], (err, row) => {
        if (row) {
          sendNotification(row.user_id, `New answer on your question by user ${user_id}`, () => {});
        }
      });
      res.status(201).send({ id: this.lastID });
    }
  );
});

app.post('/answers/:id/vote', (req, res) => {
  const { vote } = req.body;
  const answer_id = req.params.id;
  db.run(
    'UPDATE answers SET votes = votes + ? WHERE id = ?',
    [vote, answer_id],
    function (err) {
      if (err) return res.status(500).send('Error voting');
      res.status(200).send('Vote recorded');
    }
  );
});

app.post('/answers/:id/accept', (req, res) => {
  const answer_id = req.params.id;
  const { user_id } = req.body;
  db.get('SELECT question_id FROM answers WHERE id = ?', [answer_id], (err, row) => {
    if (err) return res.status(500).send('Error');
    db.get('SELECT user_id FROM questions WHERE id = ?', [row.question_id], (err, q) => {
      if (q.user_id !== user_id) return res.status(403).send('Only question owner can accept');
      db.run('UPDATE answers SET is_accepted = TRUE WHERE id = ?', [answer_id], (err) => {
        if (err) return res.status(500).send('Error accepting answer');
        res.status(200).send('Answer accepted');
      });
    });
  });
});

app.get('/notifications/:user_id', (req, res) => {
  const user_id = req.params.user_id;
  db.all('SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC', [user_id], (err, rows) => {
    if (err) return res.status(500).send('Error fetching notifications');
    res.json(rows);
  });
});

app.post('/notifications/:id/read', (req, res) => {
  const notification_id = req.params.id;
  db.run('UPDATE notifications SET is_read = TRUE WHERE id = ?', [notification_id], (err) => {
    if (err) return res.status(500).send('Error marking notification');
    res.status(200).send('Notification marked as read');
  });
});

app.post('/admin/ban', (req, res) => {
  const { user_id, admin_id } = req.body;
  db.get('SELECT role FROM users WHERE id = ?', [admin_id], (err, row) => {
    if (err || row.role !== 'admin') return res.status(403).send('Admin access required');
    db.run('UPDATE users SET role = "banned" WHERE id = ?', [user_id], (err) => {
      if (err) return res.status(500).send('Error banning user');
      res.status(200).send('User banned');
    });
  });
});

app.post('/admin/message', (req, res) => {
  const { message, admin_id } = req.body;
  db.get('SELECT role FROM users WHERE id = ?', [admin_id], (err, row) => {
    if (err || row.role !== 'admin') return res.status(403).send('Admin access required');
    db.all('SELECT id FROM users WHERE role != "banned"', (err, users) => {
      if (err) return res.status(500).send('Error fetching users');
      users.forEach(user => {
        sendNotification(user.id, message, () => {});
      });
      res.status(200).send('Message sent to all users');
    });
  });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
