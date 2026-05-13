
local af = Def.ActorFrame {
    Def.Sprite{
        InitCommand=function(self)
            self:animate(false):visible(false):x(70)
            self:Load( THEME:GetPathG("", "flagged.png") )
			self:zoomto(20,20)
            --self:diffuseshift():effectperiod(0.8)
        end,
        SetCommand=function(self, params)
            self:visible((params.Song and isFlaggedSong(params.Song) and true) or false)
        end,
    }
}

return af
