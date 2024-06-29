Class = require 'class'
push = require 'push'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
PADDLE_SPEED_FOR_AI = 100

AI_DECISION_TIMER = 0

game = {
  -- serve (waiting on a key press to start the game)
  -- play (the ball is in play)
  -- done (the game is over, with a victor)
  ['state'] = 'serve',
  ['score1'] = 0,
  ['score2'] = 0,
  ['winningPlayer'] = 0
}

event = {
  ['action'] = function ()
    if game.state == 'serve' then
      ball:reset(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, game.winningPlayer)
      game.state = 'play'
    elseif game.state == 'done' then
      ball:reset(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, game.winningPlayer)
      game.score1 = 0
      game.score2 = 0
      game.winningPlayer = 0
      game.state = 'serve'
    end
  end,
  ['exit'] = function ()
    if game.state == 'serve' or game.state == 'done' then
      love.event.quit()
    end
  end,
}

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle('Pong')

  -- declare fonts
  -- assuming that line-height is 1.5, thus, the height for various fonts will be:
  -- - small: 12
  -- - large: 24
  -- - score: 48
  smallFont = love.graphics.newFont('font.ttf', 8)
  largeFont = love.graphics.newFont('font.ttf', 16)
  scoreFont = love.graphics.newFont('font.ttf', 32)

  -- initialize elements
  ball = Ball()
  paddle1 = Paddle(5, (VIRTUAL_HEIGHT - 20) / 2)
  paddle2 = Paddle(VIRTUAL_WIDTH - 10, (VIRTUAL_HEIGHT - 20) / 2)
  ball:reset(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, game.winningPlayer)

  -- initialize virtual resolution
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true,
    canvas = false
  })

  gSounds = {
    ['paddleHit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wallHit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
  }
end

function love.keypressed(key)
  if key == 'escape' then
    event.exit()
  elseif key == 'enter' or key == 'return' then
    event.action()
  end
end

function love.update(dt)
  -- while in play, update elements position
  if game.state == 'play' then
    -- update ai timer
    AI_DECISION_TIMER = AI_DECISION_TIMER + dt
    -- update elements position
    ball:update(dt)
    paddle1:update(dt, VIRTUAL_HEIGHT)
    paddle2:update(dt, VIRTUAL_HEIGHT)

    -- check ball and paddle collision
    if ball:collides(paddle1) then
      ball:bounceOff(paddle1)
    elseif ball:collides(paddle2) then
      ball:bounceOff(paddle2)
    end

    -- check ball and edges collision
    if ball.y < 0 or ball.y > VIRTUAL_HEIGHT - ball.height then
      ball.dy = -ball.dy
      gSounds['wallHit']:play()
    elseif ball.x < 0 then
      game.score2 = game.score2 + 1
      game.winningPlayer = 2
      if game.score2 == 2 then
        game.state = 'done'
      else
        game.state = 'serve'
      end

      gSounds['score']:play()
    elseif ball.x > VIRTUAL_WIDTH - ball.width then
      game.score1 = game.score1 + 1
      game.winningPlayer = 1
      if game.score1 == 2 then
        game.state = 'done'
      else
        game.state = 'serve'
      end

      gSounds['score']:play()
    end

    -- handle player1 input
    if
      love.keyboard.isDown('up') or
      love.keyboard.isDown('w')
    then
      paddle1.dy = -PADDLE_SPEED
    elseif
      love.keyboard.isDown('down') or
      love.keyboard.isDown('s')
    then
      paddle1.dy = PADDLE_SPEED
    else
      paddle1.dy = 0
    end

    -- add ai logic
    if
      ball.dx > 0 and
      ball.x > 0.4 * VIRTUAL_WIDTH and
      AI_DECISION_TIMER > 0.3
    then
      if ball.y + ball.height < paddle2.y then
        paddle2.dy = -PADDLE_SPEED_FOR_AI
      elseif ball.y > paddle2.y + paddle2.height then
        paddle2.dy = PADDLE_SPEED_FOR_AI
      else
        paddle2.dy = 0
      end

      if AI_DECISION_TIMER > 0.5 then
        AI_DECISION_TIMER = 0
      end
    end
  end
end

function love.draw()
  push:start()

  -- display scores
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(game.score1), 0.5 * VIRTUAL_WIDTH - 61, 0.3 * VIRTUAL_HEIGHT)
  love.graphics.print(tostring(game.score2), 0.5 * VIRTUAL_WIDTH + 43, 0.3 * VIRTUAL_HEIGHT)

  if game.state == 'serve' then
    love.graphics.setFont(smallFont)
    love.graphics.print('Press ENTER to start', 0.5 * VIRTUAL_WIDTH - 44, 0.6 * VIRTUAL_HEIGHT)
  elseif game.state == 'play' then
  elseif game.state == 'done' then
    love.graphics.setFont(smallFont)
    love.graphics.print(
      'Player '..(game.winningPlayer == 1 and 'ONE' or 'TWO')..' wins!',
      0.5 * VIRTUAL_WIDTH - 34,
      0.6 * VIRTUAL_HEIGHT - 12
    )
    love.graphics.print('Press ENTER to restart', 0.5 * VIRTUAL_WIDTH - 50, 0.6 * VIRTUAL_HEIGHT)
  end

  -- display elements
  ball:render()
  paddle1:render()
  paddle2:render()

  push:finish()
end

function love.resize(width, height)
  push:resize(width, height)
end