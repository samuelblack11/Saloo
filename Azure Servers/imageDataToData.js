const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Create a readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.question("Please enter the input file name only, not the path: ", (inputFile) => {
  const inputPath = 'UserReportsOfOffensiveContent/' + inputFile;

  // Read the JSON file
  fs.readFile(inputPath, 'utf8', (err, data) => {
    if (err) {
      console.error('Error reading the file:', err);
      rl.close();
      return;
    }

    const jsonData = JSON.parse(data);
    const imageDataBase64 = jsonData.collage;

    // Decode the Base64 data
    const imageData = Buffer.from(imageDataBase64, 'base64');

    const outputFileName = path.parse(inputFile).name + '.png';
    const outputPath = 'UserReportsOfOffensiveContent/ConvertedImage-' + outputFileName;

    // Write the decoded image data to an image file
    fs.writeFile(outputPath, imageData, (err) => {
      if (err) {
        console.error('Error writing the file:', err);
      } else {
        console.log('File saved:', outputPath);
      }
      rl.close();
    });
  });
});
