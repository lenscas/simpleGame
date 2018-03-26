--HERE BE DRAGONS!
--I copied the code from someone else and I have no idea how it works
--Feel free to dig through it though, just be carefull of any lurking dragons.
local p = require( "posix" )

--basic function to deep copy a table. 
local function table_copy( t )
	local copy = {}
	for k,v in pairs( t ) do
		if type( v ) == "table" then
			copy[ k ] = table_copy( v )
		else
			copy[ k ] = v
		end
	end
	return copy
end

assert( p.isatty( p.STDIN_FILENO ), "stdin not a terminal" ) --crash if STDIN is not a terminal
local saved_tcattr = assert( p.tcgetattr( p.STDIN_FILENO ) )
local raw_tcattr = table_copy( saved_tcattr )
local basicInput = p.fdopen(p.STDIN_FILENO,"r") --change I did. This is a file handler to STDIN
raw_tcattr.lflag = bit32.band( raw_tcattr.lflag, bit32.bnot( p.ICANON ) )

local guard = setmetatable( {}, { __gc = function()
	p.tcsetattr( p.STDIN_FILENO, p.TCSANOW, saved_tcattr )
end } )

local function kbhit()
	--this code checks if there are characters that can be read from STDIN
	assert( p.tcsetattr( p.STDIN_FILENO, p.TCSANOW, raw_tcattr ) )
	local r = assert( p.rpoll( p.STDIN_FILENO,0) )
	assert( p.tcsetattr( p.STDIN_FILENO, p.TCSANOW, saved_tcattr ) )
	if r == 1 then
		return basicInput:read(1) --another change I made. this reads 1 character from STDIN.
	elseif r == 0 then
		return nil -- no new characters inside STDIN
	else
		error("WTF!") --this means STDIN was closed. Obviously, this shouldn't happen
	end
end

return kbhit
