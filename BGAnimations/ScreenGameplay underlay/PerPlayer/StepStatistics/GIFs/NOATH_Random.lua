local GIFs = {"Artificer","Gourmand","Hunter","Inv","Monk","Nightcat","Rivulet","Saint","Spearmaster","Survivor"}
local rand = "NOATH_"..GIFs[math.random(1,#GIFs)]..".lua"

t = Def.ActorFrame {
	LoadActor(rand)
}

return t