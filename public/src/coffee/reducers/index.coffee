{ combineReducers } = require 'redux'
examData = require './examData'
userData = require './userData'

module.exports = combineReducers({
  examData
  userData
})
