const express = require('express');
const fs = require('fs');
const app = express();
const port = 5000;

app.get('/plusone/:value', (req, res) => {
    const value = parseInt(req.params.value);
    const result = value + 1;
    fs.writeFile('/data/output.txt', `Input: ${value}, Output: ${result}\n`, () => {});
    res.send(result.toString());
});

app.listen(port, () => {
    console.log(`Node service running at http://localhost:${port}`);
});
