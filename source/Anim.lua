local Anim = oo.class()

function Anim:init(frames)
	self.isPlaying = false
	self.frames = nil
	self.timePerFrame = 1/30
	self.timeElapsed = 0
	self.pos = 1
	self.frame = 1
	if frames then
		self:play(frames)
	end
end

function Anim:play(frames, restart)
	if self.frames ~= frames or restart then
		self.frames = frames
		self.timePerFrame = 1/(frames.rate or 30)
		self.pos = 1
	end
	self.isPlaying = true
end

function Anim:stop()
	self.isPlaying = false
end

function Anim:update(dt)
	self.timeElapsed = self.timeElapsed + dt
	if self.isPlaying and self.timeElapsed >= self.timePerFrame then
		if self.pos >= #self.frames then
			if self.frames.loop == false then
				self.isPlaying = false
			else
				self.pos = 1
			end
		else
			self.pos = self.pos+1
		end
		self.frame = self.frames[self.pos] or 1
		self.timeElapsed = 0
	end
end

return Anim