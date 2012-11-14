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
if (scene.Particles) then return scene.Particles end

local Particles={
	instances = {},
	scene = scene,
	disp = scene
}

local AKtween = require('Classes.AKtween')
local dH = scene.dH
local mt = math
local mRand = mt.random

--RANDOM ARRAYS
local xStart, xEnd, yStart, yEnd = -sW, sW, sH*1.5, sH*.25
local xvalArr={}; for i=1,1000 do table.insert(xvalArr, mRand(xStart,xEnd)) end
local yvalArr={}; for i=1,1000 do table.insert(yvalArr, mRand(yEnd,yStart)) end

local classTweens = AKtween:create('test')
-- local T_particle = AKtween:newTween()

local yMid, yEnd = -dH*.75, 0
for i=1,25 do 
	local xEnd = table.remove(xvalArr,1); table.insert(xvalArr,xEnd)
	T_particle:subscribe('anim'..i, {time=5000, y=yMid, ease='outQuad', onComplete={time=5000, y=yEnd, ease='inQuad'}})
	T_particle:subscribe('anim'..i, {time=10000, x=xEnd})
	-- local T_particle = AKtween:newTween({time=5000, y=yMid, ease='outQuad', onComplete={time=5000, y=yEnd, ease='inQuad'}})
	-- T_particle:append({time=10000, x=xEnd})
end

function Particles:new()
	local radius = mRand(4,9)
	local particle = display.newCircle(0,0,radius)
	particle.strokeWidth = radius*.2
	particle.isVisible = false

	local r=m.random(195,205)
	local g=m.random(165,175)
	local b=m.random(115,125)
	particle.transitions = {cr=r, cg=g, cb=b}

	local r=m.random(120,130)
	local g=m.random(140,150)
	local b=m.random(200,255)
	particle.tableValues = {cr=r, cg=g, cb=b}

	local xEnd = table.remove(xvalArr,1); table.insert(xvalArr,xEnd)
	particle.xEnd, particle.yEnd = sW + xEnd, dH
	particle.yMid = dH*0.25
	particle.animCt = m.random(1,25)
	
	T_particle:apply(particle)

	function partcle:show()
		particle.isVisible = true
		particle.x, particle.y = sW, dH
		scene:dispatchEvent({name='addParticle'})
	end

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

function Particles:get()
	local instances = self.instances
	if (not instances[1]) then self:new() end
	return table.remove(instances, 1)
end

function Particles:dispose(obj)
	table.insert(self.instances, obj)
	print(#self.instances)
end

function Particles:show(config)
	local obj = self:get()
	obj:show(config)
	return obj
end

return Particles
