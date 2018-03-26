--this builds on our gameObject to more easily create something that moves every so often and colides with other objects.
local baseObj = require"gameObject"
return function(conf)
	local moveAble = baseObj(conf.char,conf.type):extend()
	moveAble.updateCount = 0
	function moveAble:update ()
		if self.isDead then return self:destroy() end
		if self.updateCount > 0 then
			self.updateCount = self.updateCount - 1
		else
			local x = self.posX + (conf.incX or 0)
			local y = self.posY + (conf.incY or 0)
			if conf.checkBounds(x,y) then
				return self:setPos(x,y)
			else
				return self:destroy()
			end
			self.updateCount = conf.updateTime or 0
		end
	end
	function moveAble:colide(colision)
		for _,obj in ipairs(colision) do
			if obj~=self then
				local change = conf:colide(self,obj)
				if change.change == "remove" then
					return change
				end
			end
		end
	end
	moveAble:setPos(conf.startX,conf.startY)
	return moveAble
end
