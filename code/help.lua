--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local globals    = require( "libs.globals" )
local widget     = require( "widget" )
local storyboard = require( "storyboard" )
local scene      = storyboard.newScene()

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local group = self.view

	local texts = {
		"INSTRUCTIONS!",
		"The goal of the game is to complete all 10 mazes in the fewest number of moves possible by getting the Purple blob (you) to the green blob (the exit).",
		"However, simply racing for the exit may not give you the least possible moves.",
		"This is because each of the following mazes are generated according to a seed based on the number of moves you took in the current maze.",
		"So it is possible that if you take a few more moves in the current maze, you will face a much shorter maze in the future.",
		"Only trial and error will determine the fastest overall route!",
		"Many thanks to everyone on the #corona IRC channel for motivating and helping me - particularly Tyraziel - the git!",
		"Rakoonic aka Barry Swan of Inludo",
	}
	local x     = math.floor( globals.screenWidth / 2 )
	local y     = 5
	for i = 1, #texts do	
		local text = display.newText( group, texts[ i ], 0, 0, globals.screenWidth - 10, 0, nil, 14 )
		if i == 1 then    text:setTextColor( 255, 127, 255 )
		elseif i > 6 then text:setTextColor( 255, 255, 127 )
		else              text:setTextColor( 191, 191, 191 ) ; end
		text:setReferencePoint( display.TopCenterReferencePoint )
		text.x     = globals.screenWidth / 2
		text.y     = y
		y          = y + text.contentHeight + 5
	end

	-- Create a button
	local button = widget.newButton{
		label   = "/\\",
		width   = 50,
		height  = 50,
		onPress = function()
			storyboard.gotoScene( "code.menu", globals.sbFade )
		end,
	}
	group:insert( button )
	button.x = globals.screenWidth - 30
	button.y = globals.screenHeight - 30
	
end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
