-- объявления зависимостей
local Player = require "player"

local bump = require "libs/bump/bump"
local sti = require "libs/sti"


local mario = {}

-- инициализация приложения начинается в данной процедуре 
function love.load()
  -- данная строчка необходима для отладки игры в среде ZeroBrane!
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- получаем размер окна
  windowWidth  = love.graphics.getWidth()
  windowHeight = love.graphics.getHeight()
  
  -- создание физического мира
  world = bump.newWorld(16)
    
  -- загрузка карт (с плагином bump - для определения коллизий)
  map = sti("map/l01.lua", { "bump" })
  
  map:bump_init(world)
  
  -- инициализация игрока на уровне
  mario = Player:new('mario', 'sprites/mario.png', world) -- вызывается функция initialize
  mario:setStartPosition(map.objects)
  
  -- добавляем слой для отрисовки
  map:addCustomLayer('spriteLayer', 3);
  
  local spriteLayer = map.layers.spriteLayer;
  
  spriteLayer.sprites = {
    player = mario
  }
  
  function spriteLayer:update(dt)
    self.sprites.player:update(dt)
  end

  function spriteLayer:draw()
    love.graphics.draw(mario.image.sprite, mario.pos.x, mario.pos.y, 0, 1, 1, mario.image.offset_x, mario.image.offset_y)
    love.graphics.print('(' .. mario.pos.x .. ', ' .. mario.pos.y .. ')', 20, 20)
  end
end

-- отрисовка состояния игры на текущий момент времени
function love.draw()
  map:draw() -- отрисовка мира
  --map:bump_draw(world) -- отрисовка границ объектов
end

-- обновление игры - dt - сколько времени прошло после предыдущего обновления (очень маленькое значение)
function love.update(dt)
  map:update(dt)
end
