
--------------------------------------------------------------
-- PROTOTYPES AND LOCAL VARIABLES ----------------------------

local JSON = require "json"

local class = {}

--------------------------------------------------------------
-- FILE FUNCTIONS --------------------------------------------

-- Encode table to JSON string
function class.JSONEncode( data )

	return JSON.encode(data)

end

-- Decode JSON string to table
function class.JSONDecode( data )

	return JSON.decode(data)

end

-- Save data to a file
function class.saveData( filePath, data )

	-- Save file
	local file = io.open( system.pathForFile( filePath, system.DocumentsDirectory ), "w" )
	file:write(data)
	io.close( file )
	
end

-- Load data from a file, returning a table
function class.loadData( filePath, directory )	

	-- Get file path and check it exists
	local fullPath = system.pathForFile( filePath, class.getDirectory( directory ) )
	if fullPath == nil then return false ; end

	-- Load file
	local file = io.open( fullPath, "r" )		
	if file then
		local data = file:read( "*a" )
		io.close( file )
		return data
	end

	-- Some sort of error, so return false
	return false
	
end

-- Get correct path
function class.getDirectory( directory )

	-- Allow for missed parameter
	if directory == nil then directory = "docs" ; end

	-- Return the correct path
	if directory == "docs" or directory == "documents" then return system.DocumentsDirectory
	else                                                    return system.ResourceDirectory ; end

end

-- Find if a file exists
function class.fileExists( filePath, directory )

	-- Does file exist?
    local results  = false
    local filePath = system.pathForFile( filePath, class.getDirectory( directory ) )
    if filePath then
    	local file = io.open( filePath, "r" )
		if file then
			file:close()
			results = true
		end
	end
	
    return results

end

-- Remove a file ( also checks if it exists)
function class.deleteFile( filePath, directory )

	-- Allow for missed parameter
	directory = directory or "docs"

	-- Get file path and check it exists
	local file, fullPath
	if directory == "docs" or directory == "documents" then fullPath = system.pathForFile( filePath, system.DocumentsDirectory )
	else                                                    fullPath = system.pathForFile( filePath, system.ResourceDirectory ) ; end
	
	-- Attempt to remove the file
	return os.remove( fullPath )
	
end

--------------------------------------------------------------
-- RETURN CLASS DEFINITION -----------------------------------

return class