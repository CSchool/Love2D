-- объявления зависимостей
local Player = require "player"
local sti = require "libs/sti"


local mario = {}

-- инициализация приложения начинается в данной процедуре 
function love.load()
  -- данная строчка необходима для отладки игры в среде ZeroBrane!
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- получаем размер окна
  windowWidth  = love.graphics.getWidth()
  windowHeight = love.graphics.getHeight()
  
  -- загрузка карт (с движком физики box2d)
  map = sti("map/l01.lua", { "box2d" })
  
  -- инициализация физического мира с гравитацией (горизонтальной и вертикальной)
  world = love.physics.newWorld(0, 0)
  
  -- Устанавливаем коллизии
  map:box2d_init(world)
  
  -- инициализация игрока на уровне
  mario = Player:new('mario', 'sprites/player') -- вызывается функция initialize
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
    love.graphics.setPointSize(5)
    love.graphics.points(math.floor(mario.pos.x), math.floor(mario.pos.y))
  end
end

-- отрисовка состояния игры на текущий момент времени
function love.draw()
  map:draw()
  
  -- тест
  
end

-- обновление игры - dt - сколько времени прошло после предыдущего обновления (очень маленькое значение)
function love.update(dt)
  map:update(dt)
end
