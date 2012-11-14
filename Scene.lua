----------------------------------------------------------------------------
--PROJECT: AKTWEEN BENCHMARK APP
--AUTHOR: ARDENTKID (OMID AHOURAI)
--http://www.ardentkid.com
--
--THIS APP IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------------------------------------

local game = storyboard.newScene()

function game:createScene( event )
	scene = self.view
	local scene = scene

	dW = display.contentWidth; scene.dW = dW
	dH = display.contentHeight; scene.dH = dH
	sW = display.contentCenterX; scene.sW = sW
	sH = display.contentCenterY; scene.sH = sH

	--CREATE TWEEN OBJ
	AKtween = require('Classes.AKtween')
	scene.AKtween = AKtween
	
	local Hud = require('Classes.Hud')
	scene.Hud = Hud

	local Particles = require('Classes.Particles')
	scene.Particles = Particles
	for i=1,700 do Particles:new() end

	function scene:tweenIt(p)
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

	scene:addEventListener('pickTweenType', scene)
	function scene:pickTweenType(event)
		self.type = event.type
	end

	scene:addEventListener('start', scene)
	function scene:start(event)
		local scene = self.scene
		local particles = scene.particles

		scene:dispatchEvent({name='pickTweenType', type=event.type})

		local function frameCount()
			local particle = particles:get()
			local colors = particle[self.type]
			particle:setFillColor(colors.cr,colors.cg,colors.cb)
			self:tweenIt(particle)
		end

		self.isActive = true
		self.runtimeFC = frameCount
		Runtime:addEventListener('enterFrame', frameCount)
	end

	scene:addEventListener('stop', scene)
	function scene:stop()
		Runtime:removeEventListener('enterFrame', self.runtimeFC)
		self.isActive = false
	end

end

function game:willEnterScene()
	local scene = self.view

end

function game:enterScene( event )	
	local scene = self.view
end

function game:exitScene( event )
	local scene = self.view
end

function game:destroyScene( event )
	local scene = self.view
end

game:addEventListener( "createScene", game )
game:addEventListener( "willEnterScene", game )
game:addEventListener( "enterScene", game )
game:addEventListener( "exitScene", game )
game:addEventListener( "destroyScene", game )

return game