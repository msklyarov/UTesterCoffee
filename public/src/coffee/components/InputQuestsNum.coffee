React       = require 'react'
{ connect } = require 'react-redux'
{ getTotalQuestsNum } = require '../actions/requests'

class InputQuestionsNum extends React.Component
  constructor: (props) ->
    super(props)
    @state =
      questsToAskNum: @props.examStore.userData.questsToAskNum

  handleQuestionsNumInput: (event) =>
    @setState({ questsToAskNum: event.target.value })

  handleSubmit: (event) =>
    event.preventDefault()
    @props.onInputQuestsNumToAsk(@state.questsToAskNum)

  render: =>
      <form
        className="form-horizontal col-md-6"
        onSubmit={@handleSubmit}>
        <div className="form-group">
          <label
            className="col-md-6 control-label"
            htmlFor="questionsToAsk">
            Please select number of questions to ask
          </label>
          <div className="col-md-3">
            <input
              className="form-control"
              type="number"
              id="questionsToAskNum"
              value={this.state.questsToAskNum}
              onChange={this.handleQuestionsNumInput}
              size={this.props.examStore.examData.questsTotalNum.toString().length}
              min="1"
              max={this.props.examStore.examData.questsTotalNum}
              required
            />
          </div>
          <div className="col-md-3">
            <label>
              from {@props.examStore.examData.questsTotalNum}
            </label>
          </div>
        </div>
        <div className="form-group">
          <div className="col-md-6">
            <button type="submit" className="btn btn-default">Submit</button>
          </div>
        </div>
      </form>

  componentWillMount: =>
    @props.onTotalQuestsNumLoad(@props.examStore.userData.testName)

module.exports = connect(
  (state) -> (
    examStore: state,
  ),
  (dispatch) -> (
    onTotalQuestsNumLoad: (testName) ->
      getTotalQuestsNum(dispatch, testName)
    onInputQuestsNumToAsk: (num) ->
      dispatch({ type: 'ADD_QUESTS_NUM_TO_ASK', payload: num })
  )
)(InputQuestionsNum)
