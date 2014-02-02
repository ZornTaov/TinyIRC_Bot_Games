--
-- TinyBot
-- (c) Copyright 2004 Tom Bampton
--     All Rights Reserved.
--
-- Command Table
--

local gCmdTab = {}
require('TinyBot/DataDumper')
local bingo = require("TinyBot/Bingo")
local blackjack = require('TinyBot/BlackJack')
function printTable(list, i)

    local listString = ''
--~ begin of the list so write the {
    if not i then
        listString = listString .. '{'
    end

    i = i or 1
    local element = list[i]

--~ it may be the end of the list
    if not element then
        return listString .. '}'
    end
--~ if the element is a list too call it recursively
    if(type(element) == 'table') then
        listString = listString .. printTable(element)
    else
        listString = listString .. element
    end

    return listString .. ', ' .. printTable(list, i + 1)

end
function dump(text)
  print(DataDumper(text), "\n---")
end
------------------------------------------------------------------------------

function bot_addcommand(cmd, level, desc, minargs, maxargs, func)
	gCmdTab[cmd] = { level = level, func = func, desc = desc, minargs = minargs, maxargs = maxargs }
	print("added " .. desc)
end

function bot_onprivmsg(server, event, nuh, parv)
	-- Dont process this event if it was typed in the client, or if it wasnt sent to the Bot's nick
	-- This stops things like spurious and confusing error messages
	if nick == server:GetNickname() or string.sub(server:GetNickname(), 1, string.len(TinyBotCfg.nick)) ~= TinyBotCfg.nick then
		return 0
	end

	-- Allow commands to be sent with or without the command char to /msg
	local cs = 2
	if parv[2] ~= server:GetNickname() and string.sub(parv[3], 1, 1) ~= TinyBotCfg.cmdchar then
		return 0
	end
	if parv[2] == server:GetNickname() and string.sub(parv[3], 1, 1) ~= TinyBotCfg.cmdchar then
		cs = 1
	end

	-- Check the command is valid
	local cmd

	local st, en = string.find(parv[3], " ")
	if st == nil then
		cmd = string.sub(parv[3], cs)
	else
		cmd = string.sub(parv[3], cs, st-1)
	end

	if gCmdTab[cmd] == nil then
		bot_sendreply(server, parv[2], nick, BOLD .. "Error" .. BOLD .. ": Unknown Command")
		return 0
	end
	-- Split up the args

	local c, argv = 0, {}
	if en ~= nil then

		while true do
			st = en + 1
			if gCmdTab[cmd].maxargs ~= nil and c >= (gCmdTab[cmd].maxargs - 1) then
				en = nil
			else
				en = string.find(parv[3], " ", st)
			end

			local arg
			if en == nil then
				arg = string.sub(parv[3], st)
			else
				arg = string.sub(parv[3], st, en - 1)
			end

			table.insert(argv, arg)
			c = c + 1

			if en == nil then break end
		end
	end
	table.setn(argv, c)

	if gCmdTab[cmd].minargs ~= nil and c < gCmdTab[cmd].minargs then
		bot_sendreply(server, parv[2], nick, BOLD .. "Error" .. BOLD .. ": Not enough arguments for command \'" .. cmd .. "\', expected " .. gCmdTab[cmd].minargs)
		return 0
	end

	-- Dispatch the command
	gCmdTab[cmd].func(server, parv[2], cmd, argv, nuh)

	return 0
end

function bot_sendreply(server, to, nick, msg)
	if string.sub(to, 1, 1) == "#" then
		server:SendPrivmsg(to, msg)
	else
		server:SendPrivmsg(nick, msg)
	end
end

------------------------------------------------------------------------------

local function onTest(server, to, cmd, argv, nuh)
	bot_sendreply(server, to, nuh.nick, "Test Command sent to " .. to .. " by " .. nuh.prefix)
	local args = ""

	for i,v in ipairs(argv) do
		if args ~= "" then
			args = args .. ", \"" .. v .. "\"";
		else
			args = "\"" .. v .. "\"";
		end
	end
	bot_sendreply(server, to, nuh.nick, "Num Args: " .. table.getn(argv) .. " Args: " .. args)
	bot_sendreply(server, to, nuh.nick,
		", " .. type(to) .. ", " .. to  --printTable(gCmdTab) 
		.. ", ".. type(cmd) -- .. ", " .. printTable(cmd)
		.. ", " .. type(argv) .. ", " .. table.concat(argv, ", " )
		.. ", " .. type(nuh) .. ", " .. nuh.nick --table.concat(nuh, ", " )
		)
end

local function onOp(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		server:SendMode(to, "+o " .. nuh.nick)
	end
end

bot_addcommand("test", 1, "A test command", 1, 2, onTest)
--bot_addcommand("op", 5, "Op the caller", nil, nil, onOp)
math.randomseed(os.time())
local function onRoll(server, to, cmd, argv, nuh)
	local args = ""
	
	num = tonumber(argv[1])
	if num < 1 then num = 1 end
	if num > 10 then num = 10 end
	size = tonumber(argv[2])
	if size < 1 then size = 1 end
	if size > 1000 then size = 1000 end
	result = 0
	for i = 1, num do
		result = result + math.random(size)
	end
	
	bot_sendreply(server, to, nuh.nick, "Args: " .. num .. ", " .. size .. " Roll: " .. result)
end

local function onCharacter(server, to, cmd, argv, nuh)
	if nuh.nick ~= "Zorn_Taov" then return end
	local args = ""
	
	num = tonumber(argv[1])
	if num < 1 then num = 1 end
	result = math.random(num)
	bot_sendreply(server, to, nuh.nick, "https://dl.dropboxusercontent.com/u/7129858/Character%20Sheet/botchoose/" .. result .. ".png")
end

bot_addcommand("roll", 1, "A test command", 2, 2, onRoll)
bot_addcommand("form", 1, "A test command", 1, 1, onCharacter)
function onBingoStart(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if not bingo.gameplaying then
			bingo.gameplaying = true
			bingo.fillSheet()
			bot_sendreply(server, to, nuh.nick, "A game has started, use !bingo_join to join!")
		else
			bot_sendreply(server, to, nuh.nick, "in a game!")
		end
	end
end

function onBingoJoin(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if bingo.gameplaying then
			bingo.addBingoPlayer(nuh.nick)
			bot_sendreply(server, to, nuh.nick, nuh.nick .. " has joined the game!")
			player = bingo.getPlayers()[nuh.nick]
			bot_sendreply(server, nuh.nick, nuh.nick, "---------------")
			bot_sendreply(server, nuh.nick, nuh.nick, "B  I  N  G  O")
			for i=1,5 do
				line = ""
				for j=1,5 do
					line = line .. player[j][i] .. " "
				end
				bot_sendreply(server, nuh.nick, nuh.nick, line)
			end
			
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !bingo_start then !bingo_join")
		end
	end
end
timetill = 0
function onBingoDraw(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if bingo.gameplaying then
			if os.clock() > timetill then
				timetill = os.clock() + 10
			else
				sec = timetill - os.clock()
				bot_sendreply(server, to, nuh.nick, "you need to wait " .. bingo.round(sec+.5) .. " more seconds.")
				return
			end
			call = bingo.draw()
			if call ~= false then
				bot_sendreply(server, to, nuh.nick, call .. "!")
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !bingo_start then !bingo_join")
		end
	end
end

function onBingo(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if bingo.gameplaying then
			if bingo.checkcard(nuh.nick) then
				bot_sendreply(server, to, nuh.nick, nuh.nick .. " is a WINNER!")
				bingo.endGame()
				bingo.gameplaying = false
			else
				bot_sendreply(server, to, nuh.nick, nuh.nick .. " is not a winner, keep playing!")
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !bingo_start then !bingo_join")
		end
	end
end

function onBingoCheck(server, to, cmd, argv, nuh)
	--if string.sub(to, 1, 1) == "#" then
		if bingo.gameplaying then
			card = bingo.showcard(nuh.nick)
			if card == nil then
				bot_sendreply(server, to, nuh.nick, nuh.nick .. " is not in the game, use !bingo_join")
			end
			bot_sendreply(server, nuh.nick, nuh.nick, "---------------")
			bot_sendreply(server, nuh.nick, nuh.nick, " B  I  N  G  O")
			for i=1,5 do
				line = ""
				for j=1,5 do
					line = line .. card[j][i]
				end
				bot_sendreply(server, nuh.nick, nuh.nick, line)
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !bingo_start then !bingo_join")
		end
	--end
end

bot_addcommand("bingo_start", 5, "Start a Bingo game!", nil, nil, onBingoStart)
bot_addcommand("bingo_join", 5, "Join a Bingo game!", nil, nil, onBingoJoin)
bot_addcommand("bingo_leave", 5, "leave the game.", 1, 1, onBingoRemovePlayer)
bot_addcommand("draw", 5, "Draw!", nil, nil, onBingoDraw)
bot_addcommand("bingo", 5, "Bingo!", nil, nil, onBingo)
bot_addcommand("check", 5, "check your card!", nil, nil, onBingoCheck)

function onBlackJackStart(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if not blackjack.bjgameplaying then
			blackjack.gameplaying = true
			blackjack.fillDeck()
			bot_sendreply(server, to, nuh.nick, "A game has started, use !blackjack_join to join!")
		else
			bot_sendreply(server, to, nuh.nick, "in a game!")
		end
	end
end

function onBlackJackJoin(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if blackjack.gameplaying then
			blackjack.addBJPlayer(nuh.nick)
			bot_sendreply(server, to, nuh.nick, nuh.nick .. " has joined the game!")
			player = blackjack.getPlayers()
			--for k,v in ipairs(player) do
			--	bot_sendreply(server, nuh.nick, nuh.nick, k .. ": " .. table.concat(v, ", "))
			--end
			--derp = {"derp" = 1, hello = 2}
			for k,v in ipairs(derp) do
				print(k .. ", " .. v)
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !bingo_start then !bingo_join")
		end
	end
end

function onBlackJackDraw(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if blackjack.gameplaying then
			call = blackjack.drawCard()
			if call ~= false then
				bot_sendreply(server, to, nuh.nick, call .. "!")
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !blackjack_start then !blackjack_join")
		end
	end
end

function onBlackJackStatus(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if blackjack.gameplaying then
			call = blackjack.setStatus()
			if call ~= false then
				bot_sendreply(server, to, nuh.nick, call .. "!")
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !blackjack_start then !blackjack_join")
		end
	end
end

function onBlackJackRemovePlayer(server, to, cmd, argv, nuh)
	if string.sub(to, 1, 1) == "#" then
		if blackjack.gameplaying then
			player = blackjack.removePlayer(nuh.nick)
			if player ~= nil then
				reason = ""
				if cmd == "blackjack_remove" then 
					reason = "been removed from" 
				elseif cmd == "blackjack_leave" then 
					reason = "left" 
				else 
					reason = "broke"
				end
				bot_sendreply(server, to, nuh.nick, player .. "has " .. reason .. " the game.")
			end
		else
			bot_sendreply(server, to, nuh.nick, "No game has started! Use !blackjack_start then !blackjack_join")
		end
	end
end


bot_addcommand("blackjack_start", 5, "Start a Black Jack game!", nil, nil, onBlackJackStart)
bot_addcommand("blackjack_join", 5, "Join a Black Jack game!", nil, nil, onBlackJackJoin)
bot_addcommand("hit", 5, "Get a card.", 0, 1, onBlackJackDraw)
bot_addcommand("stay", 5, "Stay with this hand.", nil, nil, onBlackJackStatus)
bot_addcommand("bust", 5, "You lose!", nil, nil, onBlackJackStatus)
bot_addcommand("blackjack_remove", 5, "remove a dead player.", 1, 1, onBlackJackRemovePlayer)
bot_addcommand("blackjack_leave", 5, "leave the game.", 1, 1, onBlackJackRemovePlayer)