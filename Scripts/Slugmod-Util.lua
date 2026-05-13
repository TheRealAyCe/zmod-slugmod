flaggedSongs = {}

reloadFlaggedSongs = function()
	flaggedSongs = {}
	
	local filename = "Save/LocalProfiles/flagged_songs.txt"
	
	local allFlaggedSongs = split("\n", lua.ReadFile(filename) or "")
	
	local numSongs = 0
	for i,line in ipairs(allFlaggedSongs) do
		if string.len(line) > 0 then
			flaggedSongs[line] = true
			numSongs = numSongs + 1
		end
	end
	
	Trace("Loaded "..numSongs.." flagged songs")
	if SCREENMAN then
		SCREENMAN:SystemMessage("Loaded "..numSongs.." flagged songs")
	end
end

reloadFlaggedSongs();


local function getSongId(song)
	local songDir = song:GetSongDir()
	local arr = split("/", songDir)
	return arr[3] .. "/" .. arr[4]
end

local function writeFlaggedSongs()
	-- put all songs into array and sort
	local allSongs = {}
	for k,v in pairs(flaggedSongs) do
		--Trace("song "..k)
		--SCREENMAN:SystemMessage("song "..k)
		table.insert(allSongs, k)
	end
	
	Trace("Saving "..#allSongs.." flagged songs")
	
	table.sort(allSongs)
	
	-- write file
	local filename = "Save/LocalProfiles/flagged_songs.txt"
	
	local file = RageFileUtil.CreateRageFile()
	if not file:Open(filename, 2) then
		Warn("**Could not open '" .. path .. "' to write flagged songs.**")
		return
	end
	
	for k, s in ipairs(allSongs) do
		file:Write(s.."\n")
	end
	
	file:Close()
	file:destroy()
end

isFlaggedSong = function(song)
	if not song then
		-- invalid song
		return false
	end
	
	return flaggedSongs[getSongId(song)] or false
end

setFlaggedSong = function(song, flagged)
	if not song then
		-- invalid song
		return
	end
	
	local songId = getSongId(song)
	
	if (flaggedSongs[songId] or false) == flagged then
		-- flag already applied (or not present)
		SCREENMAN:SystemMessage("Setting song flag: "..songId.." -> "..tostring(flagged).." (no change)")
		return
	end
	
    SOUND:PlayOnce(THEME:GetPathS("", flagged and "_flagged.ogg" or "Common invalid.ogg"))
	
	SCREENMAN:SystemMessage("Setting song flag: "..songId.." -> "..tostring(flagged).." (+write)")
	
	-- if flagged, set true, otherwise set nil (delete)
	flaggedSongs[songId] = flagged and true or nil
	
	--SCREENMAN:SystemMessage("Is flagged: "..tostring(flaggedSongs[songId]))
	
	writeFlaggedSongs()
end
