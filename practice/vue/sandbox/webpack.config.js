var path = require('path');

module.exports = {
    entry: './main.js',
    output: {
        path: path.resolve(__dirname, './dist'),
        publicPath: '/dist/',
        filename: 'build.js'
    },
    resolve: {
        alias: {
            'vue$': 'vue/dist/vue.esm.js' 
        }
    },
    module: {
        loaders: [
            {
                test: /\.vue$/,
                loader: 'vue-loader'
            },
            {
                test: /\.(png|jpg|eot|svg|ttf|woff)/,
                loader: 'url?limit=40000'
            }
        ]
    }
}