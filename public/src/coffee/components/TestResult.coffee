React = require 'react'
{ connect } = require 'react-redux'
{ getTestResult } = require '../actions/requests'

class TestResult extends React.Component
  constructor: (props) ->
    super(props)
    @maxMark = 5
    @props.onPageLoad(this.props.examStore.userData.testName, \
      @props.examStore.userData.firstName, \
      @props.examStore.userData.lastName)

  render: =>
    <div>
      <h2>Result</h2>
      <div>Asked questions count: {@props.examStore.examData.testResult.questsCount}</div>
      <div>Correct answered questions count: {@props.examStore.examData.testResult.answeredCorrect}</div>
      <div>Score {(@props.examStore.examData.testResult.answeredCorrect * @maxMark /
        @props.examStore.examData.testResult.questsCount).toFixed(2)} from {@maxMark}</div>
    </div>

module.exports = connect(
  (state) -> (
    examStore: state
  ),
  (dispatch) -> (
    onPageLoad: (testName, firstName, lastName) ->
      getTestResult(dispatch, testName, firstName, lastName)
  )
)(TestResult)