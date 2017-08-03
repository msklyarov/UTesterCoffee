express   = require 'express'
router   = express.Router()
config    = require 'config'
Controller = require('./controllers/testController');

routes =
  getTestList: '/tests/getAll', # GET
  getTotalQuestsNum: '/:testName/getQuestsNum', # GET
  setExamInfo: '/setExamInfo/:testName/:firstName/:lastName/:questsToAskNum', # POST
  getCurrentQuest: '/getCurrQuest/:testName/:firstName/:lastName', # GET
  setQuestAnswers: '/setQuestAnswers/:testName/:firstName/:lastName', # POST
  getTestResult: '/getTestResult/:testName/:firstName/:lastName' # GET

controller = new Controller()
router.get(routes.getTestList, controller.getTestList.bind(controller))
router.get(routes.getTotalQuestsNum, controller.getTotalQuestsNum.bind(controller))
router.post(routes.setExamInfo, controller.setExamInfo.bind(controller))
router.get(routes.getCurrentQuest, controller.getCurrentQuest.bind(controller))
router.post(routes.setQuestAnswers, controller.setQuestAnswers.bind(controller))
router.get(routes.getTestResult, controller.getTestResult.bind(controller))

configRoutes = (app) ->
  app.get '/', (req, res) ->
    res.render('index')

  app.get '/:fileName.html', (req, res) ->
    res.render(req.params.fileName)

  app.use('/api', router)

  # catch 404 and forward to error handler
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render 'error',
      message : err.message
      error : {}

module.exports = {configRoutes : configRoutes}
