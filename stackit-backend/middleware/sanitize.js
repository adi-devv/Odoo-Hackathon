const sanitizeHtml = require('sanitize-html');

const sanitize = (req, res, next) => {
  if (req.body.description) {
    req.body.description = sanitizeHtml(req.body.description, {
      allowedTags: ['b', 'i', 'u', 's', 'p', 'ul', 'ol', 'li', 'a', 'img'],
      allowedAttributes: { a: ['href'], img: ['src'] }
    });
  }
  if (req.body.content) {
    req.body.content = sanitizeHtml(req.body.content, {
      allowedTags: ['b', 'i', 'u', 's', 'p', 'ul', 'ol', 'li', 'a', 'img'],
      allowedAttributes: { a: ['href'], img: ['src'] }
    });
  }
  next();
};

module.exports = sanitize;