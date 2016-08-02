-- объявления зависимостей
local Player = require "player"

local bump = require "libs/bump/bump"
local sti = require "libs/sti"

local Camera = require "libs/camera/camera"
local World = require 'world'

local font
local mario = {}

-- ссылки на функции
local ceil = math.ceil

--[[ original resolution:
 256 × 224
 --]]

-- инициализация приложения начинается в данной процедуре 
function love.load()
  -- данная строчка необходима для отладки игры в среде ZeroBrane!
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  io.stdout:setvbuf("no") -- для вывода print сразу же в output
  
  -- получаем размер окна
  windowWidth, windowHeight = love.graphics.getDimensions()
  local yCoef = windowHeight / 208
  
  print(windowWidth, windowHeight)
  
  
  -- создание физического мира
  world = bump.newWorld(16)
    
  -- загрузка карт (с плагином bump - для определения коллизий)
  map = sti("map/l01_t.lua", { "bump" })
  
  map:bump_init(world)
  
  -- инициализация игрока на уровне
  mario = Player:new('mario', 'sprites/mario_low_anim.png', world) -- вызывается функция initialize
  mario:setStartPosition(map.objects)
  
  
  -- создаем камеру
  camera = Camera()
  camera.smoother = Camera.smooth.damped(10)
  
  camera:zoom(yCoef)
  
  local borderX, borderY = camera:worldCoords(-16 * yCoef, 0)
  camera:move(-borderX, -borderY)
  
  local camPosX, camPosY = camera:position()
  World.static.leftBorder = {x = camPosX, y = camPosY}
  
  -- test information
  print(camPosX, camPosY)
  print(camera:cameraCoords(mario.pos.x, mario.pos.y))
  print(camera:worldCoords(mario.pos.x, mario.pos.y))
  
  -- загружаем шрифт
  local fontSize = windowWidth == 800 and 14 or 16 -- тернарый оператор в действии
  font = love.graphics.newFont("fonts/emulogic.ttf", fontSize)
  love.graphics.setFont(font)
  
  -- добавляем слой для отрисовки
  map:addCustomLayer('spriteLayer', 2);
  
  local spriteLayer = map.layers.spriteLayer;
  
  spriteLayer.sprites = {
    player = mario
  }
  
  
  function spriteLayer:update(dt)
    self.sprites.player:update(dt)
  end

  function spriteLayer:draw()
    -- отрисовка текущей анимации
    mario.animations[mario.currentAnimation]:draw(mario.animations.sprite, mario.pos.x, mario.pos.y)
    
    love.graphics.setPointSize(5)
    love.graphics.points(camera:position())
    
  end
end

-- отрисовка состояния игры на текущий момент времени
function love.draw()
  camera:attach()
  local x, y = camera:position()
  map:setDrawRange(x, y, windowWidth, windowHeight)
  map:draw() -- отрисовка мира
  camera:detach() 
  
  -- отрисовка интерфейса
  local yOffset = windowHeight * 0.05
  local startOffset = windowWidth * 0.05
  
  -- вывод интерфейса на экран
  local scoreString = string.format("%06d", mario.hud.score)
  local scoreStringWidth = font:getWidth(scoreString)
  
  local scoreLabel = "Score"
  local scoreLabelWidth = font:getWidth(scoreLabel)
  
  local scoreDiff = (scoreStringWidth - scoreLabelWidth) / 2
  
  -- выводим на экран счет
  love.graphics.print(scoreLabel, startOffset + scoreDiff, yOffset)
  love.graphics.print(string.format("%06d", mario.hud.score), startOffset, yOffset * 2)
  
  -- выводим количество монеток
  love.graphics.print('x ' .. mario.hud.coins, startOffset * 7, yOffset * 2)
  
  local worldLabel = 'World'
  local worldLabelWidth = font:getWidth(worldLabel)
  
  local marioWorld = mario.hud.level
  local marioWorldWidth = font:getWidth(marioWorld)
  
  local worldDiff = (worldLabelWidth - marioWorldWidth) / 2
  
  -- выводим текущий мир (уровень)
  love.graphics.print('World', startOffset * 12, yOffset)
  love.graphics.print(marioWorld, startOffset * 12 + worldDiff, yOffset * 2)
  
  local timeLabel = 'Time'
  local marioTime = ceil(mario.hud.time)
  local diff = (font:getWidth(timeLabel) - font:getWidth(marioTime)) / 2
  
  -- выводим текущее время
  love.graphics.print('Time', startOffset * 17, yOffset)
  love.graphics.print(ceil(marioTime), startOffset * 17 + diff, yOffset * 2)
  
  --map:bump_draw(world) -- отрисовка границ объектов
end

-- обновление игры - dt - сколько времени прошло после предыдущего обновления (очень маленькое значение)
function love.update(dt)
  map:update(dt)
  
  camera:lockX(mario.pos.x)
  
  local x,y = camera:position()
  
  if (x < World.static.leftBorder.x) then
    camera:lookAt(World.static.leftBorder.x, World.static.leftBorder.y)
  end
end
