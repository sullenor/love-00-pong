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