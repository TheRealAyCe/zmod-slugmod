
-----------------------
-- Custom UI fix to display song time instead of useless BPM in the top center
-----------------------

local totalseconds = -1
local player

-- find out which player has the longest (song length), that becomes the master player
-- usually both players have the same, but not necessarily!
local humanPlayers = GAMESTATE:GetHumanPlayers()
for humanPlayer in ivalues(humanPlayers) do
	local songLength = totalLengthSongOrCourse(humanPlayer) --at least 0
	if songLength > totalseconds then
		player = humanPlayer
		totalseconds = songLength
	end
end

local SongPosition = GAMESTATE:GetPlayerState(player):GetSongPosition()

local rate = SL.Global.ActiveModifiers.MusicRate

local style = GAMESTATE:GetCurrentStyle():GetName()

-- -----------------------------------------------------------------------
-- reference to the BitmapText actor that will display remaining time
local remBMT

-- -----------------------------------------------------------------------
-- reference to the function we'll use to format long-form seconds (like 208.64382946)
-- to something presentable (like 3:28)
local fmt = nil

-- how long this song or course is, in seconds
-- we'll use this to choose a formatting function

-- choose the appropriate time-to-string formatting function

-- shorter than 10 minutes (M:SS)
if totalseconds < 600 then
	fmt = SecondsToMSS

-- at least 10 minutes, shorter than 1 hour (MM:SS)
elseif totalseconds >= 360 and totalseconds < 3600 then
	fmt = SecondsToMMSS

-- somewhere between 1 and 10 hours (H:MM:SS)
elseif totalseconds >= 3600 and totalseconds < 36000 then
	fmt = SecondsToHMMSS

-- 10 hours or longer (HH:MM:SS)
else
	fmt = SecondsToHHMMSS
end

-- -----------------------------------------------------------------------
-- In CourseMode, we want to show how far into the overall Course the player is,
-- but SongPosition:GetMusicSeconds() only gives us the current second into the current
-- song.  We'll need to track how long each song is, and add (cumulatively-increasing)
-- seconds to SongPosition:GetMusicSeconds() for each song past the first.
--
-- Here, set up a table with cumulative seconds-per-Song for the overall Course.
local cumulative_seconds = {}
if GAMESTATE:IsCourseMode() then
	cumulative_seconds = courseLengthBySong(player)
end

-- use seconds_offset in CourseMode to initialize timer text
-- for songs after the first
-- (i.e. by the start of the 4th song, 6 minutes have already elapsed)
--
-- seconds_offset is scoped to this entire file and updated in
-- CurrentSongChangedMessageCommand so it can be referenced
-- from within Update()
local seconds_offset = 0





-- -----------------------------------------------------------------------

-- -----------------------------------------------------------------------


-- -----------------------------------------------------------------------
-- this Update function will be called every frame (I think)
-- it's potentially dangerous for framerate

local Update = function(af, delta)

	-- SongPosition:GetMusicSeconds() can be negative for a bit at
	-- the beginnging depending on how the stepartist set the offset
	-- don't show negative time; just use 0
	if SongPosition:GetMusicSeconds() < 0 then
		remBMT:settext(fmt(totalseconds - seconds_offset))
		return
	end

	remBMT:settext( fmt(clamp(totalseconds - seconds_offset - (SongPosition:GetMusicSeconds()/rate), 0, totalseconds)) )
end

-- -----------------------------------------------------------------------

local af = Def.ActorFrame{}

af.InitCommand=function(self)
	self:SetUpdateFunction(Update)


	self:xy(_screen.cx, 52)

end

af.CurrentSongChangedMessageCommand=function(self,params)
	-- GAMESTATE:GetCourseSongIndex() is 0-indexed, which we'll use to our advantage here
	-- since CurrentSongChanged is broadcast by the engine at the start of every song in
	-- a course, including the first.
	--
	-- So, when ScreenGameplay appears for the first song in the course, GAMESTATE:GetCourseSongIndex()
	-- will be 0, which won't index to anything in cumulative_seconds, which is what we want.
	--
	-- When the 2nd song appears, GAMESTATE:GetCourseSongIndex() will be 1, meaning we'll index
	-- cumulative_seconds[1] to get the first song's duration.
	--
	-- When the 3rd song appears, we'll index cumulative_seconds[2] to get (1st song + 2nd song)
	-- duration.  Etc.
	local course_index = GAMESTATE:GetCourseSongIndex()
	seconds_offset = cumulative_seconds[course_index] or 0
end

-- -----------------------------------------------------------------------
-- total time number
-- song duration in normal gameplay, overall course duration in CourseMode

af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
	InitCommand=function(self)
		self:x(-4)
		self:halign(1):vertalign(bottom)

		self:settext( fmt(totalseconds) )
		
		
		--self:xy(_screen.cx, 52):valign(1):zoom(1.33)
	end
}

-- total time label
-- "song" in normal gameplay, "course" in CourseMode
af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
	InitCommand=function(self)
		self:halign(0):vertalign(bottom)
		self:zoom(0.833)

		local s = GAMESTATE:IsCourseMode() and THEME:GetString("ScreenGameplay", "Course") or THEME:GetString("ScreenGameplay", "Song")
		self:settext( ("%s "):format(s) )
	end,
	OnCommand=function(self)
		--self:x(32 + (total_width-28))
		--self:y(20)
	end
}

-- -----------------------------------------------------------------------
-- remaining time number
af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
	InitCommand=function(self)
		remBMT = self
		self:xy(-4,20)
		self:halign(1):vertalign(bottom)
	end
}

-- remaining time label
af[#af+1] = LoadFont(ThemePrefs.Get("ThemeFont") .. " Normal")..{
	Text=("%s "):format( THEME:GetString("ScreenGameplay", "Remaining") ),
	InitCommand=function(self)
		self:xy(0,20)
		self:halign(0):vertalign(bottom)
		self:zoom(0.833)
	end
}

-- -----------------------------------------------------------------------

return af
