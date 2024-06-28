--[[ Ball class:
     - init
     - reset
     - collides
     - bounceOff
     - update
     - render ]]--

Ball = Class{}

function Ball:init()
  self.height = 4
  self.width = 4
  self.dx = 0
  self.dy = 0
  self.x = 0
  self.y = 0
end

function Ball:reset(maxWidth, maxHeight, winningPlayer)
  self.x = maxWidth / 2 - 2
  self.y = maxHeight / 2 - 2
  self.dx = winningPlayer == 1 and math.random(140, 200) or -math.random(140, 200)
  self.dy = math.random(-50, 50)
end

function Ball:collides(paddle)
  if
    self.x > paddle.x + paddle.width or
    self.x + self.width < paddle.x
  then
    return false
  end

  if
    self.y > paddle.y + paddle.height or
    self.y + self.height < paddle.y
  then
    return false
  end

  return true
end

function Ball:bounceOff(paddle)
  local horizontalOverlay = paddle.x + 0.5 * paddle.width - (self.x + 0.5 * self.width)

  self.x = self.x - horizontalOverlay
  self.dx = -self.dx

  gSounds['paddleHit']:play()
end

function Ball:update(dt)
  self.x = self.x + dt * self.dx
  self.y = self.y + dt * self.dy
end

function Ball:render()
  love.graphics.rectangle(
    'fill',
    self.x,
    self.y,
    self.width,
    self.height
  )
end

--[[ Paddle class:
     - init
     - update
     - render ]]--

Paddle = Class{}

function Paddle:init(x, y)
  self.height = 20
  self.width = 5
  self.dy = 0
  self.x = x
  self.y = y
end

function Paddle:update(dt, maxHeight)
  self.y = math.min(
    math.max(
      self.y + dt * self.dy,
      0
    ),
    maxHeight - self.height
  )
end

function Paddle:render()
  love.graphics.rectangle(
    'fill',
    self.x,
    self.y,
    self.width,
    self.height
  )
end