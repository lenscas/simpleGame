local moveAble = require"basicMoveAble"
return function(x,y)
		local conf  = {
			startX      = x,
			startY      = y - 1,
			type        = "laser",
			char        = "|",
			updateTime  = 3,
			incY        = -1,
			checkBounds = function(x,y) return y > 1 end,
			colide      = function(self,laser,col) return laser:destroy() end
		}
	local laser = moveAble(conf):extend()
	return laser
end
