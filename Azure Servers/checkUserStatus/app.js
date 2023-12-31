require('dotenv').config();
const express = require('express');
const { TableClient, AzureNamedKeyCredential } = require('@azure/data-tables');

// Extract the environment variables
const accountName = process.env.AZURE_STORAGE_ACCOUNT_NAME;
const accountKey = process.env.AZURE_STORAGE_ACCOUNT_KEY;

// Initialize the Azure Table Client
const credential = new AzureNamedKeyCredential(accountName, accountKey);
const tableClient = new TableClient(
    `https://${accountName}.table.core.windows.net`,
    "Users", // Your table name
    credential
);

const app = express();
app.use(express.json());

// Create user endpoint
app.post('/create_user', async (req, res) => {
    const user_id = req.body.user_id;
    const user_entity = {
        "RowKey": user_id,
        "is_banned": false
    };
    
    try {
        await tableClient.upsertEntity(user_entity, UpdateMode.MERGE);
        res.json({ message: `User ${user_id} created successfully` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get users endpoint
app.get('/get_users', async (req, res) => {
    try {
        const users = tableClient.listEntities();
        const user_list = [];
        for await (const user of users) {
            user_list.push(user);
        }
        res.json({ users: user_list });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get user endpoint
app.get('/get_user', async (req, res) => {
    const user_id = req.query.user_id;
    try {
        const user = await tableClient.getEntity('PartitionKey', user_id);
        res.json({ [user_id]: user.is_banned });
    } catch (error) {
        res.json({ [`User ${user_id} not found`]: "" });
    }
});

// Check if user is banned
app.get('/is_banned', async (req, res) => {
    const user_id = req.query.user_id;
    try {
        const user = await tableClient.getEntity('PartitionKey', user_id);
        res.json({ "is_banned": user.is_banned });
    } catch (error) {
        res.json({ "is_banned": false });
    }
});

// Update user endpoint
app.post('/update_user', async (req, res) => {
    const user_id = req.query.user_id;
    const is_banned = req.query.is_banned;

    try {
        const user = await tableClient.getEntity('PartitionKey', user_id);
        user.is_banned = is_banned;
        await tableClient.updateEntity(user, UpdateMode.REPLACE);
        res.json({ message: `User ${user_id} has been updated` });
    } catch (error) {
        res.status(404).json({ message: `User ${user_id} not found` });
    }
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
