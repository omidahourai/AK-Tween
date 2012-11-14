----------------------------------------------
--PROJECT: AKTWEEN
--AUTHOR: OMID AHOURAI, ARDENTKID
--
--THIS LIBRARY IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------


local scene = scene
if (scene.Performance) then return scene.Performance end

local Performance = display.newGroup()
Performance.scene = scene
Performance.x, Performance.y = display.contentCenterX, 0

local memoryTxt = display.newText('00 00.00 000',10,0, 'Helvetica', 30);
memoryTxt:setReferencePoint(display.TopCenterReferencePoint)
memoryTxt.x, memoryTxt.y = 0,0
Performance:insert(memoryTxt); Performance.memoryTxt = memoryTxt
memoryTxt.Performance = Performance


local holdTxt = display.newText('FPS steady',10,0, 'Helvetica', 25)
holdTxt:setReferencePoint(display.TopCenterReferencePoint)
holdTxt.x, holdTxt.y = 0,36
Performance:insert(holdTxt); Performance.holdTxt = holdTxt
holdTxt:setTextColor(150,255,150)

scene:addEventListener('start', Performance)
function Performance:start(event)
    self.setAvg = true
    if (not self.updateFC) then self:countFrames() end
end

scene:addEventListener('stop', Performance)
function Performance:stop()
    self.setAvg = false
end

function Performance:countFrames()
    local scene = self.scene
    local prevTime = 0
    local mFloor = math.floor
    local sGetInfo = system.getInfo
    local sGetTimer = system.getTimer
    local memoryTxt = self.memoryTxt
    local holdTxt = self.holdTxt
    local ct = 1
    local arr = {}
    local function update()
        local curTime = sGetTimer()
        local fps = mFloor( 1000 / (curTime - prevTime))
        table.insert(arr, fps)
        if (ct >= 10) then
            collectgarbage('collect')
            ct =1
            local val=0
            local tot = #arr
            for i=1,tot do
                val = val+arr[i]
            end
            arr = {}
            avg = mFloor(val/tot)
            memoryTxt.text = tostring(avg).. ' ' ..
            tostring(mFloor(sGetInfo('textureMemoryUsed') * 0.0001) * 0.01) .. ' ' ..
            tostring(mFloor(collectgarbage('count')))
            if (avg > 45) then holdTxt.text = 'FPS steady'; holdTxt:setTextColor(150,255,150)
            else holdTxt.text = 'FPS poor'; holdTxt:setTextColor(255,150,150) end
        else ct = ct+1 end
        prevTime = curTime
    end

    self.updateFC = update
    Runtime:addEventListener('enterFrame', update)
    memoryTxt:addEventListener('tap', memoryTxt)
end

return Performance