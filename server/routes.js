(function() {
  var Controller, config, configRoutes, controller, express, router, routes;

  express = require('express');

  router = express.Router();

  config = require('config');

  Controller = require('./controllers/testController');

  routes = {
    getTestList: '/tests/getAll',
    getTotalQuestsNum: '/:testName/getQuestsNum',
    setExamInfo: '/setExamInfo/:testName/:firstName/:lastName/:questsToAskNum',
    getCurrentQuest: '/getCurrQuest/:testName/:firstName/:lastName',
    setQuestAnswers: '/setQuestAnswers/:testName/:firstName/:lastName',
    getTestResult: '/getTestResult/:testName/:firstName/:lastName'
  };

  controller = new Controller();

  router.get(routes.getTestList, controller.getTestList.bind(controller));

  router.get(routes.getTotalQuestsNum, controller.getTotalQuestsNum.bind(controller));

  router.post(routes.setExamInfo, controller.setExamInfo.bind(controller));

  router.get(routes.getCurrentQuest, controller.getCurrentQuest.bind(controller));

  router.post(routes.setQuestAnswers, controller.setQuestAnswers.bind(controller));

  router.get(routes.getTestResult, controller.getTestResult.bind(controller));

  configRoutes = function(app) {
    app.get('/', function(req, res) {
      return res.render('index');
    });
    app.get('/:fileName.html', function(req, res) {
      return res.render(req.params.fileName);
    });
    app.use('/api', router);
    return app.use(function(err, req, res, next) {
      res.status(err.status || 500);
      return res.render('error', {
        message: err.message,
        error: {}
      });
    });
  };

  module.exports = {
    configRoutes: configRoutes
  };

}).call(this);
