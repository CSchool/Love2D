-- объявления зависимостей
local Player = require "player"

local bump = require "libs/bump/bump"
local sti = require "libs/sti"

local Camera = require "libs/camera/camera"

local mario = {}

--[[ original resolution:
 256 × 224
 --]]

-- инициализация приложения начинается в данной процедуре 
function love.load()
  -- данная строчка необходима для отладки игры в среде ZeroBrane!
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  io.stdout:setvbuf("no") -- для вывода print сразу же в output
  
  -- получаем размер окна
  windowWidth  = love.graphics.getWidth()
  windowHeight = love.graphics.getHeight()
  
  -- создание физического мира
  world = bump.newWorld(16)
    
  -- загрузка карт (с плагином bump - для определения коллизий)
  map = sti("map/l01.lua", { "bump" })
  
  map:bump_init(world)
  
  -- инициализация игрока на уровне
  mario = Player:new('mario', 'sprites/mario_low_anim.png', world) -- вызывается функция initialize
  mario:setStartPosition(map.objects)
  
  -- создаем камеру
  camera = Camera(mario.pos.x + 7 * Player.static.size, mario.pos.y - 4 * Player.static.size, love.graphics.getWidth() / 256)
  camera.smoother = Camera.smooth.damped(10)
  
  
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
    
    love.graphics.print('(' .. mario.pos.x .. ', ' .. mario.pos.y .. ')', 20, 20)
  end
end

-- отрисовка состояния игры на текущий момент времени
function love.draw()
  camera:attach()
  map:draw() -- отрисовка мира
  camera:detach() 
  --map:bump_draw(world) -- отрисовка границ объектов
end

-- обновление игры - dt - сколько времени прошло после предыдущего обновления (очень маленькое значение)
function love.update(dt)
  map:update(dt)
  
  camera:lockX(mario.pos.x + 7 * Player.static.size)
end
