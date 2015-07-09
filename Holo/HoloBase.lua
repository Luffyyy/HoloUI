function ColorRGB(r ,g, b) --For lazy ppl
return Color(r/255 ,g/255 ,b/255)
end
HoloBlue = ColorRGB(0 ,150 ,255 )		  	 
HoloOrange = ColorRGB(255,165 ,0 )
HoloGreen = ColorRGB(0, 255, 20)	
HoloPink = ColorRGB(255, 105, 180)				 
HoloBlack = ColorRGB(0, 0, 0)		 		 
HoloGrey = ColorRGB(60, 60, 60)	
Darkblue = ColorRGB(10, 30, 125)	
HoloRed = ColorRGB(250, 0, 0)	
HoloYellow = ColorRGB(255, 200, 50)	
HoloWhite = ColorRGB(255, 255, 255)
HoloCyan = ColorRGB(0, 255, 240)
HoloPurple = ColorRGB(150, 0, 255)
SpringGreen = ColorRGB(0, 250, 154)
LightBlue = ColorRGB(173,216,230)


local clr = {
	HoloBlue,	  	 
	HoloOrange,
    HoloGreen,
	HoloPink,			 
	HoloBlack, 		 
	HoloGrey,	
	Darkblue,	
	HoloRed,
	HoloYellow, 
	HoloWhite,
	HoloCyan,
	HoloPurple,
	SpringGreen,
	LightBlue,
} 
--HoloHud Main Color	
Holo.options.Holo_color = Holo.options.Holo_color or 1
HoloColor = clr[Holo.options.Holo_color] 
local HoloColors = {
    HoloColor,
	HoloBlue,	  	 
	HoloOrange,
	HoloGreen,
	HoloPink,			 
	HoloBlack, 		 
	HoloGrey,	
	Darkblue,	
	HoloRed,
	HoloYellow, 
	HoloWhite,
	HoloCyan,
	HoloPurple,
	SpringGreen,
	LightBlue,
} 
local TextColors = {
	HoloWhite,	
	HoloBlack,	  	 	  
} 
HoloAlpha = Holo.options.MainAlpha
 
--Objective box color
	Holo.options.Obj_color = Holo.options.Obj_color or 1
	objective_box_color = HoloColors[Holo.options.Obj_color]
--Timer bg color
	Holo.options.Timerbg_color = Holo.options.Timerbg_color or 1
	Timerbg_color = HoloColors[Holo.options.Timerbg_color]
--AssaultBox
    --Assault box color
	Holo.options.Assault_color = Holo.options.Assault_color or 1
	Assault_color = HoloColors[Holo.options.Assault_color]
    --Hostage box color
	Holo.options.Hostage_color = Holo.options.Hostage_color or 1
	Hostage_color = HoloColors[Holo.options.Hostage_color]
    --No point of return box color
	Holo.options.Noreturn_color = Holo.options.Noreturn_color or 1
	Noreturn_color = HoloColors[Holo.options.Noreturn_color]	
    --Casing box color
	Holo.options.Casing_color = Holo.options.Casing_color or 1
	Casing_color = HoloColors[Holo.options.Casing_color]	
	
--HudTeammate
	--Selected weapon color
	Holo.options.Selectwep_color = Holo.options.Selectwep_color or 1
	Selectwep_color = HoloColors[Holo.options.Selectwep_color]
	--Pickups color
	Holo.options.Pickups_color = Holo.options.Pickups_color or 1
	Pickups_color = HoloColors[Holo.options.Pickups_color]
    --Equipments color
	Holo.options.Equipments_color = Holo.options.Equipments_color or 1
	Equipments_color = HoloColors[Holo.options.Equipments_color]
    --Equipments color
	Holo.options.Frame_color = Holo.options.Frame_color or 1
	HudFrame_color = HoloColors[Holo.options.Frame_color]
--Text colors
	--Health text color
	Holo.options.HealthNum_color = Holo.options.HealthNum_color or 1
	HealthNum_color = HoloColors[Holo.options.HealthNum_color]	
	--Stamina text color
	Holo.options.StaminaNum_color = Holo.options.StaminaNum_color or 1
	StaminaNum_color = HoloColors[Holo.options.StaminaNum_color]	
	--Objective text color
	Holo.options.Objective_text = Holo.options.Objective_text or 1
	Objective_text_color = TextColors[Holo.options.Objective_text]
	--Assault text color
	Holo.options.Assault_text = Holo.options.Assault_text or 1
	Assault_text_color = TextColors[Holo.options.Assault_text]
	--Casing text color
	Holo.options.Casing_text = Holo.options.Casing_text or 1
	Casing_text_color = TextColors[Holo.options.Casing_text]
	--Hostage text color
	Holo.options.Hostage_text = Holo.options.Hostage_text or 1
	Hostage_text_color = TextColors[Holo.options.Hostage_text]
	--Hostage text color
	Holo.options.Noreturn_text = Holo.options.Noreturn_text or 1
	Noreturn_text_color = TextColors[Holo.options.Noreturn_text]
	--Timer text color
	Holo.options.Timer_text = Holo.options.Timer_text or 1
	Timer_text_color = TextColors[Holo.options.Timer_text]
	StaminaSize = 48
	log("HoloHud : Colors are loaded.")
	