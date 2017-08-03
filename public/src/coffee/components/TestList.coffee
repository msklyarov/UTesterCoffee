React = require 'react'
{ connect } = require 'react-redux'
{ getTestList } = require '../actions/requests'

class TestList extends React.Component
  constructor: (props) ->
    super(props)

  handleClick: (event) =>
    event.preventDefault()
    @props.onSelectTestName(event.target.id)

  render: =>
    <ul>
      {@props.examStore.examData.testList.map((item, index) =>
        <li key={index}>
          <a
            href={item}
            id={item}
            onClick={@handleClick}
          >
            {item.replace(/_/g, ' ')}
          </a>
        </li>
      )}
    </ul>

  componentDidMount: () =>
    @props.onTestListLoad()

module.exports = connect(
  (state) -> (
    examStore: state
  ),
  (dispatch) -> (
    onTestListLoad: ->
      getTestList(dispatch)
    onSelectTestName: (testName) ->
      dispatch({type: 'ADD_TEST_NAME', payload: testName})
  )
)(TestList)
