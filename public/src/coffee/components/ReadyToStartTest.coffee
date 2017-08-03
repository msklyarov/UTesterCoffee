React       = require 'react'
{ connect } = require 'react-redux'
{ setExamInfo } = require '../actions/requests'

class ReadyToStartTest extends React.Component
  constructor: (props) ->
    super(props)

  handleSubmit: (event) =>
    event.preventDefault()
    this.props.onStartTest(@props.examStore.userData.testName, \
      @props.examStore.userData.firstName, \
      @props.examStore.userData.lastName, \
      @props.examStore.userData.questsToAskNum)

    @props.onAskCurrentQuest()

  render: =>
    <form
      className="form-horizontal col-md-4"
      onSubmit={@handleSubmit}>
      <div className="form-group">
        <div className="col-sm-offset-1 col-md-4">
          <button type="submit" className="btn btn-default">Start test</button>
        </div>
      </div>
    </form>

module.exports = connect(
  (state) -> (
    examStore: state
  ),
  (dispatch) -> (
    onStartTest: (testName, firstName, lastName, questionsToAskNum) ->
      setExamInfo(dispatch, testName, firstName, lastName, questionsToAskNum)
    onAskCurrentQuest: ->
      dispatch({ type: 'ASK_CURRENT_QUEST' })
  )
)(ReadyToStartTest)
