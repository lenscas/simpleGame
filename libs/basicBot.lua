--a simple and basic bot to play the game.

local bot = {}
--this gets the closest astroid that can hit the ship
function bot:getClosest(objs,atX,atY)
	local closest
	for _,obj in ipairs(objs) do
		if obj:getType()=="astroid" then
			if obj.posX == atX and obj.posY <= atY then
				if not closest then
					closest = obj
				else
					if obj.posY>closest.posY then
						closest = obj
					end
				end
			end
		end
	end
	return closest
end
--decides what key to press.
--like the filename says, its basic.
function bot:makeDesision(gameState)
	if gameState.distance == -1 then
		return nil
	elseif gameState.distance > 0 and gameState.fireTime <= 0 then
		return " "
	else
		if gameState.distanceLeft > 0 then
			return "a"
		else
			return "d"
		end
	end
end
--this gets called whenever the bot needs to "press" a key.
--it changes the state into something the bot can understand
--and lets it make a desision.
function bot:getKey(state)
	local botState         = {}
	botState.y             = state.y
	local closest          = self:getClosest(state.objects,state.x,state.y)
	botState.distance      = (closest and botState.y - closest.posY) or -1
	botState.fireTime      = state.countDown
	botState.distanceLeft  = state.x - 1
	botState.distanceRight = state.maxX - state.x
	botState.distanceTop   = state.y
	botState.distanceBotom = state.maxY - state.y
	return self:makeDesision(botState)
end
return bot
