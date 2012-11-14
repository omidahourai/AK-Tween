----------------------------------------------------------------------------
--PROJECT: AKTWEEN
--AUTHOR: ARDENTKID (OMID AHOURAI)
--http://www.ardentkid.com
--
--THIS LIBRARY IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
--
--Easing functions adapted from Robert Penner's AS3 tweening equations.
----------------------------------------------------------------------------

local scene = scene
if (scene.AKtween) then return scene.AKtween end

local AKtween={
	pauseAll = false
}

local function calcArr(arr, accumulative, time, to, totFrames, step, ease, from)
	local ct = #arr
	local startArr
	if (ct>0) then startArr,from = ct,arr[ct] else startArr,from = 0,from or 0 end
	local pos = 0
	local delta = to - from

	if (accumulative) then
		if (ease == 'outQuad') then
			for i=1,totFrames do
				pos = pos + step
				local index = i +startArr
				local ratio = -pos*(pos-2)
				arr[index] = from + (ratio * delta)
				-- print('values['..index..'] = '..arr[index])
			end
		elseif (ease == 'inQuad') then
			for i=1,totFrames do
				pos = pos + step
				local index = i +startArr
				local ratio = pos*pos
				arr[index] = from + (ratio * delta)
				-- print('values['..index..'] = '..arr[index])
			end
		elseif (ease == 'inOutQuad') then
			for i=1,totFrames do
				pos = pos + step
				local index = i +startArr
				local ratio
				if pos < 0.5 then ratio = 2*pos*pos
				else ratio = -2*pos*(pos-2)-1 end
				arr[index] = from + (ratio * delta)
				-- print('values['..index..'] = '..arr[index])
			end
		elseif (not ease) then
			for i=1,totFrames do
				pos = pos + step
				local index = i +startArr
				arr[index] = from + (pos * delta)
				-- print('values['..index..'] = '..arr[index])
			end
		end	
	else
		local sign
		if (delta > 0) then sign = 1 else sign = -1 end
		if (ease == 'outQuad') then
			for i=1,totFrames do
				pos = pos + step
				local index = i +startArr
				local ratio = -2*(pos -1)
				arr[index] = -ratio *2.5
				-- print('outQuad values['..index..'] = '..arr[index])
			end
		elseif (ease == 'inQuad') then
			for i=1,totFrames do
				pos = pos + step * sign
				local index = i +startArr
				local ratio = 2*pos
				arr[index] = ratio *2.5
				-- print('inQuad values['..index..'] = '..arr[index])
			end
		elseif (ease == 'inOutQuad') then
			for i=1,totFrames do
				pos = pos + step
				local index = i +startArr
				local ratio
				if pos < 0.5 then ratio = 2*pos*pos
				else ratio = -2*pos*(pos-2)-1 end
				arr[index] = from + (ratio * delta)
				-- print('values['..index..'] = '..arr[index])
			end
		elseif (not ease) then
			local val = step * delta
			for i=1,totFrames do
				local index = i +startArr
				arr[index] = val
				-- print('noEase values['..index..'] = '..arr[index])
			end
		end	
	end
end

local function tweenCalc(config, anim)
	if (not anim) then anim = {} end
	local arr = anim.arr or {}
	-- if (not arr) then arr = {} end

	local time = config.time or 1000
	local ease = config.ease
	local totFrames = 0.06 * time
	local step = 1/totFrames


	local x = config.x
	if (x) then
		local xArr = arr.x or {}
		calcArr(xArr, false, time, x, totFrames, step, ease)
		arr.x = xArr
	end

	local y = config.y
	if (y) then 
		local yArr = arr.y or {}
		calcArr(yArr, false, time, y, totFrames, step, ease)
		arr.y = yArr
	end

	local rotation = config.rotation
	if (rotation) then 
		local rotArr = arr.rotation or {}
		calcArr(rotArr, false, time, rotation, totFrames, step, ease)
		arr.rotation = rotArr
	end

	local xScale = config.xScale
	if (xScale) then 
		local xSclArr = arr.xScale or {}
		calcArr(xSclArr, true, time, xScale, totFrames, step, ease, 1)
		arr.xScale = xSclArr
	end

	local yScale = config.yScale
	if (yScale) then 
		local ySclArr = arr.yScale or {}
		calcArr(ySclArr, true, time, yScale, totFrames, step, ease, 1)
		arr.yScale = ySclArr
	end

	local alpha = config.alpha
	if (alpha) then 
		local alphaArr = arr.alpha or {}
		calcArr(alphaArr, true, time, alpha, totFrames, step, ease)
		arr.alpha = alphaArr
	end

	local xTot, yTot, rotTot, xSclTot, ySclTot, aTot
	for i=1,#arr do
		local tot = #arr[i]
		if (tot > totFrames) then totFrames = tot end
	end

	anim.totFrames = totFrames
	anim.arr = arr

	local onComplete = config.onComplete
	if (onComplete) then tweenCalc(onComplete, anim) end

	return anim
end

function AKtween:enterFrame(event)
	if (not self.pauseAll) then
		for i=1,#self do
			local obj = self[i]
			local curTween = obj.curTween
			if (curTween) then
				local tot = obj.tweenTot
				local ct = obj.tweenCount +1
				if (ct > tot) then
					if (obj.tweenRepeat) then ct =1
					else obj:finishTween() end
				end
				for k,v in pairs(curTween) do
					local value = v[ct]
					if (value) then
						if (k == 'x') then obj:translate(value,0)
						elseif (k == 'y') then obj:translate(0,value)
						else obj[k] = value end
					end
				end
				obj.tweenCount = ct
			end
		end
	end
end

function AKtween:create(name) --AKtween[name] = group
	local class = self[name]
	if (not class) then
		class = {}
		class.name = name
		class.parts = {} --contains parts data
		class.objs = self
		self[name] = class

		function class:newPart(obj, group)
			local part = {}
			part.anims = {}
			part.objs = self.objs

			function part:apply(obj, group)
				obj.curTween = nil
				obj.anims = self.anims
				obj.playTween = AKtween.playTween
				obj.finishTween = AKtween.finishTween

				table.insert(AKtween.objs, obj)
			end

			function part:subscribe(name, config)
				--NEED WAY TO NOT OVERRIDE ANIMS
				local anims = self.anims
				local anim = anims[name]
				anims[name] = tweenCalc(config, anim)
			end

			table.insert(self.parts, part)
			return part
		end

	end

	return class
end

AKtween.anims = {}

function AKtween:newTween(config)
	local tween = {}
	local anims = self.anims

	function tween:apply(obj, group)
		obj.curTween = nil
		obj.anims = self.anims
		obj.playTween = AKtween.playTween
		obj.finishTween = AKtween.finishTween

		table.insert(AKtween.objs, obj)
	end

	function tween:append(config)
		if (config) then tweenCount(config, self)
		else print('AKtween: Tween configuration failed.') end
	end

	tween:append(config)
	return tween
end

function AKtween:playTween(name, config)
	local anim = self.anims[name]
	if (anim) then 
		self.curTween = anim.arr
		self.tweenCount = 0
		self.tweenTot = anim.totFrames
		if (config) then
			self.tweenRepeat = config.repeats
			self.onComplete = config.onComplete
		else
			self.tweenRepeat = nil
			self.onComplete = nil
		end
	end
end

function AKtween:finishTween()
	self.curTween = nil
	self.tweenCount = 0
	if (self.onComplete) then self.onComplete() end
end

Runtime:addEventListener('enterFrame', AKtween)

return AKtween
