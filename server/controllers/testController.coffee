fs = require('fs')
path = require('path')
_ = require('lodash')
config = require('../../config')

class testController
  constructor: (@isCachingEnabled = true) ->
    # caches
    @_jsonDbCollections = {}
    @_jsonResultCollections = {}

  getTestList: (req, res) =>
    console.log('getTestList')
    res.json(@_getTestList())

  getTotalQuestsNum: (req, res) =>
    console.log('getQuestionsNumber')
    res.json({ length: @_getJsonDb(req.params.testName).length })

  setExamInfo: (req, res) =>
    console.log('setExamInfo')

    @_setExamInfo(req.params.testName, req.params.firstName, \
      req.params.lastName, req.params.questsToAskNum)

    res.sendStatus(200)

  getCurrentQuest: (req, res) =>
    console.log('getCurrentQuest')

    json = @_getCurrentQuest(req.params.testName, \
      req.params.firstName, req.params.lastName)

    console.log('answer: ', JSON.stringify(json.questData.answers, null, 2))

    if json != null
      res.json(@_removeIsCorrectFlags(json))
    else
      # non-existing question
      res.sendStatus(400)

  setQuestAnswers: (req, res) =>
    console.log('setQuestAnswers')

    jsonInDb = @_getCurrentQuest(req.params.testName,
      req.params.firstName, req.params.lastName)

    jsonInDb.questData.answers = _.merge(jsonInDb.questData.answers, req.body.answers)

    jsonResult = @_getJsonResult(req.params.testName, \
      req.params.firstName, req.params.lastName)

    if jsonResult.currentQuestNum < jsonResult.questsToAskNum
      jsonResult.currentQuestNum++
      jsonResult.askedQuests.push(jsonInDb)

      if jsonResult.currentQuestNum == jsonResult.questsToAskNum
        jsonResult.examStopDateTime = new Date().toString()

      @_writeExamData(req.params.testName,
        req.params.firstName, req.params.lastName, jsonResult)

      res.sendStatus(200)
    else
      # out of range
      res.sendStatus(400);

  _checkQuest: (element) ->
    (element.isCorrect && element.userAnswer) ||
    ((!element.hasOwnProperty('isCorrect') || !element.isCorrect) &&
      (!element.hasOwnProperty('userAnswer') || !element.userAnswer))

  _processAllQuests: (element) => +element.questData.answers.every(@_checkQuest)

  _calculateSum: (sum, value) -> sum + value

  getTestResult: (req, res) =>
    jsonResult = @_getJsonResult(req.params.testName,
      req.params.firstName, req.params.lastName)

    result = jsonResult.askedQuests
      .map(@_processAllQuests.bind(this))
      .reduce(@_calculateSum, 0);

    dateDiff = (Date.parse(jsonResult.examStopDateTime) -
      Date.parse(jsonResult.examStartDateTime)) / 1000;

    console.log("#{Math.floor((dateDiff / (60 * 60)) % 24)}:#{Math.floor((dateDiff / 60) % 60)}:#{Math.floor(dateDiff % 60)}")

    res.json({
      questsCount: jsonResult.questsToAskNum,
      answeredCorrect: result,
      totalTime: "#{Math.floor((dateDiff / (60 * 60)) % 24)}:#{Math.floor((dateDiff / 60) % 60)}:#{Math.floor(dateDiff % 60)}",
    })

  _getJsonDb: (testName) =>
    if @_isCachingEnabled
      collection = this._jsonDbCollections[testName]
      return collection if collection

    questionsFullName = path.format({
      dir: config.dbFolder,
      name: testName,
      ext: '.json',
    })

    collection = {}
    if fs.existsSync(questionsFullName)
      collection = JSON.parse(fs.readFileSync(questionsFullName))

    @_jsonDbCollections[testName] = collection if @_isCachingEnabled

    return collection

  _createTestFolderIfNotExists: (testName) ->
    testFolderName = path.format({
      dir: config.resultsFolder,
      name: testName,
    })

    fs.mkdirSync(testFolderName) if !fs.existsSync(testFolderName)

  _getJsonResult: (testName, firstName, lastName) =>
    collectionKey = "#{testName}_#{firstName}_#{lastName}"

    if @_isCachingEnabled
      collection = @_jsonResultCollections[collectionKey]
      return collection if collection

    @._createTestFolderIfNotExists(testName)

    testResultsFullName = path.format({
      dir: path.join(config.resultsFolder, testName),
      name: "#{firstName}_#{lastName}",
      ext: '.json',
    })

    collection = {}
    if fs.existsSync(testResultsFullName)
      collection = JSON.parse(fs.readFileSync(testResultsFullName))

    @_jsonResultCollections[collectionKey] = collection if @_isCachingEnabled

    return collection

  _getTestList: () ->
    files = fs.readdirSync(config.dbFolder)
    out = []

    out.push(path.parse(item).name) for item in files

    return out

  _setExamInfo: (testName, firstName, lastName, questsToAskNum) ->
    jsonDb = this._getJsonDb(testName)

    # calculate questions sequence here
    i = 0
    questions = []

    loop
      break if i >= questsToAskNum

      num = Math.round(Math.random() * jsonDb.length)

      if !questions.includes(num)
        questions.push(num)
        i++

    console.log(questions)

    data = {
      questsToAskNum: parseInt(questsToAskNum),
      fromTotalQuestsNum: jsonDb.length,
      questsSequence: questions.sort((a, b) => a - b),
      examStartDateTime: new Date().toString(),
      currentQuestNum: 0,
      askedQuests: [],
    }

    @_writeExamData(testName, firstName, lastName, data)

  _writeExamData: (testName, firstName, lastName, data) =>
    testResultsFullName = path.format(
      dir: path.join(config.resultsFolder, testName),
      name: "#{firstName}_#{lastName}",
      ext: '.json',
    )

    @_createTestFolderIfNotExists(testName)

    fs.writeFileSync(testResultsFullName, JSON.stringify(data, null, 2))

  _getCurrentQuest: (testName, firstName, lastName) =>
    jsonDb = @_getJsonDb(testName)

    resultJson = @_getJsonResult(testName, \
      firstName, lastName)

    if resultJson.currentQuestNum < resultJson.questsSequence.length and \
    resultJson.questsSequence[resultJson.currentQuestNum] < jsonDb.length
      return {
        questNum: resultJson.currentQuestNum,
        questData: jsonDb[resultJson.questsSequence[resultJson.currentQuestNum]],
      }

    return null


  _removeIsCorrectFlags: (inJson) ->
    outJson = _.cloneDeep(inJson)
    delete item.isCorrect if item.hasOwnProperty('isCorrect') \
      for item in outJson.questData.answers

    return outJson

module.exports = testController
