--------------------------------------------------------------
-- SETUP -----------------------------------------------------

local globals    = require( "libs.globals" )
local settings   = require( "libs.settings" )
local widget     = require( "widget" )
local storyboard = require( "storyboard" )
local scene      = storyboard.newScene()

-- Prototypes
local moveDir, attemptMove, positionPlayer

local createMaze, deleteMaze
local completeMaze

local showInfo

local mazeCreate, mazeFillRandomly, mazeCreateJoinCells, mazeCreateDefaultIterate, mazeCreateUnusedNeighbours, mazeCreateBiasedNeighbours
local freshCell, isCellEmpty

-- Variables
local sceneGroup, gameGroup, uiGroup

local level = 1
local seed  = 1
local maze
local mazeWidth, mazeHeight
local cellSize, xoffset, yOffset
local player, playerX, playerY
local endX, endY
local levelMoves = 0
local canPlay    = false
local movesText

-- DIRS:
-- 1 = UP
-- 2 = left
-- 3 = DOWN
-- 4 = right

local dirs         = { 1, 2, 3, 4 }
local oppositeDirs = { 3, 4, 1, 2 }

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

function moveDir( dir )

	-- Only allow input if can play
	if canPlay == false then return ; end
	
	-- Do move
	local moveSuccess, completed = attemptMove( dir )
	if moveSuccess == true then
		levelMoves = levelMoves + 1
		showInfo()
		
		if completed == true then
			print( "FINISHED LEVEL!" )
			completeMaze()
		end
	end

end
function attemptMove( dir )

	-- Move
	local x    = playerX
	local y    = playerY
	local cell = maze[ playerX ][ playerY ]
	if cell[ dir ] == 1 then
	
		-- Move in the right direction
		if dir == 1 then     y = playerY - 1
		elseif dir == 2 then x = playerX - 1
		elseif dir == 3 then y = playerY + 1
		elseif dir == 4 then x = playerX + 1 ; end
		positionPlayer( x, y )
		
		-- Did you get to the exit?
		return true, ( x == endX ) and ( y == endY )
	else
		return false, false
	end
	
end
function positionPlayer( x, y, forceUpdate )

	playerX  = x
	playerY  = y
	if forceUpdate == true then
		player.x = math.floor( ( x + 0.5 ) * cellSize ) + xOffset
		player.y = math.floor( ( y + 0.5 ) * cellSize ) + yOffset
	else
		transition.to( player, {
			x    = math.floor( ( x + 0.5 ) * cellSize ) + xOffset, 
			y    = math.floor( ( y + 0.5 ) * cellSize ) + yOffset, 
			time = 200
		} )
	end
	
end

function createMaze( newLevel, newSeed )

	-- Clear previous maze
	deleteMaze()
	
	-- Store values
	seed                    = newSeed
	level                   = newLevel
	globals.levels[ level ] = { seed = seed, moves = 0 }
	levelMoves              = 0

	-- Set up new maze
	gameGroup = display.newGroup()
	sceneGroup:insert( gameGroup )
	gameGroup:toBack()

	-- Get the data for this level ( 10 levels in total, 1 = easiest, 10 = hardest )
	local allMazeData = {
		{ 12, 9, 24,  0, 0 },
		{ 15, 12, 20, 1, 5 },
		{ 17, 14, 18, 4, 5 },
		{ 19, 16, 16, 0, 10 },
		{ 20, 17, 15, 3, 10 },
		{ 22, 19, 14, 0, 0 },
		{ 24, 21, 13, 2, 5 },
		{ 27, 23, 12, 0, 0 },
		{ 30, 25, 11, 5, 10 },
		{ 32, 28, 10, 8, 10 },
	}
	local levelMazeData = allMazeData[ level ]
	mazeWidth           = levelMazeData[ 1 ]
	mazeHeight          = levelMazeData[ 2 ]
	cellSize            = levelMazeData[ 3 ]

	-- Create maze
	maze = {}
	for x = 0, mazeWidth + 1 do
		local column = {}
		maze[ x ]    = column
		for y = 0, mazeHeight + 1 do
			column[ y ] = freshCell( "empty" )
		end
	end

	-- Force the border
	for x = 0, mazeWidth + 1 do
		maze[ x ][ 0 ]              = freshCell( "empty" )
		maze[ x ][ mazeHeight + 1 ] = freshCell( "empty" )
	end
	for y = 0, mazeHeight + 1 do
		maze[ 0 ][ y ]             = freshCell( "empty" )
		maze[ mazeWidth + 1 ][ y ] = freshCell( "empty" )
	end

	-- Create the maze
	local startX, startY = mazeCreate( levelMazeData[ 4 ], levelMazeData[ 5 ] )

	-- Draw maze
	local strokeSize = 1
	xOffset          = cellSize
	yOffset          = cellSize
	for x = 0, mazeWidth + 1 do
		for y = 0, mazeHeight + 1 do
			local cell      = maze[ x ][ y ]
			local cellImage = tostring( cell[ 1 ] ) .. tostring( cell[ 2 ] ) .. tostring( cell[ 3 ] ) .. tostring( cell[ 4 ] )
			local image     = display.newImageRect( "gfx/tiles/" .. cellImage .. ".png", cellSize, cellSize )
			image:setReferencePoint( display.TopLeftReferencePoint )
			gameGroup:insert( image )
			image.x         = x * cellSize + xOffset
			image.y         = y * cellSize + yOffset
		end
	end

	-- Create end spot
	local endSize      = cellSize - 4
	local endCell      = display.newRect( gameGroup, 0, 0, endSize, endSize)
	endCell:setFillColor( 0, 127, 0 )
	endCell.x          = math.floor( ( endX + 0.5 ) * cellSize ) + xOffset
	endCell.y          = math.floor( ( endY + 0.5 ) * cellSize ) + yOffset
	
	-- Create player
	local playerSize   = cellSize - 4
	player             = display.newRect( gameGroup, 0, 0, playerSize, playerSize )
	player:setFillColor( 255, 0, 127 )
	positionPlayer( startX, startY, true )

	-- You can start, so get a move on!
	showInfo()
	canPlay = true

