--------------------------------------------------------------
-- SET UP EVERYTHING -----------------------------------------

display.setStatusBar( display.HiddenStatusBar )

local globals    = require( "libs.globals" )
local storyboard = require( "storyboard" )

-- Only the bare minimum setup here, just enough to make this scene function - the rest is set up in 'setup'

-- What platform?
if system.getInfo( "platformName" ) == "iPhone OS" then globals.platform = "apple"
else                                                    globals.platform = "android" ; end

-- Set up defaults
display.setDefault( "magTextureFilter", "nearest" )

-- Set up some globals
globals.isSimulator  = ( "simulator" == system.getInfo( "environment" ) )
globals.screenWidth  = display.contentWidth
globals.screenHeight = display.contentHeight

-- Set up storyboard effects
globals.sbFade = { effect = "fade", time = 400 }

-- Set up groups 'sandwich'
globals.groups = {
	root       = display.newGroup(), 
	bg         = display.newGroup(), 
	storyboard = storyboard.stage, 
}
globals.groups.root:insert( globals.groups.bg )
globals.groups.root:insert( globals.groups.storyboard )

-- Start it all!
storyboard.gotoScene( "code.setup", globals.sbFade )
