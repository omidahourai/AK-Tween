----------------------------------------------------------------------------
--PROJECT: AKTWEEN BENCHMARK APP
--AUTHOR: ARDENTKID (OMID AHOURAI)
--http://www.ardentkid.com
--
--THIS APP IS FREE TO USE AND DISTRIBUTE 
--WITHOUT CHARGE, AS LONG AS THESE COMMENTS
--REMAIN. COPYRIGHT 2012. ALL RIGHTS RESERVED.
----------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )
io.output():setvbuf('no') -- show print commands on iphone console

storyboard = require("storyboard")
storyboard.isDebug = true
storyboard.purgeOnSceneChange = true

storyboard.gotoScene("Scene")
