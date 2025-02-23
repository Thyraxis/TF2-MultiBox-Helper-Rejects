-- Bot helper by __null
-- Forked by Dr_Coomer -- I want people to note that some comments were made by me, and some were made by the original author. I try to keep what is mine and what was by the original as coherent as possible, even if my rambalings themselfs are not. Such as this long useless comment. The unfinished medi gun and inventory manager is by the original auther and such. I am just possonate about multi-boxing, and when I found this lua I saw things that could be changed around or added, so that multiboxing can be easier and less of a slog of going to each client or computer and manually changing classes, loud out, or turning on and off features.

-- Settings:
-- Trigger symbol. All commands should start with this symbol.
local triggerSymbol = "!";

-- Process messages only from lobby owner.
local lobbyOwnerOnly = true;

-- Check if we want to me mic spamming or not.
local PlusVoiceRecord = true;

-- Keep the table of command arguments outside of all functions, so we can just jack this when ever we need anymore than a single argument.
local commandArgs;

-- WHO THE FUCK CARES ABOUT THIS SHIT 
local ZoomDistanceCheck = true;

-- Constants
local k_eTFPartyChatType_MemberChat = 1;
local steamid64Ident = 76561197960265728;
local partyChatEventName = "party_chat";
local playerJoinEventName = "player_spawn";
local availableClasses = { "scout", "soldier", "pyro", "demoman", "heavy", "engineer", "medic", "sniper", "spy", "random" };
local availableSpam = { "none", "branded", "custom" };
local availableSpamSecondsString = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60"} -- Made chatgpt write this lmao
local medigunTypedefs = {
    default = { 29, 211, 663, 796, 805, 885, 894, 903, 912, 961, 970 },
    quickfix = { 411 },
    kritz = { 35 }
};
 
-- Command container
local commands = {};
 
-- Found mediguns in inventory.
local foundMediguns = {
    default = -1,
    quickfix = -1,
    kritz = -1
};
 
-- Helper method that converts SteamID64 to SteamID3
local function SteamID64ToSteamID3(steamId64)
    return "[U:1:" .. steamId64 - steamid64Ident .. "]";
end
 
-- Thanks, LUA!
local function SplitString(input, separator)
    if separator == nil then
        separator = "%s";
    end

    local t = {};

    for str in string.gmatch(input, "([^" .. separator .. "]+)") do
            table.insert(t, str);
    end

    return t;
end
 
-- Helper that sends a message to party chat
local function Respond(input)
    client.Command("say_party " .. input, true);
end
 
-- Helper that checks if table contains a value
function Contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true;
        end
    end
 
    return false;
end

