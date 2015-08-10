CloneClass(HUDChat)
--To add more voices go down to the function addvoices you'll see alot of self:addvoice.
local s = { --Here you can change the voice commands make sure to change only what's inside the : " ".  
	voicecommand = "p", --Don't put spaces.
    woop = "woop", 
    woop2 = "woop2", 
    whistle = "whistle",
    cloacker_burn = "clk burn",
    dozer_shit = "dozer shit",
    taser_burn = "tsr burn",
    taser_tasered = "tsr tasered",
    civ_burn = "civ burn",
    dozer_entrance = "dozer",
    beep = "beep",
    bain_drill = "thermal",
    bile_death = "bile dead",
    civ_call = "911",
    civ_shout = "ahh",
    boom = "boom",
    cloacker_taunt = "clk taunt",
    shield_knock = "shield",
    dozer_taunt = "dozer taunt",
    drill_jammed = "drill jam",
    pager_answer = "pager",
    bot_ok = "ok",
    unmask = "lets go",
    hands_up = "hands up",
    on_your_knees = "down",
    followme = "follow",
    guard_spot = "guard",
    camera_spot = "camera",
    move_faster = "move",
    inspire_faster = "faster",
    help_me = "help", 
    picking_lock = "lock",
    dozer_killed = "dozer killed",
    ohshit = "shit",
    ohfuck = "fuck",
    found_gage = "gage",
    gogo = "gogo",
    cuffs_on = "cuffs",
    helicopter = "heli",
    loot_bag = "bag",
    bain_last = "last",
    bain_custody = "custody",
    bain_now = "now",
    bain1 = "bain",
    bain2 = "bain2",
    bain2 = "bain2",
    wasting_coke = "bain coke",
    secs30 = "30",
    secs20 = "20",
    secs40 = "40",
    secs60 = "60",
    com_1 = "com",
    com_2 = "com2",
    com_3 = "com3",
    com_4 = "com4",
    com_5 = "com5",
    bain_yes = "yes",
    bain_move = "movemove",
    bain_no = "no",
    bain_fuckyeah = "fuck yeah",
    cop_help = "help2",
}
local characters = {"a","b","c","d","l","m","n","o","p","q","r"}

function HUDChat:send( msg1, msg2, color )
	return managers.chat:_receive_message(ChatManager.GAME, msg1 , msg2, color and color or Color.white )
end
function HUDChat:PlayID(soundid)
  local in_custody = managers.trade:is_peer_in_custody(managers.network:session():local_peer():id())
  if not in_custody and soundid ~= nil then
   return managers.player:player_unit():sound():say(soundid, true, true)
  end
end

function HUDChat:addvoice( name, soundid, char )
	local message = self._input_panel:child("input_text"):text()
	local msg = string.gsub(string.lower(message), "!"..s.voicecommand.." ", "")
  local msg_nospace = string.gsub(msg, "%s+", "") 
	if msg == name then 
		self:PlayID(soundid)
    elseif char == true and msg == name..string.gsub(msg, name, "") or msg == string.gsub(msg, name, "")..name then
      self:PlayID(soundid..string.gsub(msg_nospace, name, ""))
    end
end
function HUDChat:addvoices()
  --How to add :

--                 Name        soundid               --Multicharacter
--self:addvoice("Examplename" ,"cloaker_detect_mono", false)   