end
function deleteMaze()

	gameGroup:removeSelf()
	maze = nil

end
function completeMaze()

	canPlay                       = false
	globals.levels[ level ].moves = levelMoves

	-- Calculate all moves so far
	local allMoves = 0
	for i = 1, level do
		allMoves = allMoves + globals.levels[ i ].moves
	end
	globals.moves = allMoves

	-- Have you completed the game?
	if level == 10 then
		
		-- Is this a new best score
		local newHighScore = true
		local bestMoves    = settings.get( "bestMoves" )
		if bestMoves and bestMoves <= allMoves then newHighScore = false ; end

		-- Well?
		if newHighScore == true then
			settings.set( "bestMoves", allMoves, true )
					
			-- Pop up an alert confirming
			native.showAlert(
				"CONGRATS",
				"New high score of just " .. tostring( allMoves ) .. " moves. Wayhey!", 
				{ "OK" },
				function()
				
					-- Back to menu we go, how anti-climactic
					storyboard.gotoScene( "code.menu", globals.sbFade )
				end
			)
		else
		
			-- Back to menu we go, how anti-climactic
			storyboard.gotoScene( "code.menu", globals.sbFade )
		end
	else

		-- Calculate new seed
		seed = seed * ( level * levelMoves )
		createMaze( level + 1, seed )
	end 

end

function showInfo()

	movesText.text = "MOVES: " .. tostring( levelMoves ) .. "/" .. tostring( globals.moves + levelMoves ) .. "\nLEVEL: " .. tostring( level ) .. "\nSEED: " .. tostring( seed )

end

--------------------------------------------------------------
-- MAZE GENERATION -------------------------------------------

function mazeCreate( bias, percentageFilled )

	print( "BIAS", bias, percentageFilled )
	
	-- Set random value
	math.randomseed( seed )

	-- Fill in maze with some 'random' blocks to begin with
	mazeFillRandomly( percentageFilled )

	-- Pick a random start from the left of the maze
	local startY                 = math.random( 1, mazeHeight )
	local startX                 = 0
	maze[ startX ][ startY ]     = freshCell( "empty" )
	maze[ startX +  1][ startY ] = freshCell( "empty" )

	-- Create random exit at right of maze
	endX                     = mazeWidth + 1
	endY                     = math.random( 1, mazeHeight )
	maze[ endX ][ endY ]     = freshCell( "empty" )
	maze[ endX -  1][ endY ] = freshCell( "empty" )

	-- Join the cells and make the paths
	mazeCreateJoinCells( startX, startY, 4 )
  	mazeCreateDefaultIterate( startX + 1, startY, bias, false )
	mazeCreateJoinCells( endX, endY, 2 )

	return startX, startY

end
function mazeFillRandomly( percentageFilled )

	cellsToFill = math.floor( mazeWidth * mazeHeight * percentageFilled / 100 )
	for i = 1, cellsToFill do
		local x        = math.random( 1, mazeWidth )
		local y        = math.random( 1, mazeHeight )
		maze[ x ][ y ] = freshCell( "ignored" )
	end

end
function mazeCreateJoinCells( x, y, dir )

	-- Marks this cell as heading in the dir
	maze[ x ][ y ][ dir ] = 1
  
	-- Marks the joined cell's heading back towards original
	local oppositeDir = oppositeDirs[ dir ]
	if dir == 1 then     maze[ x ][ y - 1 ][ oppositeDir ] = 1
    elseif dir == 2 then maze[ x - 1 ][ y ][ oppositeDir ] = 1
    elseif dir == 3 then maze[ x ][ y + 1 ][ oppositeDir ] = 1
    elseif dir == 4 then maze[ x + 1 ][ y ][ oppositeDir ] = 1 ; end

