-- Minetest 0.4.10+ mod: chat_anticurse
-- punish player for cursing by disconnecting them
--
--  Created in 2015 by Andrey. 
--  This mod is Free and Open Source Software, released under the LGPL 2.1 or later.
-- 
-- See README.txt for more information.

chat_anticurse = {}
chat_anticurse.simplemask = {}

-- Vulgar, crude harmful words in various languages.
-- I don't want to keep these words as cleartext in code, so they are stored like this.
local x1="a"
local x2="i"
local x3="u"
local x4="e"
local x5="o"
local y1="y"
local y2="и"
local y3="о"
local y4="е"
local y5="я"

chat_anticurse.simplemask = {
-- English
  " "..x1.."s" .. "s ",
  " d" .. ""..x2.."ck",
  " p"..x4.."n" .. "is",
  " p" .. ""..x3.."ssy",
  " h"..x5.."" .. "r".."ny ",
  " b"..x2.."" .. "tch ",
  " b"..x2.."" .. "tche",
  " s"..x4.."" .. "x",
  " f" .. ""..x3.."ck",
  x1.."rs"..x4.."h"..x5.."l"..x4.."",
  " c"..x3.."nt ",
  " f"..x1.."gg"..x5.."t",
  " f"..x1.."gg"..x5.."ts",
  " r"..x1.."p"..x4.."d",
  " f"..x1.."g",
  " "..x1.."n"..x1.."l",
  " sh"..x2.."t",

-- Russian
  " "..y4.."б" .. "а",
  " бл"..y5.."" .. " ",
  " ж" .. ""..y3.."п",
  " х" .. ""..y1.."й",
  " ч" .. "л"..y4.."н",
  " п"..y2.."" .. "зд",
  " в"..y3.."" .. "збуд",
  " в"..y3.."з" .. "б"..y1.."ж",
  " сп"..y4.."" .. "рм",
  " бл"..y5.."" .. "д",
  " бл"..y5.."" .. "ть",
  " с" .. ""..y4.."кс",

-- Spanish
  " p" .. x3 .. "t" .. x1,

-- Not really curse words, but trying to stop a specific behavior
  "porno",
  "porn",

-- Ugh..
  "fvuck",
  "sh!t",
  "@ss",
  "b!tch",

-- harmless word added for testing.
  " boogerpicker",
  " windowlicker",
}


chat_anticurse.check_message = function(name, message)
    local checkingmessage=string.lower( name.." "..message .." " )
	local uncensored = 0
    for i=1, #chat_anticurse.simplemask do
        if string.find(checkingmessage, chat_anticurse.simplemask[i], 1, true) ~=nil then
            uncensored = 2
            break
        end
    end
    
    --additional checks
    if 
        string.find(checkingmessage, " c"..x3.."" .. "m ", 1, true) ~=nil and 
        not (string.find(checkingmessage, " c"..x3.."" .. "m " .. "se", 1, true) ~=nil) and
        not (string.find(checkingmessage, " c"..x3.."" .. "m " .. "to", 1, true) ~=nil)
    then
        uncensored = 2
    end
    return uncensored
end

local kick_msg = "Inappropriate words used in public chat."

minetest.register_on_chat_message(function(name, message)
    local uncensored = chat_anticurse.check_message(name, message)

    if uncensored == 1 then
        minetest.kick_player(name, "Hey! Was there a bad word?")
        minetest.log("action", "Player "..name.." warned for cursing. Chat:"..message)
        return true
    end

    if uncensored == 2 then
        minetest.kick_player(name, kick_msg)
        minetest.chat_send_all("Player <"..name.."> warned for cursing" )
        minetest.log("action", "Player "..name.." warned for cursing. Chat:"..message)
        return true
    end

end)

if minetest.chatcommands["me"] then
    local old_command = minetest.chatcommands["me"].func
    minetest.chatcommands["me"].func = function(name, param)
        local uncensored = chat_anticurse.check_message(name, param)

        if uncensored == 1 then
            minetest.kick_player(name, "Hey! Was there a bad word?")
            minetest.log("action", "Player "..name.." warned for cursing. Msg:"..param)
            return
        end

        if uncensored == 2 then
            minetest.kick_player(name, kick_msg)
            minetest.chat_send_all("Player <"..name.."> warned for cursing" )
            minetest.log("action", "Player "..name.." warned for cursing. Me:"..param)
            return
        end
        
        return old_command(name, param)
    end
end

if minetest.chatcommands["msg"] then
    local old_command = minetest.chatcommands["msg"].func
    minetest.chatcommands["msg"].func = function(name, param)
        local uncensored = chat_anticurse.check_message(name, param)

        if uncensored == 1 then
            minetest.kick_player(name, "Hey! Was there a bad word?")
            minetest.log("action", "Player "..name.." warned for cursing. Msg:"..param)
            return
        end

        if uncensored == 2 then
            minetest.kick_player(name, kick_msg)
            minetest.chat_send_all("Player <"..name.."> warned for cursing" )
            minetest.log("action", "Player "..name.." warned for cursing. Msg:"..param)
            return
        end
        
        return old_command(name, param)
    end
end
