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
if (scene.Tweens) then return scene.Tweens end

local Tweens = {}
Tweens.scene = scene
local dH = scene.dH
Tweens.animCt = 0

scene:addEventListener('start', Tweens)
function Tweens:start(event)
	local scene = self.scene
	local particles = scene.particles

	scene:dispatchEvent({name='pickTweenType', type=event.type})

	local function frameCount()
		local particle = particles:get()
		local colors = particle[self.type]
		particle:setFillColor(colors.cr,colors.cg,colors.cb)
		self:tweenIt(particle)
	end
	self.runtimeFC = frameCount
	Runtime:addEventListener('enterFrame', frameCount)
end

function Tweens:tweenIt(p)
	local scene = self.scene
	local dW, dH, sW, sH = scene.dW, scene.dH, scene.sW, scene.sH
	local particles = scene.particles
	local t, t2 = 5000, 10000
	local transition = transition
	local easing = easing
	local type = self.type
	p.x, p.y = sW,dH
	local xEnd = p.xEnd

	if (type=='transitions') then
		local yMid, yEnd = p.yMid, p.yEnd
		p.tweenFC = transition.to(p, {time=t2, x=xEnd})
		p.tweenFC = transition.to(p, {time=t, y=yMid, transition=easing.outQuad, onComplete=function()
			p.tweenFC = transition.to(p, {time=t, y=yEnd, transition=easing.inQuad, onComplete=function()
				particles:dispose(p)
			end})
		end})
	elseif (type=='tableValues') then
		p:playTween('anim'..p.animCt, {onComplete=function() particles:dispose(p) end})
	end
end

scene:addEventListener('pickTweenType', Tweens)
function Tweens:pickTweenType(event)
	self.type = event.type
end

scene:addEventListener('stop', Tweens)
function Tweens:stop()
	Runtime:removeEventListener('enterFrame', self.runtimeFC)
end

return Tweens
