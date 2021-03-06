# app/lib/router.coffee

Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'

# filters

Router._filters =
  ganalytics: (pause) -> GAnalytics.pageview()

filters = Router._filters

# client

if Meteor.isClient

  # before hooks

  Router.onBeforeAction 'loading'
  Router.onBeforeAction 'dataNotFound', only: 'game'

  # after hooks

  Router.onAfterAction filters.ganalytics, except: 'game'

  # routes

  Router.map ->
    # lobby
    @route 'lobby',
      path: '/'

      waitOn: -> Meteor.subscribe 'quizOfTheDay'

    # highscore
    @route 'highscores',
      waitOn: ->
        [
          Meteor.subscribe 'quizzes'
        , Meteor.subscribe 'highscores'
        ]

    # quizzes # TODO: testing
    @route 'quizzes',
      waitOn: -> Meteor.subscribe 'allQuizzes'

    # game
    @route 'game',
      path: '/game/:_id/:action'

      waitOn: ->
        [
          Meteor.subscribe 'currentGame', @params._id
        , Meteor.subscribe 'currentQuiz', @params._id
        , Meteor.subscribe 'currentQuizQuestions', @params._id
        , Meteor.subscribe 'currentQuizSounds', @params._id
        , Meteor.subscribe 'currentQuizHighscores', @params._id
        ]

      data: -> Games.findOne @params._id

      onRun: ->
        id = @params._id
        Deps.nonreactive ->
          Session.set 'currentQuestionId', 0
          Session.set 'currentGameId', id

      onBeforeAction: (pause) ->
        unless @params.action in [ 'play', 'result' ]
          @render 'notFound'
          pause()

      action: ->
        @render @params.action

      onAfterAction: (pause) ->
        if @params.action is 'result'
          GAnalytics.pageview()
