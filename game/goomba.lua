local class = require 'libs/middleclass/middleclass'
local anim8 = require 'libs/anim8/anim8'

local Goomba = class('Goomba')

Goomba.static.width = 16
Goomba.static.height = 16
Goomba.static.velocity = 15

-- ходячий гриб - самый простой враг
function Goomba:initialize(obj, collisionWorld)
  self.className = 'goomba'
  self.id = obj.id
  self.pos = {x = obj.x, y = obj.y, direction = obj.properties.direction}
  self.animations = {}
  self.isTouched = false
  
  if not Goomba.static.sprite then
    Goomba.static.sprite = love.graphics.newImage('anims/goomba.png')
    Goomba.static.sprite:setFilter("nearest", "nearest")
    
    Goomba.static.grid = anim8.newGrid(
      Goomba.static.width, Goomba.static.height, 
      Goomba.static.sprite:getWidth(), Goomba.static.sprite:getHeight(), 
      0, 0, 1
    )
  end
  
  self.animations.walkRight = anim8.newAnimation(Goomba.static.grid('1-2', 1), 0.5)
  self.animations.walkLeft = self.animations.walkRight:clone():flipH()
  
  self.collisionWorld = collisionWorld
  
  self.collisionWorld:add(
    self, self.pos.x, self.pos.y, 
    Goomba.static.width, Goomba.static.height
  )
  
end

function Goomba:update(dt)
    local dx =  self.pos.direction == 'right' and 
                dt * Goomba.static.velocity or 
                -dt * Goomba.static.velocity
                
    local dy = 0
                
    -- пытаемся подвинуть игрока
    local collisions = {}
    local x, y = self.pos.x, self.pos.y
  
    -- передвигаем 
    self.pos.x, self.pos.y, collisions = self.collisionWorld:move(self, x + dx, y + dy)
    
    -- обрабатываем
    if #collisions > 0 then
        if self.pos.direction == 'right' then
            self.pos.direction = 'left'
        else
            self.pos.direction = 'right'
        end
    end
    
    -- обновляем анимацию
    self.animations[self:getCurrentAnimation()]:update(dt)
end

function Goomba:getCurrentAnimation()
    return "walk" .. self.pos.direction:gsub("^%l", string.upper)
end

return Goomba