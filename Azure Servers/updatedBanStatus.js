require('dotenv').config();
const axios = require('axios');
const readline = require('readline');

// Base URL from .env file
const baseURL = process.env.BASE_URL;

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const updateBanStatus = async (userId, banStatus) => {
    banStatus = banStatus.toLowerCase() === 'true';

    const lookupUrl = `${baseURL}/get_user?user_id=${userId}`;
    try {
        const lookupResponse = await axios.get(lookupUrl);
        console.log("---");
        console.log(lookupResponse.status);

        if (lookupResponse.status === 200) {
            const user = lookupResponse.data;

            const updateUrl = `${baseURL}/update_user?user_id=${userId}&is_banned=${banStatus}`;
            const updateResponse = await axios.post(updateUrl, user);

            if (updateResponse.status === 200) {
                console.log(`User ${userId} has been banned successfully`);
            } else {
                console.log(`Failed to ban user ${userId}. Status code: ${updateResponse.status}`);
            }
        }
    } catch (error) {
        console.log(`Failed to retrieve/update user ${userId}. Status code: ${error.response ? error.response.status : error.message}`);
    }
};

rl.question("Enter the user ID to ban: ", (userId) => {
    rl.question("Should the user be banned? (Enter 'True' or 'False'): ", (banStatus) => {
        updateBanStatus(userId, banStatus);
        rl.close();
    });
});

