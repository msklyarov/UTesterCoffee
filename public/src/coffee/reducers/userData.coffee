module.exports = userData = (state = {
  windowType: 'InputNameForm'
  questsToAskNum: 20
}, action) ->
  switch action.type
    when 'ADD_NAME'
      return Object.assign({}, state, {
        firstName: action.payload.firstName
        lastName: action.payload.lastName
        windowType: 'TestList'
      })

    when 'ADD_TEST_NAME'
      return Object.assign({}, state, {
        testName: action.payload
        windowType: 'InputQuestionsNum'
      })

    when 'ADD_QUESTS_NUM_TO_ASK'
      return Object.assign({}, state, {
        questsToAskNum: action.payload
        windowType: 'ReadyToStartTest'
      })

    when 'ASK_CURRENT_QUEST'
      return Object.assign({}, state, {
        windowType: 'AskCurrentQuest'
      })

    when 'SHOW_TEST_RESULT'
      return Object.assign({}, state, {
        windowType: 'TestResult'
      })

    else return state
