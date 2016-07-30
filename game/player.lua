local class = require 'libs/middleclass/middleclass'
local anim8 = require 'libs/anim8/anim8'

local Player = class('Player')
local Physics = require('physics')

Player.static.turnDurationLimit = 10
Player.static.size = 16

-- инициализация объекта Player
function Player:initialize(name, sprite, world)
  self.name = name
  
  -- инициализация анимаций
  self.animations = {}
  
  -- выделяем новое изображение в памяти
  self.animations.sprite = love.graphics.newImage(sprite)
  
  --[[
    Создаем таблицу фреймов, в которой будут хранится анимации
    Параметры 1, 2 - ширина и высота фрейма с изображением анимации
    Параметры 3, 4 - ширина и высота изображения, где хранится таблица фреймов
    Параметры 5, 6 - отступ по оси Х и Y
    Параметр 7 - заданием ширины границы между фреймами
  --]]
  
  self.animations.grid = anim8.newGrid(
    Player.static.size, Player.static.size, 
    self.animations.sprite:getWidth(), self.animations.sprite:getHeight(), 
    0, 0, 1
  )
  
  self.animations.jumping = anim8.newAnimation(self.animations.grid(6, 1), 0.1)
  
  -- копируем фрейм и отзеркаливаем его по оси Х, тем самым заставляем художников меньше рисовать
  self.animations.stayingRight = anim8.newAnimation(self.animations.grid(1, 1), 0.1)
  self.animations.stayingLeft = self.animations.stayingRight:clone():flipH() 
  
  self.animations.turnRight = anim8.newAnimation(self.animations.grid(5, 1), Player.static.turnDurationLimit)
  self.animations.turnLeft = self.animations.turnRight:clone():flipH() 
   
  
  self.animations.runningRight = anim8.newAnimation(self.animations.grid(2, 1, 3, 1, 4, 1), 0.15)
  self.animations.runningLeft = self.animations.runningRight:clone():flipH()
  
  self.currentAnimation = 'stayingRight'
  self.turnDuration = 0
    
  self.pos = {
    x = 0, 
    y = 0, 
    direction = "right",
    yVelocity = 0,
  }
  
  
  self.world = world
end

-- указываем, где находится игрок в начале игры
function Player:setStartPosition(objects)
  -- пробегаемся по всем объектам на уровне
  for k, object in pairs(objects) do
    if object.name == "playerSpawn" then
      self.pos = {x = object.x, y = object.y, direction = "right", yVelocity = 0}
      
      -- добавляем игрока в мир (маленький марио - 16х16)
      self.world:add(self, self.pos.x, self.pos.y, Player.static.size, Player.static.size)
      
      break
    end
  end 
end

-- обновление игрока
function Player:update(dt)
  local speed = 90
  
  local dx,dy = 0,0
  
  -- изначальная анимация
  self.currentAnimation = 'stayingRight'
  
  -- проверяем падаем ли мы?
  if self.pos.yVelocity ~= 0 then
    --print(self.pos.yVelocity)
    self.pos.y = self.pos.y - self.pos.yVelocity * dt
  end
  
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
      if self.pos.direction == "right" then
        -- задаем анимацию поворота
        self.pos.direction = "left"
      else
        -- задаем анимацию бега
        self.currentAnimation = 'runningLeft'
      end
  end

  -- Двигаем персонажа вправо
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
      dx = speed * dt
      
      if self.pos.direction == "left" then
        -- задаем анимацию поворота
        self.pos.direction = "right"
      else
        -- задаем анимацию бега
        self.currentAnimation = 'runningRight'
        self.turnDuration = 0
      end
  end
  
  -- todo: поправить анимацию прыжка и направление
  if love.keyboard.isDown("space") and self.pos.yVelocity == 0 then
    self.currentAnimation = 'jumping'
    self.pos.yVelocity = self.pos.yVelocity + Physics.static.jump_height
  end
  
  if self.currentAnimation == 'stayingRight' and self.pos.direction == 'left' then
    self.currentAnimation = 'stayingLeft'
  end
  
  -- пытаемся подвинуть игрока
  local collisions = {}
  local x, y = self.pos.x, self.pos.y
  
  self.pos.x, self.pos.y, collisions = self.world:move(self, x + dx, y + dy)
  
  -- если нет столкновения с землей - тянет игрока вниз 
  -- (todo: все же проверять стоим ли мы на земле, и только потом применять гравитацию)
  -- (todo: и убрать хождения по стенам :))
  if #collisions == 0 then
    self.pos.yVelocity = self.pos.yVelocity - Physics.static.gravity * dt
  end
  
  -- обрабатываем столкновения с предметами
  for i,v in pairs(collisions) do
    --print(v.type, v.otherRect.x, v.otherRect.y, v.otherRect.w, v.otherRect.h)
    
    if v.item == self and v.normal.y == -1 then
      self.pos.y = v.otherRect.y - 16
      self.pos.yVelocity = 0
    end
    
  end
    
  -- рисуем анимацию
  self.animations[self.currentAnimation]:update(dt)
  
end


return Player