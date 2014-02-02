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
a = {"B", "I", "N", "G", "O"}
local players = {}

function bingo.fillSheet()
	print("________________________")
	for i=1, 75 do
		bingoSheet[i] = a[bingo.round(i/15+.5)] .. i
	end
	bingo.shuffle(bingoSheet)
	print(table.concat( bingoSheet, ", " ))
	if debugbingo then
		for i=1, 73 do
			print(bingoSheet[1])
			table.remove(bingoSheet, 1)
			
		end
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
			mt[i][j] = a[i] .. cardTableDummy[i][1]
			table.remove(cardTableDummy[i], 1)
		end
	end
	mt[3][3] = "free"
	players[nick] = mt
	for i=1,5 do
		print(table.concat(players[nick][i], ", ") .. "\n")
	end
end

function bingo.getPlayers()
	return players
end

function getNumPlayers()
	return table.getn(players)
end

function bingo.checkcard(nick)
	win = false
	print(table.concat(called, ", "))
	--check rows
	for i=1,5 do
		ding = 0
		for j=1,5 do
			if bingo.findMe(called, players[nick][i][j]) or players[nick][i][j] == "free" then 
				ding = ding + 1
			end
		end
		if ding == 5 then 
			win = true 
			break
		end
	end
	--check columns
	for i=1,5 do
		if win then break end
		ding = 0
		for j=1,5 do
			if bingo.findMe(called, players[nick][j][i]) or players[nick][j][i] == "free" then 
				ding = ding + 1
			end
		end
		if ding == 5 then 
			win = true 
			break
		end
	end
	--check cross
	if win then return win end
	ding = 0
	for i=1,5 do
		if bingo.findMe(called, players[nick][i][i]) or players[nick][i][i] == "free" then 
			ding = ding + 1
		end
	end
	if ding == 5 then 
		win = true 
	end
	if win then return win end
	ding = 0
	for i=1,5 do
		if bingo.findMe(called, players[nick][i][6-i]) or players[nick][i][6-i] == "free" then 
			ding = ding + 1
		end
	end
	if ding == 5 then 
		win = true 
	end
	return win
end

function bingo.showcard(nick)
	local card = players[nick]
	
	for i=1,5 do
		for j=1,5 do
			if bingo.findMe(called, card[i][j]) or card[i][j] == "free" then 
				card[i][j] = "(" .. card[i][j] .. ")"
			end
		end
	end
	return card
end

function bingo.draw()
	if table.getn(bingoSheet)<1 then
		print("game over!")
		return false
	end
	print(bingoSheet[1])
	table.insert(called, bingoSheet[1])
	--print(table.concat(called, ", ") .. " called table")
	call = bingoSheet[1]
	table.remove(bingoSheet, 1)
	return call
end

function bingo.endGame()
	bingo.gameplaying = false
	bingoSheet = {}
	called = {}
	players = {}
end
return bingo