--If Mutli character(for sounds like bain last announce or custody add true after sound id in the chat you type a or b or c or d(characters ids)
-- after that the sound will play so for example we put self:addvoice("lol" ,"play_ban_i20", true) if we type in the chat !p lol a or !p a lol bain will say dallas you're the last. or if b he will say chains) 
--All characters ids : a = dallas,b = chains,c = wolf,d = hoxton,l = houston,m = wick,n = clover,o = dragan,p = jacket,q = bonnie,r = sokol  
       self:addvoice(s.bain_last ,"play_ban_i20", true)   
       self:addvoice(s.bain_custody ,"Play_ban_h11", true)   
       self:addvoice(s.woop, "cloaker_detect_mono") 
       self:addvoice(s.whistle, "whistling_attention")               
       self:addvoice(s.woop2, "cloaker_detect_christmas_mono")
       self:addvoice(s.cloacker_burn ,"clk_burndeath")        
       self:addvoice(s.dozer_shit ,"bdz_visor_lost") 
       self:addvoice(s.taser_burn ,"tsr_burndeath")  
       self:addvoice(s.taser_tasered ,"tsr_tasered")   
       self:addvoice(s.civ_burn ,"cm1_burnhurt")  
       self:addvoice(s.dozer_entrance ,"bdz_entrance")  
       self:addvoice(s.beep,"swatturret_alert") 
       self:addvoice(s.bile_death ,"Play_plt_a64")
       self:addvoice(s.civ_call ,"cm1_911_call")
       self:addvoice(s.civ_shout ,"cm1_a01x_any")    
       self:addvoice(s.boom ,"swat_explosion")    
       self:addvoice(s.shield_knock ,"shield_identification") 
       self:addvoice(s.cloacker_taunt ,"cloaker_taunt_after_assault")    
       self:addvoice(s.dozer_taunt ,"bdz_post_kill_taunt")    
       self:addvoice(s.com_1 ,"Play_com_hm1_01")                     
       self:addvoice(s.com_2 ,"Play_com_hm1_02")                    
       self:addvoice(s.com_3 ,"Play_com_hm1_03")                              
       self:addvoice(s.com_4 ,"Play_com_hm1_04")                  
       self:addvoice(s.cop_help ,"hlp")  
      --Heister lines  
       self:addvoice(s.drill_jammed ,"d02x_sin")   
       self:addvoice(s.pager_answer ,"dsp_radio_msging_1")  
       self:addvoice(s.bot_ok ,"r01x_sin")         
       self:addvoice(s.unmask ,"a01x_any")            
       self:addvoice(s.hands_up ,"l01x_sin")         
       self:addvoice(s.on_your_knees,"l02x_sin")   
       self:addvoice(s.followme ,"f38_any") 
       self:addvoice(s.guard_spot ,"f37_any")   
       self:addvoice(s.camera_spot ,"f39_any") 
       self:addvoice(s.move_faster ,"f40_any") 
       self:addvoice(s.inspire_faster ,"g18") 
       self:addvoice(s.help_me,"p45") 
       self:addvoice(s.picking_lock ,"p29")                
       self:addvoice(s.dozer_killed ,"g30")         
       self:addvoice(s.ohshit ,"g60")               
       self:addvoice(s.ohfuck ,"g29")                  
       self:addvoice(s.found_gage ,"g92")                  
       self:addvoice(s.gogo ,"p12")                 
       self:addvoice(s.cuffs_on ,"l03x_sin")                 
       self:addvoice(s.loot_bag ,"p27")                  
       self:addvoice(s.helicopter ,"p41")
       --BAIN           
       self:addvoice(s.bain_drill ,"Play_pln_branchbank_stage1_83")                    
       self:addvoice(s.bain1 ,"gen_ban_b10")                                  
       self:addvoice(s.secs30,"Play_pln_polin_02")                                     
       self:addvoice(s.secs20 ,"Play_pln_polin_01")                  
       self:addvoice(s.secs40 ,"Play_pln_polin_03")       
       self:addvoice(s.secs60 ,"Play_pln_polin_04")   
       self:addvoice(s.bain_now ,"gen_ban_b02c")
       self:addvoice(s.wasting_coke ,"Play_pln_hm2_20")
       self:addvoice(s.bain_no ,"play_pln_gen_dir_07")              
       self:addvoice(s.bain_yes ,"play_pln_gen_dir_08")
       self:addvoice(s.bain_move ,"play_pln_gen_urg_01")              
       self:addvoice(s.bain_fuckyeah,"Play_pln_pdsg_01") 
end
function HUDChat:check(table, sound)
    if string.match(sound,s.bain_last) or string.match(sound,s.bain_custody) then return true end 
    for k, v in pairs(table) do
        if v == sound then return k end
    end
    return false
end
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function HUDChat:enter_key_callback()
  local text = self._input_panel:child("input_text")
  local message = text:text()
  local in_custody = managers.trade:is_peer_in_custody(managers.network:session():local_peer():id())
  if string.len(message) > 0 then
    local u_name = managers.network.account:username()
    if not string.starts(message,"!")  then
    managers.chat:send_message(self._channel_id, u_name or "Offline", message)
    end
  end
  if string.starts(string.lower(message),"!id") then 
   local msg = string.gsub(string.lower(message), "!id", "")
   local msg_nospace = string.gsub(msg, "%s+", "") 
   if string.len(msg_nospace) > 0 then --Play sound id.
     self:send("Playing id", string.gsub(msg_nospace, "id",""), HoloBlue) 
     self:PlayID(string.gsub(msg_nospace, "!id",""))
   else 
    self:send("Info", "Type !id and then the sound id you want to play(some of them are heist specific)", HoloGreen) 
    end
  end
  if string.starts(string.lower(message),"!say") then 
  managers.hud:show_hint{
    text = string.gsub(message, "!say ", ""),
    time = 3,
    event = 0,
  }
  end  
  if string.starts(string.lower(message),"!"..s.voicecommand) then
   local msg = string.gsub(string.lower(message), "!"..s.voicecommand.." ", "")
   local msg_nospace = string.gsub(msg, "%s+", "") 

   if msg == "" then
       self:send("Info", "Type !"..s.voicecommand.." and then type a voice you want to play full list in HudChat.lua", HoloGreen)  
   elseif in_custody then
       self:send(string.upper("Error"), "you must be alive to use voice commands!", HoloRed) 
   else  
       self:addvoices()
  end
end
  text:set_text("")
  text:set_selection(0, 0)
  managers.hud:set_chat_focus(false)
end

