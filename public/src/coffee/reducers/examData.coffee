module.exports = examData = (state = {
  testList: []
  questsTotalNum: 60
  currentQuest:
    questNum: 0
    questData:
      questionText: ''
      answers: []
  testResult:
    questsCount: 0
    answeredCorrect: 0
}, action) ->
  switch action.type
    when 'GET_TEST_LIST'
      return Object.assign({}, state, { testList: action.payload })

    when 'GET_TOTAL_QUESTS_NUM'
      return Object.assign({}, state, { questsTotalNum: action.payload })

    when 'SET_EXAM_INFO', 'SET_QUEST_ANSWERS'
      return state

    when 'GET_CURRENT_QUEST'
      return Object.assign({}, state, { currentQuest: action.payload })

    when 'GET_TEST_RESULT'
      return Object.assign({}, state, { testResult: action.payload })

    else return state