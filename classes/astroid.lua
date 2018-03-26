local baseObj = require"basicMoveAble"
return function(x,y)
	local conf = {
		startX      = x,
		startY      = y,
		type        = "astroid",
		char        = "+",
		updateTime  = 4,
		incY        = 1,
		checkBounds = function(x,y) return y < 52 end,
		colide      = function(self,astr,col) return astr:destroy() end
	}
	local astroid = baseObj(conf):extend()
	return astroid
end
