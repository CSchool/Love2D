local class = require 'libs/middleclass/middleclass'
local anim8 = require 'libs/anim8/anim8'

local Coin = class('Coin')

Coin.static.width = 10
Coin.static.height = 14

function Coin:initialize(obj, collisionWorld)
  
  self.className = 'coin'
  self.id = obj.id
  self.pos = {x = obj.x, y = obj.y}
  self.animation = {}
  self.isTouched = false
  
  -- заносим рисунок в статическую переменную для того, чтобы можно было хранить в одном месте анимации и спрайты для всех объектов 
  if not Coin.static.sprite then
    Coin.static.sprite = love.graphics.newImage('anims/coin.png')
    Coin.static.sprite:setFilter("nearest", "nearest")
    
    Coin.static.grid = anim8.newGrid(
      Coin.static.width, Coin.static.height, 
      Coin.static.sprite:getWidth(), Coin.static.sprite:getHeight(), 
      0, 0, 1
    )
  end
  
  self.animation.flip = anim8.newAnimation(Coin.static.grid('1-3', 1), 0.6)
  
  collisionWorld:add(
    self, self.pos.x, self.pos.y, 
    Coin.static.width, Coin.static.height
  )
end

function Coin:update(dt)
  self.animation.flip:update(dt)
end

function Coin:isVisible(camera, windowWidth, scale)
  local delta = windowWidth / 2
  local camX = camera:cameraCoords(camera:position())
  local coinX = camera:cameraCoords(self.pos.x, self.pos.y)
  
  return coinX - camX < delta and (coinX - camX) > -(delta + Coin.static.width * scale)
end

return Coin