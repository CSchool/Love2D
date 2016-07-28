local class = require 'libs/middleclass/middleclass'

local Player = class('Player')

-- инициализация объекта Player
function Player:initialize(name, sprite)
  self.name = name
  self.sprite = sprite
  self.pos = {x = 0, y = 0}
end

-- указываем, где находится игрок в начале игры
function Player:setStartPosition(objects)
  -- пробегаемся по всем объектам на уровне
  for k, object in pairs(objects) do
    if object.name == "playerSpawn" then
      self.pos = {x = object.x, y = object.y}
      break
    end
  end 
end

-- обновление игрока
function Player:update(dt)
  local speed = 16
  
  -- Двигаем персонажа вверх
  if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
      self.pos.y = self.pos.y - speed * dt
  end

  -- Двигаем персонажа вниз
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
      self.pos.y = self.pos.y + speed * dt
  end

  -- Двигаем персонажа влево
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
      self.pos.x = self.pos.x - speed * dt
  end

  -- Двигаем персонажа вправо
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
      self.pos.x = self.pos.x + speed * dt
  end
end

return Player