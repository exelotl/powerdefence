
-- vector from a to b
function vecTo(ax, ay, bx, by)
    return bx-ax, by-ay
end


function normVec(x, y)
    local mag = math.sqrt(x^2+y^2)
    return x/mag, y/mag
end

-- gets the normalised direction vector from a to b
function directionTo(ax, ay, bx, by)
    return normVec(vecTo(ax, ay, bx, by))
end


function angleTo(ax, ay, bx, by)
    local x, y = vecTo(ax, ay, bx, by)
    return math.atan2(y, x)
end


function fromPolar(mag, dir)
    return mag*math.cos(dir), mag*math.sin(dir)
end

-- pick from a probability density function
-- eg {a = 0.4, b = 0.6} means return a: 40% of the time and b: 60%
-- probabilities should sum to 1
-- return nil if pdf empty or sum(pdf) < 1
-- returns a string: if the PDF refers to variable names, use:
-- _G[pickFromPDF({...})] to obatin the variable rather than the name
function pickFromPDF(pdf)
    local v = math.random() -- ~ uniform [0,1]
    local total = 0
    for item, prob in pairs(pdf) do
        total = total + prob
        if total >= v then
            return item
        end
    end
    return nil
end


-- small unit test for the pdf function above
local function testPickFromPDF()
    local as = 0
    local bs = 0
    local pdf = {a = 0.3, b = 0.7}
    for i=1,100000 do
        local choice = pickFromPDF(pdf)
        if choice == 'a' then
            as = as + 1
        elseif choice == 'b' then
            bs = bs + 1
        else
            assert(false)
        end
    end
    printf('as: %i, bs: %i', as, bs)
end


-- calculate a moving average of occurring events over a set window size. eg
-- enemies being killed over a 5 second window. This class logs the time of each
-- event and getAvgRate() determines the average rate of the events over the
-- last N seconds where N is the window size
MovingAverageRate = oo.class()

function MovingAverageRate:init(windowDuration)
    self.eventTimes = {}
    self.windowDuration = windowDuration -- seconds
end

function MovingAverageRate:logEvent()
    table.insert(self.eventTimes, globalTimer)
end


function MovingAverageRate:getAvgRate()
    local keepPred = function(time)
        return time >= globalTimer - self.windowDuration
    end
    -- filtering is O(n) but realistically there should be <100 entries so its ok?
    self.eventTimes = ifilter(self.eventTimes, keepPred)
    return #self.eventTimes / self.windowDuration
end

function MovingAverageRate:getAvgInterval()
    return 1 / self:getAvgRate()
end

