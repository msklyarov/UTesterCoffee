(function() {
  var app, bodyParser, express, path, pug, routes;

  express = require('express');

  path = require('path');

  bodyParser = require('body-parser');

  routes = require('./server/routes');

  pug = require('pug');

  app = express();

  app.set('views', path.join(__dirname, 'views'));

  app.set('view engine', 'pug');

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded({
    extended: false
  }));

  app.use(express["static"](path.join(__dirname, 'public')));

  routes.configRoutes(app);

  module.exports = app;

}).call(this);
