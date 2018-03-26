local timeTools  = require"time"

local function main(args)
	--get our file
	file = args["file"] or "./records/out.txt"
	file = assert(io.open(file,"r"))
	--we want all the text as I have plenty of RAM and lazy.
	--this will probably byte me in the but later, oh well
	local wholeText = file:read("*all") 
	file:close() --at least we can close the file quickly
	--\n characters are our frame bounderies. Split on them and loop over it
	for line in string.gmatch(wholeText, '([^\n]+)') do
		local start = timeTools.getTimeNS() --get current time
		io.write(line) --print our line to the output. WITHOUT NEW LINES!
		--and nicely wait to maintain 60FPS and to not get over it either
		local sleepTime = 16666666 - timeTools.getTimeSinceNS(start)
		timeTools.sleepNS(sleepTime)
	end
	--clear the screen at the end because we are nice like that.
	os.execute("clear")
end
return main
