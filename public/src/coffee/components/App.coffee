#React   = require 'react'
#{ connect } = require 'react-redux'
#InputNameForm   = require './InputNameForm'
#
#class App extends React.Component
#  render : ->
#      <div>
#        <InputNameForm />
#      </div>
#
#module.exports = connect(
#  (state) -> (
#    examStore: state
#  )
#)(App)

React         = require 'react'
{ connect }   = require 'react-redux'
Header        = require './Header'
Footer        = require './Footer'
InputNameForm = require './InputNameForm'
TestList      = require './TestList'
InputQuestsNum = require './InputQuestsNum'
ReadyToStartTest = require './ReadyToStartTest'
AskCurrentQuest = require './AskCurrentQuest'
TestResult = require './TestResult'

class App extends React.Component
  render :->
    #  let currentWindow;
    console.log(this.props);
    switch @props.examStore.userData.windowType
      when 'TestList' then currentWindow = <TestList />
      when 'InputQuestionsNum' then currentWindow = <InputQuestsNum />
      when 'ReadyToStartTest' then currentWindow = <ReadyToStartTest />
      when 'AskCurrentQuest' then currentWindow = <AskCurrentQuest />
      when 'TestResult' then currentWindow = <TestResult />
      else currentWindow = <InputNameForm />

     <div>
        <div className="col-md-12">
          <Header />
        </div>
        {currentWindow}
        <div className="col-md-12">
          <Footer  />
        </div>
    </div>

#export default connect(
#  state => ({
#    examStore: state,
#  }),
#    dispatch => ({}),
#)(App);

module.exports = connect(
  (state) -> (
    examStore: state
  )
)(App)
