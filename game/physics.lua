local class = require 'libs/middleclass/middleclass'

local Physics = class('Physics')

Physics.static.gravity = 9.8 * 16
Physics.static.jump_height = 8 * 16

return Physics