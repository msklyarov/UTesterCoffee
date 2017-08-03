React           = require 'react'
ReactDOM        = require 'react-dom'
{ Provider }    = require 'react-redux'
{ createStore } = require 'redux'
App             = require './components/App'
reducer = require './reducers'

store = createStore reducer, window.__REDUX_DEVTOOLS_EXTENSION__ &&  window.__REDUX_DEVTOOLS_EXTENSION__()

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)

