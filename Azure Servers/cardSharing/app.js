const express = require('express');
const path = require('path');
const fs = require('fs');
const logger = require('morgan');

const app = express();
// Set up logging
const accessLogStream = fs.createWriteStream(path.join(__dirname, 'application.log'), { flags: 'a' });
app.use(logger('combined', { stream: accessLogStream }));

// Serve static files from the 'templates' directory
app.use(express.static(path.join(__dirname, 'templates')));

// Serve the apple-app-site-association file
app.get('/apple-app-site-association', (req, res) => {
    res.type('application/json');
    res.sendFile(path.join(__dirname, 'apple-app-site-association'));
});

// Handle requests to the root URL '/'
app.get('/', (req, res) => {
    // Always serve index.html, regardless of whether uniqueName is present
    res.sendFile(path.join(__dirname, 'templates', 'index.html'));
});


const port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
