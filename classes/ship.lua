local baseObj  = require"gameObject"
local newLaser = require"laser"
return function(x,y)
	local obj = baseObj("^","shipt")
	local ship = obj:extend()
	ship.lives = 3
	ship.shotTime = 0
	ship:setPos(x,y)
	function ship:colide(objs)
		for k,v in ipairs(objs) do
			if v ~= self then
				if v.getType()=="astroid" then
					self.lives = self.lives - 1
					return self.lives > 0, true
				end
			end
		end
		return true,false
	end
	function ship:update()
		if self.shotTime > 0 then
			self.shotTime = self.shotTime - 1
		end
	end
	function ship:shoot()
		if self.shotTime <= 0 then
			self.shotTime = 20
			return newLaser(ship.posX,ship.posY-1)
		end
	end
	return ship
end
