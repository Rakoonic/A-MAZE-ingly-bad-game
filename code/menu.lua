--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local globals    = require( "libs.globals" )
local settings   = require( "libs.settings" )
local widget     = require( "widget" )
local storyboard = require( "storyboard" )
local scene      = storyboard.newScene()

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local group = self.view

	-- BG
	local bg   = display.newImageRect( group, "gfx/menu.png", globals.screenWidth, globals.screenHeight )
	bg:setReferencePoint( display.TopLeftReferencePoint )
	bg.x, bg.y = 0, 0

	-- Display best run
	local bestMoves = settings.get( "bestMoves" )

	if bestMoves then
		local text = display.newText( group, "FEWEST MOVES TO COMPLETE GAME: " .. bestMoves, 0, 0, nil, 16 )
		text.x     = globals.screenWidth / 2
		text.y     = 200
	end

	-- Create a button
	local button = widget.newButton{
		label   = "PLAY!",
		width   = 200,
		height  = 70,
		onPress = function()
			globals.moves  = 0
			globals.levels = {}
			storyboard.gotoScene( "code.game", globals.sbFade )
		end,
	}
	group:insert( button )
	button.x = globals.screenWidth / 2
	button.y = 260

	-- Create a button
	local button = widget.newButton{
		label   = "?",
		width   = 50,
		height  = 50,
		onPress = function()
			storyboard.gotoScene( "code.help", globals.sbFade )
		end,
	}
	group:insert( button )
	button.x = globals.screenWidth - 30
	button.y = globals.screenHeight - 30
	
end
function scene:didExitScene( event )

	storyboard.purgeScene( "code.menu" )

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "didExitScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
