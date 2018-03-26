
local function main(conf)
	--{{{load libs
	local getKey
	local timeTools
	if conf.isBot then
		getKey     = function(state) return conf.bot:getKey(state) end
		timeTools = require"mockTime"
	else
		getKey    = require"input"
		timeTools  = require"time"
		
	end
	local term       = require"term"
	local newAstroid = require"astroid"
	local ship       = require"ship"(0,0)
	--}}}
	--{{{declare needed vars
	local fileOut    = assert(io.open(conf.file,"w")) --the file the recording is saved to
	local objs       = {} --list of objects in the scene at any one point
	local count      = 0  --count the amount of frames that have passed
	local points     = 0  --amount of points the player has
	local isAlive    = true --keeps track if the player is alive
	--}}}

	--{{{declare needed functions
	--simple function to see if an object is in the boundries of the game
	local function checkBounds(x,y)
		if x < 1 or x > 100 then
			return false
		elseif y < 1 or y > 52 then
			return false
		end
		return true
	end
	--this renders a character and writes it down in the recording
	local function writeAt(x,y,char)
		term.cursor.jump(x,y)
		io.write(char)
		term.cursor.jump(fileOut,x,y)
		fileOut:write(char)
	end
	--takes a change in our scene and renders it if needed.
	local function renderChange(change)
		if change.change == "none" then
			return
		end
		if change.old.y > 1 then
			writeAt(change.old.y,change.old.x," ")
		end
		if change.change == "move" and change.new.y > 1 then
			writeAt(change.new.y,change.new.x,change.draw)
		end
	end
	--}}}
	--{{{update loop
	renderChange(ship:setPos(50,50)) --render the ship.
	while isAlive and not (conf.limit and conf.limit < count) do
		local start = timeTools.getTimeNS() --get the start time. Used to calculate how long we need to wait
		local k --holds the pressed key
		--give the state to our bot and ask which key it would press if its a bot
		--else just look in our terminal
		if conf.isBot then
			k = getKey({
				y = ship.posY,
				x = ship.posX,
				maxX = 100,
				maxY = 52,
				countDown = ship.shotTime,
				objects = objs
			})
		else
			k = getKey()
		end
		ship:update() --update the ship. This allows it to tick down the shoot timer
		if k then --if there is a key press, process it
			local x,y = ship.posX,ship.posY --save current values
			if k == "w" then
				y = y - 1 --its a terminal, 1= top row
			elseif k=="s" then
				y = y + 1
			elseif k=="a" then
				x = x - 1  --its a terminal, 1= most left character
			elseif k == "d" then
				x = x + 1
			elseif k == " " then
				--we update the laser (and render it) when we process the rest of out objects
				table.insert(objs,ship:shoot() or nil)
			elseif k=="]" then
				return --TODO make this a better stop
			end
			--make sure the ship can actually be in the new position
			--before updating the position and rendering it
			if checkBounds(x,y) then
				renderDelta = ship:setPos(x,y)
					if renderDelta then
					renderChange(renderDelta)
				end
			end
			
		end
		local newObjs = {} --new list of objects
		local grid    = {} --the grid gets build as we process more objects. Used to detect colisions.
		--check if a new astroid should spawn and give it a random x location
		if math.random() >=0.90 then
			local x = math.random(100)
			table.insert(newObjs,newAstroid(x,-4))
		end
		--here we update all our game objects
		for _,obj in ipairs(objs) do
			if not obj.isDead then --if an object is dead, remove it
				local delta = obj:update(count)
				if delta.change ~= "remove" then
					--the object shouldn't be removed, thus we will process it further
					table.insert(newObjs,obj)
					--place it in our grid
					grid[obj.posX] = grid[obj.posX] or {}
					grid[obj.posX][obj.posY] = grid[obj.posX][obj.posY] or {}
					table.insert(grid[obj.posX][obj.posY],obj)
					if #grid[obj.posX][obj.posY] >= 2 then
						local newObjsAtPlace = {} --after a colision, objects may be removed.
						for k,v in ipairs(grid[obj.posX][obj.posY]) do
							local colDelta = v:colide(grid[obj.posX][obj.posY])
							if colDelta.change ~= "remove" then
								table.insert(newObjsAtPlace,v)
							end
						end
						grid[obj.posX][obj.posY] = newObjsAtPlace
					end
				end
				renderChange(delta) --render the change to the scene
			else
				renderChange(obj:destroy())
			end
		end
		--now its time to see if our ship colided
		local hit = false
		if grid[ship.posX] and grid[ship.posX][ship.posY] then
			isAlive,hit = ship:colide(grid[ship.posX][ship.posY])
			for k,v in ipairs(grid[ship.posX][ship.posY]) do
				v:colide({ship})
			end
		end
		--update our object list
		objs = newObjs
		--calculate how long this update took, used to maintain 60FPS
		local sleepTime = 16666666 - timeTools.getTimeSinceNS(start)
		timeTools.sleepNS(sleepTime) --here we sleep to not go above 60FPS
		count = count + 1 --update our screen count
		fileOut:write("\n") --new line to our records indicate the end of this frame
	end
	--}}}
	--{{{clean up
	os.execute("clear") --remove junk from our terminal
	fileOut:close() --close our record file. It isn't needed any longer.
	--make sure the cursor is at the top left so we can print like normal
	term.cursor.jump(1,1)
	print(count)
	print(points)
	--nice messages to let the player know he/she won or lost
	if not isAlive then
		print("You lost :( ")
	elseif quit then
		print("Bye :( .")
	else
		print("You survived!")
	end
	--give back to our main script how well the player did
	--usefull when training bots.
	return {
		quit = quit,
		survived = isAlive,
		frameCount = count,
		points = points
	}
	--}}}
end
return main
