const express = require('express');
const app = express();
app.use(express.json());

app.patch('/repos/:owner/:repo', (req, res) => {
  console.log(`Mock intercepted: PATCH /repos/${req.params.owner}/${req.params.repo}`);
  console.log('Request headers:', JSON.stringify(req.headers));
  console.log('Request body:', JSON.stringify(req.body));

  // Validate request body
  const { is_template } = req.body;
  if (typeof is_template !== 'boolean') {
    return res.status(400).json({ message: 'Bad Request: is_template must be a boolean' });
  }

  // Simulate different responses based on repo and owner
  if (req.params.owner === 'test-owner' && req.params.repo === 'test-repo') {
    res.status(200).json({ name: req.params.repo, is_template });
  } else if (req.params.repo === 'existing-repo') {
    res.status(403).json({ message: 'Forbidden: Repository cannot be modified' });
  } else {
    res.status(404).json({ message: 'Not Found: Repository or owner does not exist' });
  }
});

app.listen(3000, () => {
  console.log('Mock server listening on http://127.0.0.1:3000...');
});
