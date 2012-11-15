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

local Particles={
	instances = {},
	scene = scene,
	disp = scene
}

local mt = math
local mRand = mt.random
local dW, dH, sW, sH = scene.dW, scene.dH, scene.sW, scene.sH
local transition = transition
local easing = easing

--RANDOM ARRAYS
local xStart, xEnd, yStart, yEnd = -sW, sW, sH*1.5, sH*.25
local xvalArr={}; for i=1,500 do table.insert(xvalArr, mRand(xStart,xEnd)) end
local yvalArr={}; for i=1,500 do table.insert(yvalArr, mRand(yEnd,yStart)) end

--CREATE 25 PRE-DETERMINED TWEENS AND STORE THEM INTO OUR ARRAY
local tweenArr = {}
local yEnd = -dH*.75
for i=1,25 do 
	local xEnd = table.remove(xvalArr,1); table.insert(xvalArr,xEnd)
	local tween = AKtween:newTween({time=5000, y=yEnd, ease='outQuad', onComplete={time=5000, y=-yEnd, ease='inQuad'}})
	tween:append({time=10000, x=xEnd})
	table.insert(tweenArr, tween)
end

function Particles:new()
	local radius = mRand(4,9)
	local particle = display.newCircle(0,0,radius)
	particle.strokeWidth = radius*.2
	particle.isVisible = false

	particle.cr=mRand(195,205)
	particle.cg=mRand(165,175)
	particle.cb=mRand(115,125)

	particle.gr=mRand(120,130)
	particle.gg=mRand(140,150)
	particle.gb=mRand(200,255)

	local xEnd = table.remove(xvalArr,1); table.insert(xvalArr,xEnd)
	particle.xEnd, particle.yEnd = sW + xEnd, dH
	particle.yMid = dH*0.25
	
	local tween = table.remove(tweenArr,1); table.insert(tweenArr, tween)
	tween:apply(particle, 'moveAnim')

	particle.show = self.show
	function particle:dispose() Particles:dispose(self) end
	particle.Class = self
	table.insert(self.instances, particle)
	return particle
end

function Particles:dispose(particle)
	particle.isVisible=false
	table.insert(self, particle)
	scene:dispatchEvent({name='disposeParticle'})
end

function Particles:get(color)
	local instances = self.instances
	local particle
	if (instances[1]) then particle = table.remove(instances, 1)
	else particle = self:new() end
	return particle
end

function Particles:dispose(particle)
	table.insert(self.instances, particle)
end

scene:addEventListener('showParticle', Particles)
function Particles:showParticle(color)
	local particle = self:get()
	particle:show(color)
	return particle
end

function Particles:show(type)
	self.isVisible = true
	self.x, self.y = sW, dH

	if (type=='transitions') then
		local t, t2 = 5000, 10000
		self:setFillColor(self.cr, self.cg, self.cb)
		self.tweenFC = transition.to(self, {time=t2, x=self.xEnd})
		self.tweenFC = transition.to(self, {time=t, y=self.yMid, transition=easing.outQuad, onComplete=function()
			self.tweenFC = transition.to(self, {time=t, y=self.yEnd, transition=easing.inQuad, onComplete=function()
				self:dispose()
			end})
		end})
	elseif (type=='tableValues') then
		self:setFillColor(self.gr, self.gg, self.gb)
		self:playTween('moveAnim', {onComplete=function() self:dispose() end})
	end
end


return Particles
