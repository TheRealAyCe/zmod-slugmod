t = Def.ActorFrame {}
 
t[#t+1] = Def.Sprite {    
  Texture="NOATH_Gourmand 5x3.png",

  Frame0000=1, Delay0000=0.133333333,
  Frame0001=2, Delay0001=0.133333333,
  Frame0002=3, Delay0002=0.133333333,
  Frame0003=4, Delay0003=0.133333333,
  Frame0004=5, Delay0004=0.133333333,
  Frame0005=6, Delay0005=0.133333333,
  Frame0006=7, Delay0006=0.133333333,
  Frame0007=8, Delay0007=0.133333333,
  Frame0008=9, Delay0008=0.133333333,
  Frame0009=10,Delay0009=0.133333333,
  Frame0010=11,Delay0010=0.133333333,
  Frame0011=12,Delay0011=0.133333333,
  Frame0012=13,Delay0012=0.133333333,
  Frame0013=14,Delay0013=0.133333333,
  Frame0014=0 ,Delay0014=0.133333333,

  OnCommand=function(self)
    self:effectclock("bgm")
    self:zoom(0.5)
  end  
}
 
return t