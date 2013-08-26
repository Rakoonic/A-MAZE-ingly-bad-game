--------------------------------------------------------------
-- SETTINGS LIBRARY ------------------------------------------

local fileio = require( "libs.fileio" )

-- Set up 
local class = {}

local file
local values        = {}
local defaultValues = { initialised = false }

--------------------------------------------------------------
-- FUNCTIONS -------------------------------------------------

function class.initialise( params )

	params        = params or {}
	defaultValues = params.defaultValues or defaultValues
	
	-- Settings file
	if params.file then file = params.file
	else                file = "settings.txt" ; end

	-- Load settings (or create if they don't exist)
	local rawData = fileio.loadData( file )
	if rawData == false then
		values = defaultValues

		-- Save the default data
		class.save()
	else
		local data = fileio.JSONDecode( rawData )
		if data then values = data
		else         values = defaultValues ; end
	end

	-- Reset values
	if params.resetValues then class.resetValues( values, params.resetValues ) ; end

end
function class.resetValues( startValues, resetValues )

	for k, v in pairs( resetValues ) do
		if type( v ) == "table" then
			if startValues[ k ] then class.resetValues( startValues[ k ], v )
			else                     startValues[ k ] = v ; end
		else
			startValues[ k ] = v
		end
	end

end

function class.save()

	-- Convert to JSON and save
	local rawData = fileio.JSONEncode( values )
	local result  = fileio.saveData( file, rawData )

end

function class.get( value )

	if value then return values[ value ]
	else          return values ; end
	
end
function class.set( key, value, autoSave )

	values[ key ] = value
	if autoSave == true then class.save() ; end

end
function class.getSection( section, value )

	if value then return values[ section ][ value ]
	else          return values[ section ] ; end

end
function class.setSection( section, key, value, autoSave )

	values[ section ][ key ] = value
	if autoSave == true then class.save() ; end

end

--------------------------------------------------------------
-- RETURN CLASS DEFINITION -----------------------------------

return class
