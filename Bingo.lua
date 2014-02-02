bingo = {}
math.randomseed(os.time())
bingo.gameplaying = false
local debugbingo = false

function bingo.round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

function bingo.shuffle(t)
        assert(t, "table.bingo.shuffle() expected a table, got nil")
        local iterations = table.getn(t)
        local j
        for i = iterations, 2, -1 do
                j = math.random(i)
                t[i], t[j] = t[j], t[i]
        end
end

function bingo.findMe(sometable, searchMe)
	local found = false
	for i = 1,table.getn(sometable) do
		if sometable[i] == searchMe then
			found = true
			break
		end
	end
	return found -- (true/false)
end

local bingoSheet = {}
local called = {}
for i=1, 75 do
	called[i] = false
end

local players = {}
a = {"B", "I", "N", "G", "O"}

function bingo.fillSheet()
	print("________________________")
	for i=1, 75 do
		bingoSheet[i] = i
	end
	bingo.shuffle(bingoSheet)
	if debugbingo then
		print(table.concat( bingoSheet, ", " ))
	end
end

function bingo.addBingoPlayer(nick)
	if players[nick] ~= nil then return end
	
	mt = {}
	cardTableDummy = {}
	for i=1,5 do
		cardTableDummy[i] = {}
		for j=1,15 do
			cardTableDummy[i][j] = j + 15*(i-1)
		end
	end

	for i=1,5 do
		mt[i] = {}
		bingo.shuffle(cardTableDummy[i])
		for j=1,5 do
			mt[i][j] = cardTableDummy[i][1]
			table.remove(cardTableDummy[i], 1)
		end
	end
	mt[3][3] = "##"
	players[nick] = mt
	if debugbingo then
		for i=1,5 do
			print(table.concat(players[nick][i], ", ") .. "\n")
		end
	end
end

function bingo.getPlayers()
	return players
end

function getNumPlayers()
	return table.getn(players)
end

function bingo.checkcard(nick)
	--print(table.concat(called, ", "))
	if debugbingo then
		for k,v in ipairs(called) do
			print(k .. ": " .. tostring(v))
		end
	end
	--check rows
	for i=1,5 do
		ding = 0
		for j=1,5 do
			if (called[players[nick][i][j]] ~= nil and called[players[nick][i][j]]) or players[nick][i][j] == "##" then 
				ding = ding + 1
			end
		end
		if ding == 5 then 
			return true
		end
	end
	--check columns
	for i=1,5 do
		ding = 0
		for j=1,5 do
			if (called[players[nick][j][i]] ~= nil and called[players[nick][j][i]]) or players[nick][j][i] == "##" then 
				ding = ding + 1
			end
		end
		if ding == 5 then 
			return true
		end
	end
	--check cross
	ding = 0
	for i=1,5 do
		if (called[players[nick][i][i]] ~= nil and called[players[nick][i][i]]) or players[nick][i][i] == "##" then 
			ding = ding + 1
		end
	end
	if ding == 5 then 
		return true
	end
	ding = 0
	for i=1,5 do
		if (called[players[nick][i][6-i]] ~= nil and called[players[nick][i][6-i]]) or players[nick][i][6-i] == "##" then 
			ding = ding + 1
		end
	end
	if ding == 5 then 
		return true 
	end
	return false
end

function bingo.showcard(nick)

	card = {}
	for i=1, 5 do
		card[i] = {}
		for j,x in pairs(players[nick][i]) do card[i][j] = x end
	end
	
	for i=1,5 do
		for j=1,5 do
			spaaaaaace = ""
			if type(card[i][j]) == 'number' and card[i][j] < 10 then 
				spaaaaaace = " " 
			end	
			if called[card[i][j]] or card[i][j] == "##" then 
				card[i][j] = "\002\0034 " .. spaaaaaace .. card[i][j] .. "\003\002"
			else
				card[i][j] = " " .. spaaaaaace .. card[i][j]
			end
		end
	end
	
	spaaaaaace = ""
	return card
end

function bingo.draw()
	if table.getn(bingoSheet)<1 then
		print("game over!")
		return false
	end
	print(bingoSheet[1])
	called[bingoSheet[1]] = true
	--print(table.concat(called, ", ") .. " called table")
	call = bingoSheet[1]
	table.remove(bingoSheet, 1)
	return a[bingo.round(call/15+.5)] .. call
end

function bingo.endGame()
	bingo.gameplaying = false
	bingoSheet = {}
	called = {}
	players = {}
end
return bingo