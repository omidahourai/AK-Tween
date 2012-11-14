----------------------------------------------
--PROJECT: AKTWEEN
--AUTHOR: OMID AHOURAI, ARDENTKID
--
--THIS LIBRARY IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------

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

	local particles = require('Classes.Particles')
	scene.particles = particles

	local tweens = require('Classes.Tweens')
	scene.tweens = tweens

	local Performance = require('Classes.Performance')
	scene.Performance = Performance

	scene:addEventListener('start', scene)
	function scene:start()
		self.isActive = true
	end

	scene:addEventListener('stop', scene)
	function scene:stop()
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