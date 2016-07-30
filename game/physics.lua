local class = require 'libs/middleclass/middleclass'

local Physics = class('Physics')

Physics.static.gravity = 9 * 16
Physics.static.jump_height = 100

return Physics