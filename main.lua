--makes us able to load our classes and libs
package.path     = package.path .. ";./classes/?.lua;./libs/?.lua;./programs/?.lua"
os.execute("clear") --nice clear screen
io.stdout:setvbuf 'no' --else output will only be shown after we write a newline
--{{{parse arguments
local args = {...}
local betterArgs = {}
local kind
for k,v in ipairs(args) do
	if kind then
		betterArgs[kind] = v
		kind = nil
	else
		--check if its a value that just need to exist and set them to true if they are
		if v == "--bot" or v=="-b" then
			betterArgs["-b"] = true
		elseif v == "-c" or v=="--compress" then
			betterArgs["-c"] = true
		else
			kind = v
		end
	end
end
--}}}
---{{{setup configuration
local file   = betterArgs["-t"] or betterArgs["--type"] or "game"
local runBot = file=="game" and betterArgs["-b"]
local limit  = runBot and tonumber((betterArgs["-l"] or betterArgs["--limit"] or 200))
local displayFile = (betterArgs["-f"] or betterArgs["--file"] or "out.txt")
local compress = betterArgs["-c"] or false
displayFile = "./records/" .. displayFile --add the records path in front of the given name

local toRun
if file == "game" then
	toRun = require"game"
elseif file=="display" then
	toRun = require"display"
end

---}}}

--if its marked as compressed we need to decompress it first before we can access it
if file=="display" and compress then
	os.execute("gunzip "..displayFile..".gz")
end
--run the selected program
toRun({
	file   = displayFile,
	isBot  = runBot,
	limit  = limit,
	bot    = (runBot or nil) and require"basicBot" --get the bot if needed
})
--gunzip removed the file so either way if it was marked to as compressed we need to compress.
--no matter if we just display the file or made a new one
if compress then
	os.execute("gzip "..displayFile)
end
