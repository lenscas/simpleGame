--this creates a simple gameObject
--it is the basis of all game objects
return function(char,type)
	char = char or "#"
	local obj = {
		posX = 0,
		posY = 0,
		char = char,
		isDead = false
	}
	function obj:getType() return type end
	--this sets the position of the game object and returns a "renderChange"
	--renderChanges are used to update the screen.
	function obj:setPos(x,y)
		if  (not (x or y)) or (x==self.posX and y==self.posY) then
			return {
				change = "none"
			}
		end
		local renderChange = {
			change = "move",
			old = {
				x = self.posX,
				y = self.posY
			},
			new = {
				x = x or self.posX,
				y = y or self.posY
			},
			draw = self.char
		}
		self.posX = x or self.posX
		self.posY = y or self.posY
		return renderChange
	end
	--this function should always be changed by other gameobjects
	function obj:update()
		error("not implemented!")
	end
	--when called, mark the object as dead and return the correct renderChange
	function obj:destroy()
		local delta = {
			change = "remove",
			old = {
				x = self.posX,
				y = self.posY
			},
		}
		self.isDead = true
		return delta
	end
	--simple function that handles extending this.
	function obj:extend(obj)
		local newObj = setmetatable( obj or {},{__index=self})
		return newObj
	end
	return obj
end
