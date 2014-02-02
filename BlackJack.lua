BJ = {}
math.randomseed(os.time())
BJ.gameplaying = false
local debugbj = false
local players = {}
local playerList = {}
local deck = {}
local nums = {"A", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"}
local suits = {"S", "C", "4D", "4H"}
local deckcount = 1

function round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

function BJ.shuffle(t)
        assert(t, "BJ.shuffle() expected a table, got nil")
        local iterations = table.getn(t)
        local j
        for i = iterations, 2, -1 do
                j = math.random(i)
                t[i], t[j] = t[j], t[i]
        end
end

function BJ.findMe(sometable, searchMe)
	local found = false
	for i = 1,table.getn(sometable) do
		if sometable[i] == searchMe then
			found = true
			break
		end
	end
	return found -- (true/false)
end

function BJ.fillDeck(count)
	if count ~= nil then
		deckcount = count
	end
	print("________________________")
	num = 1
	for k=1, deckcount or 1 do
		for i=1, table.getn(suits) do
			for j=1, table.getn(nums) do
				print(nums[j] .. suits[i])
				deck[num] = nums[j] .. suits[i]
				num = num + 1
			end
		end
	end
	print(table.concat( deck, ", " ))
	BJ.shuffle(deck)
	print(table.concat( deck, ", " ))
	if debugbj then
		for i=1, table.getn(deck) do
			print(deck[1])
			table.remove(deck, 1)
		end
	end
end

function BJ.addBJPlayer(nick)
	players[nick] = {}
	
	hand = {}
	
	for i=1,2 do
		hand[i] = BJ.drawCard(nick)
	end
	--players[nick] = hand
	print(table.concat(players[nick], ", ") .. "\n")
	return mt
end

function BJ.getPlayers()
	return players
end

function BJ.removePlayer(nick)
	for k,v in ipairs(playerList) do
		
	end
end

function BJ.clearHand(nick)
	if players[nick] ~= nil then
		players[nick] = {}
	end
end

function BJ.drawCard(nick)
	if table.getn(deck)<3 then
		BJ.fillDeck(deckcount)
	end
	print(deck[1])
	call = deck[1]
	table.insert(players[nick], call)
	table.remove(deck, 1)
	return call
end

return BJ