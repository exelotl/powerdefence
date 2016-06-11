-- Limits and smooths the frame rate

local nextTime = 0

return function (fps)
	local time = love.timer.getTime()

	if nextTime <= time then
		nextTime = time
	else
		love.timer.sleep(nextTime - time)
	end
	
	nextTime = nextTime + 1/fps
end
