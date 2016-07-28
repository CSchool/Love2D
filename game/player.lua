local class = require 'libs/middleclass/middleclass'
local Player = class('Player')

-- инициализация объекта Player
function Player:initialize(name, sprite, world)
  self.name = name
  self.image = {
    sprite = love.graphics.newImage(sprite),
    offset_x = 0,
    offset_y = 0
  }
  self.pos = {x = 0, y = 0}
  self.world = world
end

-- указываем, где находится игрок в начале игры
function Player:setStartPosition(objects)
  -- пробегаемся по всем объектам на уровне
  for k, object in pairs(objects) do
    if object.name == "playerSpawn" then
      self.pos = {x = object.x, y = object.y}
      
      -- add player to world
      self.world:add(self, self.pos.x, self.pos.y, self.image.sprite:getWidth(), self.image.sprite:getHeight())
      break
    end
  end 
end

-- обновление игрока
function Player:update(dt)
  local speed = 32
  
  local dx,dy = 0,0
  
  -- Двигаем персонажа вверх
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
      dy = -speed * dt
  end

  -- Двигаем персонажа вниз
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
      dy = speed * dt
  end

  -- Двигаем персонажа влево
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
      dx = -speed * dt
  end

  -- Двигаем персонажа вправо
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
      dx = speed * dt
  end
  
  -- пытаемся подвинуть игрока
  local collisions = {}
  self.pos.x, self.pos.y, collisions = self.world:move(self, self.pos.x + dx, self.pos.y + dy)
  
  -- обрабатываем столкновения с предметами
  for i,v in pairs(collisions) do
    print(v.other)
  end
  
end

return Player