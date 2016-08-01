local class = require 'libs/middleclass/middleclass'

local World = class('World')

World.static.gravity = 9.8 * 16
World.static.jump_height = 8 * 16

World.static.leftBorder = {x = 0, y = 0}

return World