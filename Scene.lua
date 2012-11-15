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

	--PARTICLE SPAWN RUNTIME
	scene:addEventListener('start', scene)
	function scene:start(event)
		local particles = self.Particles
		self.type = event.type

		local function frameCount()
			self:dispatchEvent({name='showParticle', type=self.type})
			local particle = Particles:showParticle(self.type)
		end

		self.isActive = true
		self.runtimeFC = frameCount
		Runtime:addEventListener('enterFrame', frameCount)
	end

	scene:addEventListener('pickTweenType', scene)
	function scene:pickTweenType(event)
		self.type = event.type
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