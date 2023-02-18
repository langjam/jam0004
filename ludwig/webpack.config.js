const path = require('path');

module.exports = {
    entry: {
        demo: "./lib/js/src/Demo.bs.js",
    },
    output: {
        filename: "[name].js",
        path: path.resolve(__dirname, "dist/"),
    }
};