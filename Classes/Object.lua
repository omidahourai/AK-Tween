----------------------------------------------
--PROJECT: AKTWEEN
--AUTHOR: OMID AHOURAI, ARDENTKID
--
--THIS LIBRARY IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------

module(..., package.seeall)

function new(scene, config, disp, groupBool)
	local object
	if (groupBool) then object = display.newGroup()
	else object = {} end
	
	object.landscape = scene
	object.anim = {}

	object.scene = scene
	object.type = 'object'
	object.name = 'object'
	object.hitcount = 0
	object.config = config
	object.path = config.path
	
	if (not disp) then object.disp = scene.landscape
	else object.disp = disp end

	
	function object:show(config, ref)
		local scene = self.scene
		if (config) then
			for k,v in pairs(config) do self.config[k] = v end
		end
		local config = self.config
		local spr = self.spr
		local disp = self.disp
		if (spr.isVisible) then self:hide() end

		self.offsetRefX, self.offsetRefY = spr.xReference, spr.yReference
		spr:setReferencePoint(display.CenterReferencePoint)

		--INITIALIZE
		self.currentState = 'default'
		-- self.collisionEnabled = true
		self.isMoveEnabled = true
		if (not self.difficulty) then self.difficulty = scene.DIFFICULTY or 1 end
		self.direction = 1 --positive x direction
		disp:insert(3,spr)

		--POSITION
		if (not ref) then ref = {x=0, y=0} end
		local xval, yval = config.xval, config.yval

		if (type(xval) == 'string') then
			if (xval == 'center') then spr.x = ref.x; self.curLane = 0
			elseif (xval == 'left') then spr.x = ref.x - scene.LANE_TOT; self.curLane = -1
			elseif (xval == 'right') then spr.x = ref.x + scene.LANE_TOT; self.curLane = 1 end
		elseif (xval) then 
			if (xval < 3) then spr.x = ref.x + xval*sW
			else spr.x = ref.x + xval end
		else spr.x = math.random(1,dW) end

		if (yval) then spr.y = ref.y - yval
		else 
			local cx, cy = disp:contentToLocal(0,0)
			spr.y = cy
		end

		--ROTATION
		if (config.rot) then spr.rotation = config.rot end

		--SPRITE
		if (spr.prepare) then spr:prepare(config.sprite) end
		if (self.playOnShow) then spr:play(config.sprite) end
		spr.isVisible = true
		spr.alpha = 1

		scene:addEventListener('hide', self)
		scene:addEventListener('pause', self)
		scene:addEventListener('resume', self)
		self:beginEnterFrame()

		if (self.isJumpable) then self:addJumpTest() end
		-- if (self.player) then self.player:toFront() end
		if (self.showSecondary) then self:showSecondary(config) end
	end
	

	function object:addJumpTest()
		local countered = false
		local player = self.player
		local pDisp = player.disp
		local spr = self.spr
		local disp = self.disp

		print('addJumpTest to '..self.name)
		local comp1 = self.alertradius + player.hitradius
		local comp2 = self.hitradius + player.hitradius
		local curLane = self.curLane
		local glow = self.glow

		local px, py, sprX, sprY
		local dx, dy, hyp


		--UPON WEAPON COLLECTION, DISPATCH EVENT TO CLEAR PLAYER ALERTS

		local function calculate()
			px, py = pDisp:localToContent(player.x, player.y)
			sprX, sprY = disp:localToContent(spr.x, spr.y)
			dx, dy = sprX - px, sprY - py
			hyp = dx*dx + dy*dy
		end

		local function watchCounter(event)
			if (event.target == self) then
				countered = true
				scene:removeEventListener('playerSetCounter', watchCounter)
				self.setCounterFC = nil
				disp:insert(glow)
				glow.x, glow.y = spr.x, spr.y
				glow.isVisible = true
				spr:toFront()
				-- self:addTween(glow, 0.35, {xScale=1, yScale=1, alpha=0})
			end
		end

		local function alertedPlayer()
			calculate()
		 	if (hyp < comp2) then
		 		if (countered) then scene:dispatchEvent({name='playerHasCountered', target=self})
		 		else 
					scene:removeEventListener('playerSetCounter', watchCounter)
					self.setCounterFC = nil
		 			scene:dispatchEvent({name='obstacleHit', target=self, hitTarget=player, phase='success'})
		 		end
		 		Runtime:removeEventListener('enterFrame', alertedPlayer)
		 		self.collisionFC = nil
		 	elseif (sprY > py) then
		 		scene:dispatchEvent({name='obstacleHit', target=self, hitTarget=player, phase='cancelled'})
		 		Runtime:removeEventListener('enterFrame', alertedPlayer)
		 		self.collisionFC = nil
		 		scene:removeEventListener('playerSetCounter', watchCounter)
				self.setCounterFC = nil
		 	end
		end

		local function checkToAlert()
			if (player.curLane == curLane) then
				calculate()
				if (hyp < comp1) then
					Runtime:removeEventListener('enterFrame', checkToAlert)
					self.collisionFC = alertedPlayer
					Runtime:addEventListener('enterFrame', alertedPlayer)
					self.setCounterFC = watchCounter
					scene:addEventListener('playerSetCounter', watchCounter)
					scene:dispatchEvent({name='playerShowAlert', target=self})
				end
			end
		end

		self.collisionFC = checkToAlert
		Runtime:addEventListener('enterFrame', checkToAlert)
	end

	function object:leftright(from, to)
		local spr = self.spr
		if (spr.x < from or spr.x > to) then self.direction = self.direction*-1 end
		spr.x = spr.x+3*self.direction
	end
	
	function object:changeSpeed(speed)
		self.speed = BG_SPEED * speed
	end

	function object:pause()
		if (self.pauseNum) then self.pauseNum = self.pauseNum+1 else self.pauseNum = 1 end
		if (self.collisionFC) then Runtime:removeEventListener('enterFrame', self.collisionFC) end
		if (self.enterFrameFC) then Runtime:removeEventListener('enterFrame', self.enterFrameFC) end
		if (self.pauseSecondary) then self:pauseSecondary() end
	end
	
	function object:resume()
		if (self.collisionFC) then Runtime:addEventListener('enterFrame', self.collisionFC) end
		if (self.enterFrameFC) then Runtime:addEventListener('enterFrame', self.enterFrameFC) end
		if (self.resumeSecondary) then self:resumeSecondary() end
	end

	function object:hideShrink()
		if (self.onTrack) then
			if (self.setCounterFC) then Runtime:removeEventListener('enterFrame', self.setCounterFC); self.setCounterFC = nil end
			if (self.collisionFC) then Runtime:removeEventListener('enterFrame', self.collisionFC); self.collisionFC = nil end

			-- self:addTween(self.spr, 0.3, {xScale=0.01, yScale=0.01, ease='inQuad', onComplete=function() self:hide() end})
			if (self.hideShrinkSecondary) then self:hideShrinkSecondary() end
		end
	end

	function object:hide(event)
		print('object:hide() '..self.name)
		local spr = self.spr
		local scene = self.scene
		self.isMoveEnabled = false
		-- self.collisionEnabled = false
		self.curLane = nil
		scene:insert(spr)
		spr.isVisible = false

		scene:removeEventListener('hide', self)
		scene:removeEventListener('pause', self)
		scene:removeEventListener('resume', self)

		if (self.setCounterFC) then
	 		scene:dispatchEvent({name='obstacleHit', target=self, hitTarget=player, phase='cancelled'})
	 		Runtime:removeEventListener('enterFrame', self.collisionFC)
	 		self.collisionFC = nil
	 		scene:removeEventListener('playerSetCounter', self.setCounterFC)
			self.setCounterFC = nil
		end

		Runtime:removeEventListener('enterFrame', self.enterFrameFC); self.enterFrameFC = nil
		if (self.setCounterFC) then Runtime:removeEventListener('enterFrame', self.setCounterFC); self.setCounterFC = nil end
		if (self.collisionFC) then Runtime:removeEventListener('enterFrame', self.collisionFC); self.collisionFC = nil end
		if (self.hideSecondary) then self:hideSecondary(event) end
	end

	return object
end

