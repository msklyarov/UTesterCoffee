React       = require 'react'
{ connect } = require 'react-redux'

class InputNameForm extends React.Component
  constructor: (props) ->
    super(props)
    @state =
      firstName: ''
      lastName: ''

  handleSubmit: (event) =>
    event.preventDefault()
    @props.onAddName({
      firstName: @firstName.value
      lastName: @lastName.value
    })

  render: =>
      <div>
        <form
          className="form-horizontal col-md-4"
          onSubmit={@handleSubmit}>
          <h4>Please input your name in english.</h4>
          <div className="form-group">
            <label
              className="col-md-4 control-label"
              htmlFor="firstName">
                First Name
            </label>
            <div className="col-md-8">
              <input
                className="form-control"
                type="text"
                id="firstName"
                placeholder="First Name"
                minLength="3"
                maxLength="20"
                size="20"
                required
                ref={(input) => @firstName = input}
              />
            </div>
          </div>
          <div className="form-group">
            <label
              className="col-md-4 control-label"
              htmlFor="lastName">
                Last Name
            </label>
            <div className="col-md-8">
              <input
                className="form-control"
                type="text"
                id="lastName"
                placeholder="Last Name"
                minLength="3"
                maxLength="20"
                size="20"
                required
                ref={(input) => @lastName = input}
              />
            </div>
          </div>
          <div className="form-group">
            <div className="col-sm-offset-4 col-md-8">
              <button type="submit" className="btn btn-default">Submit</button>
            </div>
          </div>
        </form>
      </div>

module.exports = connect(
  (state) -> (
    examStore: state
  ),
  (dispatch) -> (
    onAddName: (nameStruct) ->
      dispatch({ type: 'ADD_NAME', payload: nameStruct })
  )
)(InputNameForm)