end
function mazeCreateDefaultIterate( x, y, bias, prevDir )

	-- Keep looping until the map is full
	while true do
	
		-- Check there are neighbours available
		local unusedNeighbours = mazeCreateUnusedNeighbours( x, y )
		if #unusedNeighbours == 0 then break ; end
		
		-- Allow for bias
		if bias > 0 then mazeCreateBiasedNeighbours( bias, unusedNeighbours, prevDir ) ; end
		
		-- Pick a random exit
		local newDir = unusedNeighbours[ math.random( #unusedNeighbours ) ]
		
		-- Join them
		mazeCreateJoinCells( x, y, newDir )
		
		-- Get new direction
		local newX = x
		local newY = y
		if newDir == 1 then     newY = newY - 1
		elseif newDir == 2 then newX = newX - 1
		elseif newDir == 3 then newY = newY + 1
		elseif newDir == 4 then newX = newX + 1 ; end

		-- Iterate
		mazeCreateDefaultIterate( newX, newY, bias, newDir )
	end

end
function mazeCreateUnusedNeighbours( x, y )

	local unusedNeighbours = {}
	if y > 1 then
		if isCellEmpty( x, y - 1 ) then unusedNeighbours[ #unusedNeighbours + 1 ] = 1 ; end
	end
	if x > 1 then
		if isCellEmpty( x - 1, y ) then unusedNeighbours[ #unusedNeighbours + 1 ] = 2 ; end
	end
	if y < mazeHeight then
		if isCellEmpty( x, y + 1 ) then unusedNeighbours[ #unusedNeighbours + 1 ] = 3 ; end
	end
	if x < mazeWidth then
		if isCellEmpty( x + 1, y ) then unusedNeighbours[ #unusedNeighbours + 1 ] = 4 ; end
	end
  
  	return unusedNeighbours

end
function mazeCreateBiasedNeighbours( bias, unusedNeighbours, prevDir )

	-- Check the previous dir is a possibility
	local dirFound = false
	for i = 1, #unusedNeighbours do
		if unusedNeighbours[ i ] == prevDir then
			dirFound = true
			break
		end
	end
	if dirFound == false then return ; end
	
	-- Insert additional biases
	for i = 1, bias do
		unusedNeighbours[ #unusedNeighbours + 1 ] = prevDir
	end
	
end

function freshCell( cellType )

	if cellType == "empty" then       return { 0, 0, 0, 0 }
	elseif cellType == "ignored" then return { 2, 2, 2, 2 }
	else                              return { 1, 1, 1, 1 } ; end
	
end
function isCellEmpty( x, y )

	local cell    = maze[ x ][ y ]
	local isEmpty = true
	for i = 1, 4 do
		if cell[ i ] ~= 0 then
			isEmpty = false
			break
		end
	end

	return isEmpty
	
end

--------------------------------------------------------------
-- STORYBOARD ------------------------------------------------

function scene:createScene( event )

	sceneGroup = self.view
	gameGroup  = display.newGroup()
	sceneGroup:insert( gameGroup )
	uiGroup    = display.newGroup()
	sceneGroup:insert( uiGroup )
	
	-- Create a button
	local button = widget.newButton{
		label = "MENU",
		width = 100,
		height = 40,
		onPress = function()
			storyboard.gotoScene( "code.menu", globals.sbFade )
		end,
	}
	uiGroup:insert( button )
	button:setReferencePoint( display.TopLeftReference )
	button.x = globals.screenWidth - 110
	button.y = 10

	-- Set up direction buttons
	local buttons = {
		{ 2, "<", globals.screenWidth - 60, globals.screenHeight - 60 }, 
		{ 4, ">", globals.screenWidth - 5, globals.screenHeight - 60 }, 
		{ 1, "/\\", globals.screenWidth - 30, globals.screenHeight - 115 }, 
		{ 3, "\\/", globals.screenWidth - 30, globals.screenHeight - 5 }, 
	}
	for i = 1, #buttons do
		local data   = buttons[ i ]
		local button = widget.newButton{
			label     = data[ 2 ],
			width     = 50,
			height    = 50,
			onRelease = function() moveDir( data[ 1 ] ) ; end,
		}
		uiGroup:insert( button )
		button:setReferencePoint( display.BottomRightReferencePoint )
		button.x     = data[ 3 ]
		button.y     = data[ 4 ]
		button.alpha = 0.5
	end

	-- Create moves text
	movesText   = display.newText( uiGroup, "", 0, 0, 100, 0, nil, 12 )
	showInfo()
	movesText.x = globals.screenWidth - 55
	movesText.y = 100
	
	-- Create the maze
	createMaze( 1, 1 )

end
function scene:didExitScene( event )

	storyboard.purgeScene( "code.game" )

end

--------------------------------------------------------------
-- STORYBOARD LISTENERS --------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "didExitScene", scene )

--------------------------------------------------------------
-- RETURN STORYBOARD OBJECT ----------------------------------

return scene
