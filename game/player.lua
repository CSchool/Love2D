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
  
  -- копируем фрейм и отзеркаливаем его по оси Х, тем самым заставляем художников меньше рисовать
  self.animations.jumpingRight = anim8.newAnimation(self.animations.grid(6, 1), 0.1)
  self.animations.jumpingLeft = self.animations.jumpingRight:clone():flipH()
  
  
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
  
  self.jumping = {
    isJumping = false, -- флажок на анимацию прыжка
    direction = 'Right' -- в каком направлении прыгаем
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
  
  -- проверка клавиатуры
  -- Двигаем персонажа вверх
  if (love.keyboard.isDown("w") or love.keyboard.isDown("up") or love.keyboard.isDown("space")) and not self.jumping.isJumping then
    self.pos.yVelocity = self.pos.yVelocity + Physics.static.jump_height
    self.jumping.isJumping = true
    self.jumping.direction = self.pos.direction:gsub("^%l", string.upper) -- делаем заглавную первую букву
  end


  -- Двигаем персонажа вниз
  if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
    -- необходимо для большого Марио
  end

  -- Двигаем персонажа влево
  if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
      dx = -speed * dt
      if self.pos.direction == "right" then
        -- задаем направление поворота, если не находимся в прыжке
        if not self.jumping.isJumping then 
          self.pos.direction = "left"
        end
      else
        -- задаем анимацию бега
        self.currentAnimation = 'runningLeft'
      end
  end

  -- Двигаем персонажа вправо
  if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
      dx = speed * dt
      
      if self.pos.direction == "left" then
        -- задаем направление поворота, если не находимся в прыжке
        if not self.jumping.isJumping then
          self.pos.direction = "right"
        end
      else
        -- задаем анимацию бега
        self.currentAnimation = 'runningRight'
        self.turnDuration = 0
      end
  end
  
  -- специальные проверки на анимации игрока - направление в стоячем состоянии + прыжок 
  if self.currentAnimation == 'stayingRight' and self.pos.direction == 'left' then
    self.currentAnimation = 'stayingLeft'
  end
  
  if self.jumping.isJumping then
    self.currentAnimation = 'jumping' .. self.jumping.direction
  end
  
  -- пытаемся подвинуть игрока
  local collisions = {}
  local x, y = self.pos.x, self.pos.y
  
  -- передвигаем 
  self.pos.x, self.pos.y, collisions = self.world:move(self, x + dx, y + dy)
  

  
  local isFloor = false -- есть ли коллизии с полом
  
  -- обрабатываем столкновения с предметами
  for i,v in pairs(collisions) do
    --print(v.type, v.otherRect.x, v.otherRect.y, v.otherRect.w, v.otherRect.h)
    
    -- если пол, мы его касаемся нормально, и у нас есть вертикально ускорение, то стоит прекратить падение
    if v.item == self and v.normal.y == -1 and self.pos.yVelocity ~= 0 then
      self.pos.y = v.otherRect.y - 16
      self.pos.yVelocity = 0
      isFloor = true
    end
    
  end
  
  -- если нет столкновения с землей - тянем игрока вниз, иначе говорим, что прыжка нет
  -- (todo: убрать хождения по стенам :))
  if not isFloor then
    self.pos.yVelocity = self.pos.yVelocity - Physics.static.gravity * dt
  elseif isFloor and self.jumping.isJumping == true then
    self.jumping.isJumping = false
  end
    
  -- рисуем анимацию
  self.animations[self.currentAnimation]:update(dt)
  
end


return Player