-- Game event processor
local function FireGameEvent(event)
    -- Validation.
    -- Checking if we've received a party_chat event.
    if event:GetName() ~= partyChatEventName then
        return;
    end
 
    -- Checking a message type. Should be k_eTFPartyChatType_MemberChat.
    if event:GetInt("type") ~= k_eTFPartyChatType_MemberChat then
        return;
    end
 
    local partyMessageText = event:GetString("text");
 
    -- Checking if message starts with a trigger symbol.
    if string.sub(partyMessageText, 1, 1) ~= triggerSymbol then
        return;
    end
 
    if lobbyOwnerOnly then
        -- Validating that message sender actually owns this lobby
        local senderId = SteamID64ToSteamID3(event:GetString("steamid"));
 
        if party.GetLeader() ~= senderId then
            return;
        end
    end
 
    -- Parsing the command
    local fullCommand = string.lower(string.sub(partyMessageText, 2, #partyMessageText));
    commandArgs = SplitString(fullCommand);
 
    -- Validating if we know this command
    local commandName = commandArgs[1];
    local commandCallback = commands[commandName];
 
    if commandCallback == nil then
        Respond("Unknown command [" .. commandName .. "]");
        return;
    end
 
    -- Removing command name
    table.remove(commandArgs, 1);
 
    -- Calling callback
    commandCallback(commandArgs);
end

-- ============= Commands' section ============= --
local function KillCommand(args)
    client.Command("kill", true);
    Respond("The HAEVY IS DEAD.");
end

local function ExplodeCommand(args)
    client.Command("explode", true);
    Respond("Kaboom!");
end

local function SwitchWeapon(args)
    local slotStr = args[1];

    if slotStr == nil then
        Respond("Usage: " .. triggerSymbol .. "slot <slot number>");
        return;
    end

    local slot = tonumber(slotStr);

    if slot == nil then
        Respond("Unknown slot [" .. slotStr .. "]. Available are 0-10.");
        return;
    end

    if slot < 0 or slot > 10 then
        Respond("Unknown slot [" .. slotStr .. "]. Available are 0-10.");
        return;
    end

    Respond("Switched weapon to slot [" .. slot .. "]");
    client.Command("slot" .. slot, true);
end

-- Follow bot switcher added by Dr_Coomer - Doctor_Coomer#4425
local function FollowBotSwitcher(args)
    local fbot = args[1];

    if fbot == nil then
        Respond("Usage: " .. triggerSymbol .. "fbot stop/friends/all");
        return;
    end

    fbot = string.lower(args[1]);

    if fbot == "stop" then
        Respond("Disabling followbot!");
        fbot = "none";
    end

    if fbot == "friends" then
        Respond("Following only friends!");
        fbot = "friends only";
    end

    if fbot == "all" then
        Respond("Following everyone!");
        fbot = "all players";
    end

    gui.SetValue("follow bot", fbot);
end

-- Loudout changer added by Dr_Coomer - Doctor_Coomer#4425
local function LoadoutChanger(args)
    local lout = args[1];

    if lout == nil then
        Respond("Usage: " .. triggerSymbol .. "lout A/B/C/D");
        return;
    end

    --Ahhhhh
    --More args, more checks, more statements.

    --5/27/2023 -- used the string class in lua to remove a third of the checks

    if string.lower(lout) == "a" then
        Respond("Switching to loudout A!");
        lout = "0";
    elseif lout == "1" then
        Respond("Switching to loudout A!");
        lout = "0"; --valve counts from zero. to make it user friendly since humans count from one, the args are between 1-4 and not 0-3
    end
    
    if string.lower(lout) == "b" then
        Respond("Switching to loutoud B!");
        lout = "1";
    elseif lout == "2" then
        Respond("Switching to loutoud B!");
        lout = "1"
    end

    if string.lower(lout) == "c" then
        Respond("Switching to loudout C!");
        lout = "2";
    elseif lout == "3" then
        Respond("Switching to loudout C!");
        lout = "2";
    end

    if string.lower(lout) == "d" then
        Respond("Switching to loudout D!");
        lout = "3";
    elseif lout == "4" then
        Respond("Switching to loudout D!");
        lout = "3";
    end

    client.Command("load_itempreset " .. lout, true);
end


-- Lobby Owner Only Toggle added by Dr_Coomer - Doctor_Coomer#4425
local function TogglelobbyOwnerOnly(args)
    local OwnerOnly = args[1]

    if OwnerOnly == nil then
        Respond("Usage: " .. triggerSymbol .. "OwnerOnly 1/0 or true/false");
        return;
    end

    if OwnerOnly == "1" then
        lobbyOwnerOnly = true;
    elseif string.lower(OwnerOnly) == "true" then
        lobbyOwnerOnly = true;
    end

    if OwnerOnly == "0" then
        lobbyOwnerOnly = false;
    elseif string.lower(OwnerOnly) == "false" then
        lobbyOwnerOnly = false;
    end

    Respond("Lobby Owner Only is now: " .. OwnerOnly)
end

-- Toggle ignore friends added by Dr_Coomer - Doctor_Coomer#4425
local function ToggleIgnoreFriends(args)
    local IgnoreFriends = args[1]

    if IgnoreFriends == nil then
        Respond("Usage: " .. triggerSymbol .. "IgnoreFriends 1/0 or true/false")
        return;
    end

    if IgnoreFriends == "1" then
        IgnoreFriends = 1;
    elseif string.lower(IgnoreFriends) == "true" then
        IgnoreFriends = 1;
    end
    
    if IgnoreFriends == "0" then
        IgnoreFriends = 0;
    elseif string.lower(IgnoreFriends) == "false" then
        IgnoreFriends = 0;
    end

    Respond("Ignore Steam Friends is now: " .. IgnoreFriends)
    gui.SetValue("Ignore Steam Friends", IgnoreFriends)
end

--[[
callbacks.Register("Draw", "SwitchCheckForlobbyOwnerOnlyBool", function()
    print(lobbyOwnerOnly); --making sure this even works lmao
end)
--]]

-- connect to servers via IP re implemented by Dr_Coomer - Doctor_Coomer#4425
--Context: There was a registered callback for a command called "connect" but there was no function for it. So, via the name of the registered callback, I added it how I thought he would have.
local function Connect(args)
    local Connect = args[1]

    Respond("Joining server " .. Connect .. "...")

    client.Command("connect " .. Connect, true);
end

-- Chatspam switcher added by Dr_Coomer - Doctor_Coomer#4425
local function cspam(args)
    local cspam = args[1];

    if cspam == nil then
        Respond("Usage: " .. triggerSymbol .. "cspam none/branded/custom")
        return;
    end

    local cspamSeconds = table.remove(commandArgs, 2)
    cspam = string.lower(args[1])

    --Code:
    --Readable: N
    --Works: Y
    --I hope no one can see how bad this is, oh wait...

    if not Contains(availableSpam, cspam) then
        if Contains(availableSpamSecondsString, cspam) then
            print("switching seconds")
            Respond("Chat spamming with " .. cspam .. " second interval")
            gui.SetValue("Chat Spam Interval (s)", tonumber(cspam, 10))
            return;
        end

        Respond("Unknown chatspam: [" .. cspam .. "]")
        return;

    end

    if Contains(availableSpam, cspam) then
        if Contains(availableSpamSecondsString, cspamSeconds) then
            print("switching both")
            gui.SetValue("Chat Spam Interval (s)", tonumber(cspamSeconds, 10)) --I hate this god damn "tonumber" function. Doesn't do as advertised. It needs a second argument called "base". Setting it anything over 10, then giving the seconds input anything over 9, will then force it to be to that number. Seconds 1-9 will work just fine, but if you type 10 it will be forced to that number. --mentally instane explination
            gui.SetValue("Chat spammer", cspam)
            Respond("Chat spamming " .. cspam .. " with " .. tostring(cspamSeconds) .. " second interval")
            return;
        end
    end

    if not Contains(availableSpamSecondsString, cspam) then
        if Contains(availableSpam, cspam) then
            print("switching spam")
            gui.SetValue("Chat spammer", cspam)
            Respond("Chat spamming " .. cspam)
            return;
        end
    end
end

-- MORE PASTING!!!! im just updating this old ass script to coomer's shit 
-- also if it gives out an error i will not fix it bc im not good with lua :skull:
-- update: its a sphere not cube like cathook :sob:
local IsInRange = false;
local closestplayer

local CurrentClosestX
local CurrentClosestY

local Distance = 1200; --best + from cathook (i only took the number)

local function zoomdistance(args)
    local zoomdistance = args[1]
    local zoomdistanceDistance = tonumber(table.remove(commandArgs, 2)) -- when !zd was triggerd it wil warn :skull: SO FUCKING RETARDED

    if zoomdistance == nil then
        Respond("Example: " .. triggerSymbol .. "zd on 650")
        return
    end

    zoomdistance = string.lower(args[1])

    if zoomdistance == "1" then
        ZoomDistanceCheck = true
    elseif zoomdistance == "on" then
        ZoomDistanceCheck = true
    end

    if zoomdistance == "0" then
        ZoomDistanceCheck = false
    elseif zoomdistance == "off" then
        ZoomDistanceCheck = false
    end

    if zoomdistanceDistance == nil then
        return;
    end

    Distance = zoomdistanceDistance

end

function DistanceFrom(x1, y1, x2, y2) --Maths :nerd:
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function GetPlayerLocations()

    local localp = entities.GetLocalPlayer()
    local players = entities.FindByClass("CTFPlayer")

    if localp == nil then
        return;
    end

    if ZoomDistanceCheck == false then
        return;
    end

    local localpOrigin = localp:GetAbsOrigin();
    local localX = localpOrigin.x
    local localY = localpOrigin.y

    for i, player in pairs(players) do

        --Skip players we don't want to enumerate
        if not player:IsAlive() then
            goto Ignore
        end

        if player:IsDormant() then
            goto Ignore
        end

        if player == localp then
            goto Ignore
        end
        if player:GetTeamNumber() == localp:GetTeamNumber() then
            goto Ignore
        end

        --Get the current enumerated player's vector2 from their vector3
        local Vector3Players = player:GetAbsOrigin()
        local X = Vector3Players.x
        local Y = Vector3Players.y

        localX = localpOrigin.x
        localY = localpOrigin.y

        if IsInRange == false then
            if DistanceFrom(localX, localY, X, Y) < Distance then --If we get someone that is in range then we save who they are and their vector2
                IsInRange = true;

                closestplayer = player;

                CurrentClosestX = closestplayer:GetAbsOrigin().x
                CurrentClosestY = closestplayer:GetAbsOrigin().y
            end
        end
        ::Ignore::
    end

    if IsInRange == true then

        CurrentClosestX = closestplayer:GetAbsOrigin().x
        CurrentClosestY = closestplayer:GetAbsOrigin().y

        if localp == nil or not localp:IsAlive() then
            IsInRange = false;
            return;
        end

        if closestplayer == nil then
            error("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nthis might never get hit\n\n\n\n\n\n\n\n\n\n\n")
            IsInRange = false;
            return;
        end

        if closestplayer:IsDormant() then
            IsInRange = false;
            return;
        end

        if not closestplayer:IsAlive() then --Check if the current closest player has died
            IsInRange = false;
            return;
        end

        if DistanceFrom(localX, localY, CurrentClosestX, CurrentClosestY) > Distance then --Check if they have left our range
            IsInRange = false;
            return;
        end
    end
end
--guess what guys? more pasting!
local stopScope = false;
local countUp = 0;
local function AutoUnZoom(cmd)
    local localp = entities.GetLocalPlayer();

    if (localp == nil or not localp:IsAlive()) then
        return;
    end

    if IsInRange == true then
        if not (localp:InCond( TFCond_Zoomed)) then 
            cmd.buttons = cmd.buttons | IN_ATTACK2 
        end
    elseif IsInRange == false then
        if stopScope == false then
            if (localp:InCond( TFCond_Zoomed)) then 
                cmd.buttons = cmd.buttons | IN_ATTACK2 
                stopScope = true;
            end
        end
    end


    --Wait logic
    if stopScope == true then
        countUp = countUp + 1;
        if countUp == 66 then 
            countUp = 0;
            stopScope = false;
        end
    end

end
-- im not adding auto vote kick in this. we already use another lua also https://bro.who-tf.ru/like_bro_who_are_you_dude_nn_stranger_anyway_heres_my_random_string/4InA92tj coomer pasting????? (upload.system link)
local function SwitchClass(args)
    local class = args[1];

    if class == nil then
        Respond("Usage: " .. triggerSymbol .. "class <" .. table.concat(availableClasses, ", ") .. ">");
        return;
    end

    class = string.lower(args[1]);

    if not Contains(availableClasses, class) then
        Respond("Unknown class [" .. class .. "]");
        return;
    end

    if class == "heavy" then
        -- Wtf Valve
        -- ^^ true true, I agree.
        class = "heavyweapons";
    end

    Respond("Switched to [" .. class .. "]");
    gui.SetValue("Class Auto-Pick", class); 
    client.Command("join_class " .. class, true);
end

local function Say(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say <text>");
        return;
    end

    client.Command("say " .. string.gsub(msg, "|", " "), true);
end

local function SayTeam(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say_team <text>");
        return;
    end
    
    client.Command("say_team " .. string.gsub(msg, "|", " "), true);
end

local function SayParty(args)
    local msg = args[1];

    if msg == nil then
        Respond("Usage: " .. triggerSymbol .. "say_party <text>");
        return;
    end

    client.Command("say_party " .. string.gsub(msg, "|", " "), true);
end

local function Taunt(args)
    client.Command("taunt", true);
end

local function TauntByName(args)
    local firstArg = args[1];

    if firstArg == nil then
        Respond("Usage: " .. triggerSymbol .. "tauntn <Full taunt name>.");
        Respond("For example: " .. triggerSymbol .. "tauntn Taunt: The Schadenfreude");
        return;
    end

    local fullTauntName = table.concat(args, " ");
    client.Command("taunt_by_name " .. fullTauntName, true);
end

-- Reworked Mic Spam, added by Dr_Coomer - Doctor_Coomer#4425 Shit
--local function Speak(args)
--    Respond("Listen to me!")
--    PlusVoiceRecord = true;
--    client.Command("+voicerecord", true)
--end

--local function Shutup(args)
 --   Respond("I'll shut up now...")
  --  PlusVoiceRecord = false;
  --  client.Command("-voicerecord", true)
--end

--local function MicSpam(event)

 --   if event:GetName() ~= playerJoinEventName then
 --       return;
 --   end

  --  if PlusVoiceRecord == true then
     --   client.Command("+voicerecord", true);
 --   end
--end

-- StoreMilk additions

local function Leave(args)
	gamecoordinator.AbandonMatch();

    --Fall back. If you are in a community server then AbandonMatch() doesn't work.
    client.Command("disconnect" ,true)
end

local function Console(args)
    local cmd = args[1];

    if cmd == nil then
        Respond("Usage: " .. triggerSymbol .. "console <text>");
        return;
    end

    client.Command(cmd, true);
end

callbacks.Register("Draw", "test", function ()
    
end)

-- its retarded
--local function duckspeedon(args)
--    Respond("Lets get duckin")
--    gui.SetValue("duck speed", 1);
--    client.Command("+duck", true);
--end
    
--local function duckspeedoff(args)
--    Respond("Alright no more duckin :sob:")
--    gui.SetValue("duck speed", 0);
--    client.Command("-duck", true);
--end


local isducked = false
local function ducktoggle(args)
    local duk = args[1]

    if duk == nil then
        Respond("Usage: on, off");
        return;
    end

    if duk == "on" then
        if isducked == false then
            Respond("Lets get duckin")
            gui.SetValue("duck speed", 1);
            client.Command("+duck", true);
            isducked = true
        elseif isducked == true then
            Respond("Already duckin my boy")
        end
    end
    if duk == "off" then
        if isducked == true then
            Respond("Alright no more duckin :sob:")
            gui.SetValue("duck speed", 0);
            client.Command("-duck", true);
        elseif isducked == false then
            Respond("i am already not ducking")
        end
    end
end

--local function turnonspin(args)
--    Respond("Lets get spining boys!")
--    gui.SetValue("Anti aim", 1);
--end

--local function turnoffspin(args)
--    Respond("No more spin boys :(")
--    gui.SetValue("Anti aim", 0);
--end

local spinnin = false
local function spintoggle(args)
    local spincom = args[1]

    if spincom == nil then
        Respond("Usage: on, off");
        return;
    end

    if spincom == "on" then
        if spinnin == false then
            Respond("Lets spin boys")
            gui.SetValue("anti aim", 1);
            spinnin = true
        elseif spinnin == true then
            Respond("Already Spinning")
        end
    end
    if spincom == "off" then
        if spinnin == true then
            Respond("Alright no more spin")
            gui.SetValue("anti aim", 0);
        elseif spinnin == false then
            Respond("i am already not spinning")
        end
    end
end

local madealiasmic = false
local onoroffaliasmic = false
local alreadyrunningmic = false
local function amic(args)
    local amictr = args[1];

    if amictr == nil then
        Respond("Alias: run (runs the alias), stop (stops the alias from running), on (sets alias to on), off (sets alias to off)");
        return;
    end

    if amictr == "run" then
        if madealiasmic == true then
           if alreadyrunningmic == false then
                client.Command("v", true);
                Respond("Alias: Running")
                alreadyrunningmic = true
           elseif alreadyrunningmic == true then
                Respond("Alias: Already running")
           end
        end
        if madealiasmic == false then
            Respond("Alias: mic wasnt created please create one by doing '!mic on' and it will create one it only changes alias")
        end
    end
    if amictr == "on" then
        if onoroffaliasmic == true then
            Respond("Alias: Already on")
        end
        if onoroffaliasmic == false then
            client.Command('alias v "+voicerecord;wait 100;v"', true);
            madealiasmic = true
            onoroffaliasmic = true
            Respond("Alias: Set from off to on!")
        end
    end
    if amictr == "off" then
        if onoroffaliasmic == false then
            Respond("Alias: Already off")
        end
        if onoroffaliasmic == true then
            client.Command('alias v "-voicerecord;wait 100;v"', true);
            madealiasmic = true
            onoroffaliasmic = false
            Respond("Alias: Set from on to off!")
        end
    end
    if amictr == "stop" then
        if madealiasmic == false then
            Respond("Alias: mic was not found")
        end
        if madealiasmic == true then
            client.Command('alias v "-voicerecord"', true);
            client.Command("-voicerecord", true);
            madealiasmic = false
            onoroffaliasmic = false
            alreadyrunningmic = false
            Respond("Alias: Stopped")
        end
    end
end

local function zoomtoggle(args)
    client.Command("+attack2;wait 20;-attack2", true);
    Respond("m2'd")
end

-- i was about to add navbot :skull:
-- ============= End of commands' section ============= --

-- This method is an inventory enumerator. Used to search for mediguns in the inventory.
-- guys its more pasting
local function newmap_event(event) --reset what ever data we want to reset when we switch maps
    if (event:GetName() == "game_newmap") then
        timer = 0 --unused shit
        IsInRange = false;
        CurrentClosestX = nil
        CurrentClosestY = nil
        closestplayer = nil;
    end
end

local function EnumerateInventory(item)
    -- Broken for now. Will fix later.

    local itemName = item:GetName();
    local itemDefIndex = item:GetDefIndex();

    if Contains(medigunTypedefs.default, itemDefIndex) then
        -- We found a default medigun.
        --foundMediguns.default = item:GetItemId();
        local id = item:GetItemId();
    end
    

    if Contains(medigunTypedefs.quickfix, itemDefIndex) then
        -- We found a quickfix.
        -- foundMediguns.quickfix = item:GetItemId();
        local id = item:GetItemId();
    end

    if Contains(medigunTypedefs.kritz, itemDefIndex) then
        -- We found a kritzkrieg.
        --foundMediguns.kritz = item:GetItemId();
        local id = item:GetItemId();
    end
end

-- Registers new command.
-- 'commandName' is a command name
-- 'callback' is a function that's called when command is executed.
local function RegisterCommand(commandName, callback)
    if commands[commandName] ~= nil then
        error("Command with name " .. commandName .. " was already registered!");
        return; -- just in case, idk if error() acts as an exception
    end

    commands[commandName] = callback;
end

-- Sets up command list and registers an event hook
local function Initialize()
    -- Registering commands

    -- Suicide commands
    RegisterCommand("kill", KillCommand);
    RegisterCommand("explode", ExplodeCommand);

    -- Switching things
    RegisterCommand("slot", SwitchWeapon);
    RegisterCommand("class", SwitchClass);

    -- Saying things
    RegisterCommand("say", Say);
    RegisterCommand("say_team", SayTeam);
    RegisterCommand("say_party", SayParty);

    -- Taunting
    RegisterCommand("taunt", Taunt);
    RegisterCommand("tauntn", TauntByName);

    -- Attacking
    --RegisterCommand("attack", Attack); even more useless than Connect

    -- Registering event callback
    callbacks.Register("FireGameEvent", FireGameEvent);

	-- StoreMilk additions
	RegisterCommand("leave", Leave);
	RegisterCommand("console", Console);

    -- Broken for now! Will fix later.
    --inventory.Enumerate(EnumerateInventory);

    -- [[ Stuff added by Dr_Coomer - Doctor_Coomer#4425 ]] --

    -- Switch Follow Bot
    RegisterCommand("fbot", FollowBotSwitcher);

    -- Switch Loadout
    RegisterCommand("lout", LoadoutChanger);

    -- Toggle Owner Only Mode
    RegisterCommand("owneronly", TogglelobbyOwnerOnly);

    -- Connect to server via IP
    RegisterCommand("connect", Connect);

    -- Toggle Ignore Friends
    RegisterCommand("ignorefriends", ToggleIgnoreFriends);

    -- Switch chat spam
    RegisterCommand("cspam", cspam);

    -- Mic Spam toggle
   -- RegisterCommand("speak", Speak);
--	RegisterCommand("shutup", Shutup);
   -- callbacks.Register("FireGameEvent", MicSpam);
    -- zoom distance
    RegisterCommand("zd", zoomdistance) --shorten this saved 2 bytes
    callbacks.Register("CreateMove", "GetPlayerLocations", GetPlayerLocations)

    --Auto unzoom
    callbacks.Register("CreateMove", "unzoom", AutoUnZoom)

    -- anyone would help me to stop thinking about becoming an idiot
    callbacks.Register("FireGameEvent", "newmap_event", newmap_event)
    -- [[ Stuff added by thyraxis ]] --

    -- Duck Speed
    --RegisterCommand("duckon", duckspeedon)
    --RegisterCommand("duckoff", duckspeedoff)
    RegisterCommand("duck", ducktoggle)
    -- Spin
    RegisterCommand("spinon", turnonspin)
    RegisterCommand("spinoff", turnoffspin)
    -- Mic
    RegisterCommand("mic", amic)
    -- zoom
    RegisterCommand("zoom", zoomtoggle)
end

Initialize();
