-- проверка пересечения двух прямоугольников
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return 
        x1 < x2+w2 and x2 < x1+w1 and
        y1 < y2+h2 and y2 < y1+h1
end

function love.load()
     -- данная строчка необходима для отладки игры в среде ZeroBrane!
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    io.stdout:setvbuf("no") -- для вывода print сразу же в output
    
    math.randomseed(os.time()) -- задание новой последовательности рандомных чисел

    -- получаем ширину и высоту игрового окна
    screenWidth = love.graphics.getWidth()
    screenHeigth = love.graphics.getHeight()
    
    world = {
        shootInterval = 0.5, -- cooldown стрельбы/перезарядка - т.е. игрок может стрелять 1 раз в 0.5 секунд
        enemySpawnInterval = 1.5, -- cooldown появления врагов - т.е. новый враг появляется 1 раз в 1.5 секунд
        canEnemySpawn = true, -- переменная-флажок возможности появления нового врага
        enemySpawnTimer = 3 -- переменная-таймер для создания врагов
    }
    
    player = {
        x = love.graphics.getWidth() / 2, -- координаты по оси Х
        y = love.graphics.getHeight() / 2, -- координаты по оси Y
        height = 50, -- высота игрока
        width = 20, -- ширина игрока
        speedX = 150, -- скорость по оси Х
        speedY = 150, -- скорость по оси Y
        bullets = {}, -- пульки игрока
        canShoot = true, -- флаг, разрещающий стрелять
        shootTimer = world.shootInterval, -- таймер-cooldown (сколько времени нельзя стрелять)
        score = 0,-- очки
        isAlive = true -- жив ли игрок?
    }
    
    -- характеристики пули
    bulletStat = {
        height = 10,
        width = 5,
        speedY = 50 -- как быстро летит пуля
    }
    
    -- враги
    enemies = {}
    
end

function love.update(dt)
    
    -- при любом раскладе игры (идет игра или игрок мертв) необходимо выйти из игры при нажатии escape
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end
    
    -- если игрок живой, то обновляем состояние игры
    if player.isAlive then
    
        -- создание врага или обновление таймера
        if world.canEnemySpawn then
            -- создаем врага (делаем рандомные параметры)
            local enemyWidth = math.random(5, 50)
            local enemyHeight = math.random(5, 15)
            
            local enemy = {
                width = enemyWidth,
                height = enemyHeight,
                x = math.random(1, screenWidth - enemyWidth), -- уменьшаем границу справа, для того, чтобы корректно появлялись враги
                y = -enemyHeight, -- для того, чтобы враг появлялся из-за экрана
                speedY = math.random(5, 100),
                -- задаем цвет противника
                color = {
                    math.random(0, 255), 
                    math.random(0, 255), 
                    math.random(0, 255)
                }
            }
            
            table.insert(enemies, enemy) -- записываем врага в таблицу врагов
            
            -- больше врагов нельзя создавать, до тех пор enemySpawnTimer не станет <= 0
            world.canEnemySpawn = false
            world.enemySpawnTimer = world.enemySpawnInterval
        else
            world.enemySpawnTimer = world.enemySpawnTimer - dt
            -- отсчитываем таймер до появления нового врага
            if world.enemySpawnTimer <= 0 then
                world.canEnemySpawn = true -- можем создавать нового врага
            end
        end
        
        --передвижение врагов
        for i,enemy in pairs(enemies) do
            enemy.y = enemy.y + enemy.speedY * dt
            
            -- если враг вышел за экран, то удаляем его из игры
            if enemy.y > screenHeigth - enemy.height then
                table.remove(enemies, i)
            end
        end
        
        --передвижение пуль
        for i,bullet in pairs(player.bullets) do
            bullet.y = bullet.y - dt * bulletStat.speedY
            
            -- если пуля вышла из игры, то удаяем ее
            if bullet.y < 0 then
                table.remove(player.bullets, i)
            end
        end
        
        -- игрок
        -- стрельба (если нельзя стрелять, то уменьшаем таймер до тех пор, пока он не станет <= 0, в этом случае изменяем флажок)
        if not player.canShoot then
            player.shootTimer = player.shootTimer - dt
            
            if player.shootTimer <= 0 then
                player.canShoot = true
            end
        end
        
        -- управление
        
        if love.keyboard.isDown('a', 'left') then
            player.x = player.x - dt * player.speedX
        end
        
        if love.keyboard.isDown('d', 'right') then
            player.x = player.x + dt * player.speedX
        end
        
        if love.keyboard.isDown('w', 'up') then
            player.y = player.y - dt * player.speedY
        end
        
        if love.keyboard.isDown('s', 'down') then
            player.y = player.y + dt * player.speedY
        end
            
        -- границы мира  (за них нельзя вылезать, поэтому ограничиваем игрока)
        if player.x < 0  then
            player.x = 0
        elseif player.x > screenWidth - player.width then
            player.x = screenWidth - player.width
        end
        
        if player.y < 0 then
            player.y = 0
        elseif player.y > screenHeigth - player.height then
            player.y = screenHeigth - player.height
        end
        
        -- стрельба (стреляем, если есть возможность)
        if love.keyboard.isDown('space') and player.canShoot then
            local bullet = {
                x = player.x + player.width / 2,
                y = player.y
            }
            
            -- создали пулю и запретили стрелять
            table.insert(player.bullets, bullet)
            player.canShoot = false
            player.shootTimer = world.shootInterval
            
        end
        
        -- проверка пересечений пуль, врагов и игрока
        for i,enemy in pairs(enemies) do
            for j,bullet in pairs(player.bullets) do
                if checkCollision(
                    enemy.x, enemy.y, enemy.width, enemy.height,
                    bullet.x, bullet.y, bulletStat.width, bulletStat.height
                ) then
                    table.remove(enemies, i)
                    table.remove(player.bullets, j)
                    player.score = player.score + 1 -- увеличиваем счет игрока
                end
            end
            
            if checkCollision(
                enemy.x, enemy.y, enemy.width, enemy.height,
                player.x, player.y, player.width, player.height
            ) then
                table.remove(enemies, i)
                player.isAlive = false
            end
        end
    
    else
        --[[
            что-нибудь, например, отслеживать нажатие клавиши R, обнулить все таблицы с врагами и пулями, и оживить игрока :)
        --]] 
    end
end

function love.draw()
    if player.isAlive then
        -- рисуем игрока
        love.graphics.setColor(230, 230, 0) -- ставим новый цвет
        love.graphics.rectangle('fill', player.x, player.y, player.width, player.height)
        love.graphics.setColor(255, 255, 255) -- возвращаем старый

        -- рисуем пули
        for i,bullet in pairs(player.bullets) do
            love.graphics.rectangle('fill', bullet.x, bullet.y, bulletStat.width, bulletStat.height)
        end
        
        -- рисуем врагов
        for i,enemy in pairs(enemies) do
            love.graphics.setColor(enemy.color[1], enemy.color[2], enemy.color[3])
            love.graphics.rectangle('fill', enemy.x, enemy.y, enemy.width, enemy.height)
        end
        
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("SCORE: " .. tostring(player.score), screenWidth * 0.05, screenHeigth * 0.95)
    else
        love.graphics.print("Game over", screenWidth / 2, screenHeigth / 2)
    end
end