----------------------------------------------
--PROJECT: AKTWEEN
--AUTHOR: OMID AHOURAI, ARDENTKID
--
--THIS LIBRARY IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------

local scene = scene
if (scene.particles) then return scene.particles end

local particles={}
particles.scene = scene

local AKtween = require('Classes.AKtween')
local dH = scene.dH
local mt = math
local mRand = mt.random

--RANDOM ARRAYS
local xStart, xEnd, yStart, yEnd = -sW, sW, sH*1.5, sH*.25
local xvalArr={}; for i=1,5000 do table.insert(xvalArr, mRand(xStart,xEnd)) end
local yvalArr={}; for i=1,5000 do table.insert(yvalArr, mRand(yEnd,yStart)) end

local classTweens = AKtween:create('test')
local T_particle = AKtween:newTween()

local yMid, yEnd = -dH*.75, 0
for i=1,25 do 
	local xEnd = table.remove(xvalArr,1); table.insert(xvalArr,xEnd)
	T_particle:subscribe('anim'..i, {time=5000, y=yMid, ease='outQuad', onComplete={time=5000, y=yEnd, ease='inQuad'}})
	T_particle:subscribe('anim'..i, {time=10000, x=xEnd})
	local T_particle = AKtween:newTween({time=5000, y=yMid, ease='outQuad', onComplete={time=5000, y=yEnd, ease='inQuad'}})
	T_particle:append({time=10000, x=xEnd})
end

local animCount = 1

function particles:get()
	local scene = self.scene
	local particle
	if (self[1]) then particle = table.remove(self, 1)
	else 
		local rad = table.remove(self.radArr, 1); table.insert(self.radArr, rad)
		particle = self.class(rad)
	end
	particle.isVisible=true

	local xEnd = table.remove(xvalArr,1); table.insert(xvalArr,xEnd)
	xEnd = scene.sW + xEnd
	particle.xEnd = xEnd

	scene:dispatchEvent({name='addParticle'})
	return particle
end

function particles:dispose(particle)
	particle.isVisible=false
	table.insert(self, particle)
	scene:dispatchEvent({name='disposeParticle'})
end

local function newParticle(radius)
	local m=math
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
		particle.xEnd, particle.yEnd = xEnd, dH
		particle.yMid = dH*0.25
		particle.animCt = m.random(1,25)
	return particle
end

particles.class = newParticle
local radArr={}; for i=1,10 do table.insert(radArr, math.random(4,9)) end
for i=1,700 do
	local rad = radArr[math.random(1,10)]
	local particle = newParticle(rad)
	T_particle:apply(particle)
	table.insert(particles, particle)
end
particles.scene = scene
particles.disp = scene
particles.radArr = radArr

return particles
