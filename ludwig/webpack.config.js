const HtmlWebpackPlugin = require("html-webpack-plugin");
const path = require('path');

module.exports = {
    entry: {
        main: "./src/main.bs.js",
    },
    output: {
        filename: "[name].js",
        path: path.resolve(__dirname, "dist/"),
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'Ludwig',
        }),
    ],
};