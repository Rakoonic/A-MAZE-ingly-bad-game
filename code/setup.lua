--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local globals    = require( "libs.globals" )
local settings   = require( "libs.settings" )
local storyboard = require( "storyboard" )
local widget     = require( "widget" )
local scene      = storyboard.newScene()

-- Note only the bare minimum is set up here initially
-- The rest happens when you want to change screen to hide the pause as it happens

local settingsFile       = "settings-001.txt"
local forceFreshSettings = false

-- Set up theme
globals.theme        = "default"
globals.themePath    = "themes/" .. globals.theme .. "/"
globals.themePathLua = "themes." .. globals.theme .. "."
globals.themeFile    = globals.themePathLua .. "widgets.theme"
widget.setTheme( globals.themeFile )

-- Prototypes
local setup

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

function setup( params )

	-- Set up settings
	settings.initialise( {
		defaultValues = {
			initialised = false,
		},
	})

	-- Force a download
	if forceFreshSettings == true then settings.set( "initialised", false ) ; end

	-- Go to menu
	storyboard.gotoScene( "code.menu", globals.sbFade )

end

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	local group = self.view

	-- BG
	local bg   = display.newImageRect( group, "gfx/splash.png", globals.screenWidth, globals.screenHeight )
	bg:setReferencePoint( display.TopLeftReferencePoint )
	bg.x, bg.y = 0, 0

end
function scene:enterScene( event )

	-- Set up timer
	if globals.isSimulator then timer.performWithDelay( 1, setup )
	else                        timer.performWithDelay( 2000, setup ) ; end

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
