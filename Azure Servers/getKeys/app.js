const express = require('express');
const basicAuth = require('express-basic-auth');
const { SecretClient } = require('@azure/keyvault-secrets');
const app = express();
const port = process.env.PORT || 8080;
require('dotenv').config();
const { DefaultAzureCredential } = require('@azure/identity');

// Configure basic auth
const myAuthorizer = (username, password) => {
    const userMatches = basicAuth.safeCompare(username, process.env.BASIC_AUTH_USERNAME);
    const passwordMatches = basicAuth.safeCompare(password, process.env.BASIC_AUTH_PASSWORD);
    return userMatches & passwordMatches;
};

app.use(basicAuth({
    authorizer: myAuthorizer,
    challenge: true
}));

// Azure Key Vault Client Setup
const vaultName = process.env.VAULT_NAME
const url = `https://${vaultName}.vault.azure.net`;
const credential = new DefaultAzureCredential();
const client = new SecretClient(url, credential);

// Routes
app.get('/getkey', async (req, res) => {
    const keyName = req.query.keyName;
    try {
        const secret = await client.getSecret(keyName);
        res.json({ value: secret.value });
    } catch (e) {
        res.status(500).send(`Error fetching secret: ${e.message}`);
    }
});

app.get('/getkeys', async (req, res) => {
    const keyNames = req.query.keyNames.split(',');
    if (!keyNames.length) {
        return res.status(400).send({ error: "No keyNames parameter provided" });
    }

    try {
        const result = {};
        for (const keyName of keyNames) {
            try {
                const secret = await client.getSecret(keyName);
                result[keyName] = secret.value;
            } catch (e) {
                console.error(`Error getting secret for key ${keyName}: ${e.message}`);
            }
        }
        res.json(result);
    } catch (e) {
        res.status(500).send(`Error: ${e.message}`);
    }
});

// Start Server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
