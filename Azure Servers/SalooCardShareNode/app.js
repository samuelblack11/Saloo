const express = require('express');
const path = require('path');
const fs = require('fs');
const logger = require('morgan');

const app = express();

// Set up logging
const accessLogStream = fs.createWriteStream(path.join(__dirname, 'application.log'), { flags: 'a' });
app.use(logger('combined', { stream: accessLogStream }));

// Serve the HTML file directly
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'templates', 'index.html'));
});
// ...


const port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});