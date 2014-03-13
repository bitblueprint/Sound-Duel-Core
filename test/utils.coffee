# test/utils.coffee

load_new_game = (driver, name) ->
  driver.get "http://localhost:3000"
  driver.findElement(id: 'name').sendKeys name
  driver.findElement(id: 'new-game').click()
  # Selenium bug workaround
  # http://code.google.com/p/selenium/issues/detail?id=2766
  driver.wait( ->
    driver.findElement(id: 'popup-confirm')
  , 1000)
  driver.executeScript "window.scrollTo(0, \
    document.getElementById('popup-confirm').getBoundingClientRect().top);"
  driver.findElement(id: 'popup-confirm').click()

answer_question = (driver, all) ->
  driver.findElements(css: '.alternative')
    .then (elements) ->
      driver.wait( ->
        elements[0].getAttribute('disabled')
          .then (disabled) ->
            unless disabled
              elements[0].click()
              true
      , 2000)
        .then ->
          if all
            driver.wait( ->
              driver.findElement(tagName: 'h3')
                .getText()
                .then (text) ->
                  unless text.match /Resultater/
                    answer_question driver, true
              true
            , 1000)

module.exports.load_new_game   = load_new_game
module.exports.answer_question = answer_question