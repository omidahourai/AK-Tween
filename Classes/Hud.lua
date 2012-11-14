----------------------------------------------------------------------------
--PROJECT: AKTWEEN BENCHMARK APP
--AUTHOR: ARDENTKID (OMID AHOURAI)
--http://www.ardentkid.com
--
--THIS APP IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------------------------------------

local scene = scene
if (scene.Hud) then return scene.Hud end
local dH, sH, dW, sW = scene.dH, scene.sH, scene.dW, scene.sW

Hud = display.newGroup()
scene:insert(Hud)
Hud.scene = scene

local memoryTxt = display.newText('00 00.00 000',10,0, 'Helvetica', 30);
memoryTxt:setReferencePoint(display.TopCenterReferencePoint)
memoryTxt.x, memoryTxt.y = sW,0
Hud:insert(memoryTxt); Hud.memoryTxt = memoryTxt
memoryTxt.Hud = Hud

local holdTxt = display.newText('FPS steady',10,0, 'Helvetica', 25)
holdTxt:setReferencePoint(display.TopCenterReferencePoint)
holdTxt.x, holdTxt.y = sW,36
Hud:insert(holdTxt); Hud.holdTxt = holdTxt
holdTxt:setTextColor(150,255,150)

local counter = display.newText('0', 0,0, system.nativeFont, 30)
counter.x, counter.y = scene.dW-100, 130
Hud.counter = counter

local spawnType = display.newText('transitions', 0,0, system.nativeFont, 30)
spawnType.x, spawnType.y = scene.dW-100, 170
Hud.spawnType = spawnType

--BUTTONS
local onOffBtn = display.newGroup()
	local txt = display.newText('Off', 0,0, 'Helvetica', 30)
	onOffBtn:insert(txt); onOffBtn.txt = txt
	txt.x, txt.y = 90,40

	local btn = display.newRect(0,0,180,80)
	onOffBtn:insert(btn); onOffBtn.btn = btn
	btn:setFillColor(255,255,255,0)
	btn.strokeWidth = 5
	Hud:insert(onOffBtn); Hud.onOffBtn = onOffBtn
	onOffBtn:setReferencePoint(display.CenterRightReferencePoint)
	onOffBtn.x, onOffBtn.y = scene.dW+6, 380
onOffBtn:addEventListener('touch', Hud)

--TWEEN TYPE BUTTONS
local typeBtns = {}; Hud.typeBtns = typeBtns
local transBtn = display.newGroup()
	local txt = display.newText('trans.to', 0,0, 'Helvetica', 30)
	transBtn:insert(txt); transBtn.txt = txt
	txt.x, txt.y = 80,35

	local btn = display.newRect(0,0,180,80)
	transBtn:insert(btn); transBtn.btn = btn

	btn:setFillColor(255,255,255,100)
	btn.strokeWidth = 5
	Hud:insert(transBtn); Hud.transBtn = transBtn
	transBtn:setReferencePoint(display.CenterRightReferencePoint)
	transBtn.x, transBtn.y = 100, dH
transBtn:addEventListener('touch', Hud)
transBtn.type = 'transitions'
transBtn.rotation = 90
table.insert(typeBtns, transBtn)

local tableBtn = display.newGroup()
	local txt = display.newText('AKtween', 0,0, 'Helvetica', 30)
	tableBtn:insert(txt); tableBtn.txt = txt
	txt.x, txt.y = 80,35

	local btn = display.newRect(0,0,180,80)
	tableBtn:insert(btn); tableBtn.btn = btn

	btn:setFillColor(255,255,255,0)
	btn.strokeWidth = 5
	Hud:insert(tableBtn); Hud.tableBtn = tableBtn
	tableBtn:setReferencePoint(display.CenterRightReferencePoint)
	tableBtn.x, tableBtn.y = 220, dH
tableBtn:addEventListener('touch', Hud)
tableBtn.type = 'tableValues'
tableBtn.rotation = 90
table.insert(typeBtns, tableBtn)

scene:addEventListener('addParticle', Hud)
function Hud:addParticle(event)
	local counter = self.counter
	counter.text = counter.text+1
end

scene:addEventListener('disposeParticle', Hud)
function Hud:disposeParticle(event)
	local counter = self.counter
	counter.text = counter.text-1
end

scene:addEventListener('start', Hud)
function Hud:start()
	local btnG = self.onOffBtn
	btnG.txt.text = 'On'
	btnG.btn:setFillColor(255,255,255,100)
	self.setAvg = true
    if (not self.updateFC) then self:countFrames() end
end

scene:addEventListener('stop', Hud)
function Hud:stop()
	local btnG = self.onOffBtn
	btnG.txt.text = 'Off'
	btnG.btn:setFillColor(255,255,255,0)
	self.setAvg = false
end

function Hud:changeBtns(btn)
	local typeBtns = self.typeBtns
	for i=1,#typeBtns do
		local button = typeBtns[i]
		local bkgr = button.btn
		if (btn == button) then 
			bkgr:setFillColor(255,255,255,100)
			scene:dispatchEvent({name='pickTweenType', type=btn.type})
		else bkgr:setFillColor(255,255,255,0) end
	end
	self.spawnType.text = btn.type
end

function Hud:touch(event)
	if (event.phase == 'began') then
		local scene = self.scene
		local target = event.target

		if (target == self.onOffBtn) then
			if (scene.isActive) then scene:dispatchEvent({name='stop'})
			else scene:dispatchEvent({name='start', type=self.spawnType.text}) end
		else self:changeBtns(target) end
	end
end

function Hud:countFrames()
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

return Hud
