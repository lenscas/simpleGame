local pos = require"posix.time"
local module = {}
--sleeps for a certain amount of time in Nano seconds.
--needs to be given an integer which is less than 1000000000
function module.sleepNS(sleepTime)
	local res,err,num
	--this function can return early in some cases, in those cases, lets sleep again
	local remain = sleepTime
	while remain > 0 do
		res,err,num,remain = pos.nanosleep({
			tv_sec = 0,
			tv_nsec = remain
		})
		remain = remain or 0 --most of the time though, remain isn't set. In which case, set it to 0
	end
end
--gets a PosixTimeTable consisting of a seconds field (tv_sec) and a nano seconds field (tv_nsec)
function module.getTimeNS()
	local timeTable = pos.clock_gettime(pos.CLOCK_REALTIME)
	return timeTable
end
--given a PosixTimeTable, calculate the amount of nano seconds that has passed since
--returns an integer which represent the amount of nano seconds that have passed.
function module.getTimeSinceNS(timeTable)
	local now  = module.getTimeNS()
	local secs = now.tv_sec - timeTable.tv_sec
	local ns   = now.tv_nsec - timeTable.tv_nsec
	if secs > 0 then
		ns = ns + secs * 1000000000
	end
	return ns
end
return module
