React       = require 'react'
{ connect } = require 'react-redux'
{ getCurrentQuest, setQuestAnswers } = require '../actions/requests'

class AskCurrentQuest extends React.Component
  constructor: (props) ->
    super(props)

    @props.onCurrentQuestLoad(@props.examStore.userData.testName, \
      @props.examStore.userData.firstName, \
      @props.examStore.userData.lastName)

  handleSubmit: (event) =>
    event.preventDefault()
    @disableSubmitButton()

    jsonData = @props.examStore.examData.currentQuest.questData

    for item, index in jsonData.answers
      delete item.userAnswer
      item.userAnswer = true if document.getElementsByName('question')[index].checked

    @props.onQuestAnswersSubmit(@props.examStore.userData.testName, \
      @props.examStore.userData.firstName, \
      @props.examStore.userData.lastName, \
      jsonData)

    if @props.examStore.examData.currentQuest.questNum < @props.examStore.userData.questsToAskNum - 1
      @props.onCurrentQuestLoad(@props.examStore.userData.testName, \
        @props.examStore.userData.firstName, \
        @props.examStore.userData.lastName);
    else
      @props.onTestFinished()

  enableSubmitButton: ->
    document.getElementsByClassName('submit-quest-answer')[0]
      .removeAttribute('disabled')

  disableSubmitButton: ->
    document.getElementsByClassName('submit-quest-answer')[0]
      .setAttribute('disabled', 'disabled')

  render: =>
    <form
      className="form-horizontal col-md-6"
      onSubmit={@handleSubmit}>
      <h3>Test name: {@props.examStore.userData.testName.replace(/_/g, ' ')}</h3>
      <h4>Quiestion {@props.examStore.examData.currentQuest.questNum + 1} from {@props.examStore.userData.questsToAskNum}</h4>
      <p>{@props.examStore.examData.currentQuest.questData.questionText}</p>
        {@props.examStore.examData.currentQuest.questData.answers.map((item, index) =>
          <div
            key={item.text}
            className={if @props.examStore.examData.currentQuest.questData.areMultyAnswers then "checkbox" else "radio"}>
            <label>
              <input
                type={if @props.examStore.examData.currentQuest.questData.areMultyAnswers then "checkbox" else "radio"}
                name="question"
                value={item.text}
                onChange={@enableSubmitButton}
              />
              {item.text}
            </label>
          </div>
        )}
      <br />
      <div className="form-group">
        <div className="col-md-6">
          <button
            className="btn btn-default submit-quest-answer"
            type="submit">
              Submit
          </button>
        </div>
      </div>
    </form>

  componentWillMount: =>
    if @props.examStore.examData.currentQuest.questNum < @props.examStore.userData.questsToAskNum
      @props.onCurrentQuestLoad(@props.examStore.userData.testName, \
        @props.examStore.userData.firstName,
        @props.examStore.userData.lastName)
    else
      @props.onTestFinished()

module.exports = connect(
  (state) -> (
    examStore: state
  ),
  (dispatch) -> (
    onCurrentQuestLoad: (testName, firstName, lastName) ->
      getCurrentQuest(dispatch, testName, firstName, lastName)
    onQuestAnswersSubmit: (testName, firstName, lastName, jsonData) ->
      setQuestAnswers(dispatch, testName, firstName, lastName, jsonData)
    onTestFinished: ->
      dispatch({type: 'SHOW_TEST_RESULT'})
  )
)(AskCurrentQuest)
