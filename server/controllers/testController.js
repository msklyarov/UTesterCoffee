(function() {
  var _, config, fs, path, testController,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  path = require('path');

  _ = require('lodash');

  config = require('../../config');

  testController = (function() {
    function testController(isCachingEnabled) {
      this.isCachingEnabled = isCachingEnabled != null ? isCachingEnabled : true;
      this._getCurrentQuest = bind(this._getCurrentQuest, this);
      this._writeExamData = bind(this._writeExamData, this);
      this._getJsonResult = bind(this._getJsonResult, this);
      this._getJsonDb = bind(this._getJsonDb, this);
      this.getTestResult = bind(this.getTestResult, this);
      this._processAllQuests = bind(this._processAllQuests, this);
      this.setQuestAnswers = bind(this.setQuestAnswers, this);
      this.getCurrentQuest = bind(this.getCurrentQuest, this);
      this.setExamInfo = bind(this.setExamInfo, this);
      this.getTotalQuestsNum = bind(this.getTotalQuestsNum, this);
      this.getTestList = bind(this.getTestList, this);
      this._jsonDbCollections = {};
      this._jsonResultCollections = {};
    }

    testController.prototype.getTestList = function(req, res) {
      console.log('getTestList');
      return res.json(this._getTestList());
    };

    testController.prototype.getTotalQuestsNum = function(req, res) {
      console.log('getQuestionsNumber');
      return res.json({
        length: this._getJsonDb(req.params.testName).length
      });
    };

    testController.prototype.setExamInfo = function(req, res) {
      console.log('setExamInfo');
      this._setExamInfo(req.params.testName, req.params.firstName, req.params.lastName, req.params.questsToAskNum);
      return res.sendStatus(200);
    };

    testController.prototype.getCurrentQuest = function(req, res) {
      var json;
      console.log('getCurrentQuest');
      json = this._getCurrentQuest(req.params.testName, req.params.firstName, req.params.lastName);
      console.log('answer: ', JSON.stringify(json.questData.answers, null, 2));
      if (json !== null) {
        return res.json(this._removeIsCorrectFlags(json));
      } else {
        return res.sendStatus(400);
      }
    };

    testController.prototype.setQuestAnswers = function(req, res) {
      var jsonInDb, jsonResult;
      console.log('setQuestAnswers');
      jsonInDb = this._getCurrentQuest(req.params.testName, req.params.firstName, req.params.lastName);
      jsonInDb.questData.answers = _.merge(jsonInDb.questData.answers, req.body.answers);
      jsonResult = this._getJsonResult(req.params.testName, req.params.firstName, req.params.lastName);
      if (jsonResult.currentQuestNum < jsonResult.questsToAskNum) {
        jsonResult.currentQuestNum++;
        jsonResult.askedQuests.push(jsonInDb);
        if (jsonResult.currentQuestNum === jsonResult.questsToAskNum) {
          jsonResult.examStopDateTime = new Date().toString();
        }
        this._writeExamData(req.params.testName, req.params.firstName, req.params.lastName, jsonResult);
        return res.sendStatus(200);
      } else {
        return res.sendStatus(400);
      }
    };

    testController.prototype._checkQuest = function(element) {
      return (element.isCorrect && element.userAnswer) || ((!element.hasOwnProperty('isCorrect') || !element.isCorrect) && (!element.hasOwnProperty('userAnswer') || !element.userAnswer));
    };

    testController.prototype._processAllQuests = function(element) {
      return +element.questData.answers.every(this._checkQuest);
    };

    testController.prototype._calculateSum = function(sum, value) {
      return sum + value;
    };

    testController.prototype.getTestResult = function(req, res) {
      var dateDiff, jsonResult, result;
      jsonResult = this._getJsonResult(req.params.testName, req.params.firstName, req.params.lastName);
      result = jsonResult.askedQuests.map(this._processAllQuests.bind(this)).reduce(this._calculateSum, 0);
      dateDiff = (Date.parse(jsonResult.examStopDateTime) - Date.parse(jsonResult.examStartDateTime)) / 1000;
      console.log((Math.floor((dateDiff / (60 * 60)) % 24)) + ":" + (Math.floor((dateDiff / 60) % 60)) + ":" + (Math.floor(dateDiff % 60)));
      return res.json({
        questsCount: jsonResult.questsToAskNum,
        answeredCorrect: result,
        totalTime: (Math.floor((dateDiff / (60 * 60)) % 24)) + ":" + (Math.floor((dateDiff / 60) % 60)) + ":" + (Math.floor(dateDiff % 60))
      });
    };

    testController.prototype._getJsonDb = function(testName) {
      var collection, questionsFullName;
      if (this._isCachingEnabled) {
        collection = this._jsonDbCollections[testName];
        if (collection) {
          return collection;
        }
      }
      questionsFullName = path.format({
        dir: config.dbFolder,
        name: testName,
        ext: '.json'
      });
      collection = {};
      if (fs.existsSync(questionsFullName)) {
        collection = JSON.parse(fs.readFileSync(questionsFullName));
      }
      if (this._isCachingEnabled) {
        this._jsonDbCollections[testName] = collection;
      }
      return collection;
    };

    testController.prototype._createTestFolderIfNotExists = function(testName) {
      var testFolderName;
      testFolderName = path.format({
        dir: config.resultsFolder,
        name: testName
      });
      if (!fs.existsSync(testFolderName)) {
        return fs.mkdirSync(testFolderName);
      }
    };

    testController.prototype._getJsonResult = function(testName, firstName, lastName) {
      var collection, collectionKey, testResultsFullName;
      collectionKey = testName + "_" + firstName + "_" + lastName;
      if (this._isCachingEnabled) {
        collection = this._jsonResultCollections[collectionKey];
        if (collection) {
          return collection;
        }
      }
      this._createTestFolderIfNotExists(testName);
      testResultsFullName = path.format({
        dir: path.join(config.resultsFolder, testName),
        name: firstName + "_" + lastName,
        ext: '.json'
      });
      collection = {};
      if (fs.existsSync(testResultsFullName)) {
        collection = JSON.parse(fs.readFileSync(testResultsFullName));
      }
      if (this._isCachingEnabled) {
        this._jsonResultCollections[collectionKey] = collection;
      }
      return collection;
    };

    testController.prototype._getTestList = function() {
      var files, item, j, len, out;
      files = fs.readdirSync(config.dbFolder);
      out = [];
      for (j = 0, len = files.length; j < len; j++) {
        item = files[j];
        out.push(path.parse(item).name);
      }
      return out;
    };

    testController.prototype._setExamInfo = function(testName, firstName, lastName, questsToAskNum) {
      var data, i, jsonDb, num, questions;
      jsonDb = this._getJsonDb(testName);
      i = 0;
      questions = [];
      while (true) {
        if (i >= questsToAskNum) {
          break;
        }
        num = Math.round(Math.random() * jsonDb.length);
        if (!questions.includes(num)) {
          questions.push(num);
          i++;
        }
      }
      console.log(questions);
      data = {
        questsToAskNum: parseInt(questsToAskNum),
        fromTotalQuestsNum: jsonDb.length,
        questsSequence: questions.sort((function(_this) {
          return function(a, b) {
            return a - b;
          };
        })(this)),
        examStartDateTime: new Date().toString(),
        currentQuestNum: 0,
        askedQuests: []
      };
      return this._writeExamData(testName, firstName, lastName, data);
    };

    testController.prototype._writeExamData = function(testName, firstName, lastName, data) {
      var testResultsFullName;
      testResultsFullName = path.format({
        dir: path.join(config.resultsFolder, testName),
        name: firstName + "_" + lastName,
        ext: '.json'
      });
      this._createTestFolderIfNotExists(testName);
      return fs.writeFileSync(testResultsFullName, JSON.stringify(data, null, 2));
    };

    testController.prototype._getCurrentQuest = function(testName, firstName, lastName) {
      var jsonDb, resultJson;
      jsonDb = this._getJsonDb(testName);
      resultJson = this._getJsonResult(testName, firstName, lastName);
      if (resultJson.currentQuestNum < resultJson.questsSequence.length && resultJson.questsSequence[resultJson.currentQuestNum] < jsonDb.length) {
        return {
          questNum: resultJson.currentQuestNum,
          questData: jsonDb[resultJson.questsSequence[resultJson.currentQuestNum]]
        };
      }
      return null;
    };

    testController.prototype._removeIsCorrectFlags = function(inJson) {
      var item, outJson;
      outJson = _.cloneDeep(inJson);
      if ((function() {
        var j, len, ref, results;
        ref = outJson.questData.answers;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          item = ref[j];
          results.push(item.hasOwnProperty('isCorrect'));
        }
        return results;
      })()) {
        delete item.isCorrect;
      }
      return outJson;
    };

    return testController;

  })();

  module.exports = testController;

}).call(this);
