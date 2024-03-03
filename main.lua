Class = require 'class'
push = require 'push'
require 'elements'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

game = {
  -- serve (waiting on a key press to start the game)
  -- play (the ball is in play)
  -- done (the game is over, with a victor)
  state = 'serve',
  score1 = 0,
  score2 = 0,
  winningPlayer = 0
}

event = {}
function event.action()
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
end
function event.exit()
  if game.state == 'serve' or game.state == 'done' then
    love.event.quit()
  end
end
function event.moveUp(player) end
function event.moveDown(player) end

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
end

function love.keypressed(key)
  if key == 'escape' then
    event.exit()
  elseif key == 'enter' or key == 'return' then
    event.action()
  elseif key == 'w' then
    event.moveUp(1)
  elseif key == 's' then
    event.moveDown(2)
  elseif key == 'up' or key == 'p' then
    event.moveUp(1)
  elseif key == 'down' or key == ';' then
    event.moveDown(2)
  end
end

function love.update(dt)
  -- while in play, update elements position
  if game.state == 'play' then
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
    elseif ball.x < 0 then
      game.score2 = game.score2 + 1
      game.winningPlayer = 2
      if game.score2 == 2 then
        game.state = 'done'
      else
        game.state = 'serve'
      end
    elseif ball.x > VIRTUAL_WIDTH - ball.width then
      game.score1 = game.score1 + 1
      game.winningPlayer = 1
      if game.score1 == 2 then
        game.state = 'done'
      else
        game.state = 'serve'
      end
    end

    -- handle player1 input
    if love.keyboard.isDown('w') then
      paddle1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
      paddle1.dy = PADDLE_SPEED
    else
      paddle1.dy = 0
    end
    -- handle player2 input
    if love.keyboard.isDown('up') or love.keyboard.isDown('p') then
      paddle2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') or love.keyboard.isDown(';') then
      paddle2.dy = PADDLE_SPEED
    else
      paddle2.dy = 0
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