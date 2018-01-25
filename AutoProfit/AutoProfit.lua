----------------------------------------------------------------
--	AutoProfit v3.11 (June 2006)
--	Check out www.gameguidesonline.com for the latest version.
--	To learn how I used the 3D model read this: (http://www.gameguidesonline.com/guides/articles/ggoarticleoctober05_02.asp)
--	Written by Jason Allen.
----------------------------------------------------------------

autoProfitExceptions = {}
autoSell = 0
autoSilent = 0
totalProfit = 0
rotation = 0
rotrate = 0

function AutoProfit_OnLoad()
	SLASH_AUTOPROFIT1 = "/autoprofit"
	SLASH_AUTOPROFIT2 = "/ap"
	SlashCmdList["AUTOPROFIT"] = AutoProfit_SlashCmd
end

function AutoProfit_SellJunk()
	local oldTime, newTime
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			oldTime = GetTime()
			local check = AutoProfit_CheckItem(GetContainerItemLink(bag, slot))
			if check then
				if autoSilent == 0 then DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_SOLD.. GetContainerItemLink(bag, slot), 0.0, .8, 1) end
				newTime = GetTime()
				while newTime - oldTime < .1 do newTime = GetTime() end -- item sale every 0.1 second
				UseContainerItem(bag, slot)
			end
		end
	end
end

function AutoProfit_Calculate()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local check = AutoProfit_CheckItem(GetContainerItemLink(bag, slot))
			if check then
				AutoProfit_Tooltip:SetBagItem(bag, slot)
			end
		end
	end
end

function AutoProfit_AddCoin()
	if arg1 then
		totalProfit = totalProfit + arg1
	end
end

function AutoProfit_RotateModel(elapsed)
	if rotrate > 0 then 
		rotation = rotation + elapsed * rotrate
	end
	TreasureModel:SetRotation(rotation)
end

function AutoProfit_CheckItem(link)
	if not link then return end
		
	--This prevents Dark Moon Faire items from being sold to the vendor.
	if string.find(link, "11407") then return end -- Torn Bear Pelt

	if string.find(link, "ff9d9d9d") then
		for i = 1,table.getn(autoProfitExceptions) do
			if link == autoProfitExceptions[i] then return nil end
		end
		return true
	end
	return nil
end

function AutoProfit_SlashCmd(msg)
	
	--No switch statement in Lua? Lots of ugly if's to follow.		
	if msg == "" then
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_HELP_MSG1, 0.0, .8, 1)
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_HELP_MSG2, 0.0, .8, 1)
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_HELP_MSG3, 0.0, .8, 1)
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_HELP_MSG4, 0.0, .8, 1)
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_HELP_MSG5, 0.0, .8, 1)
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_HELP_MSG6, 0.0, .8, 1)
		return
	elseif msg == "auto" then
		if autoSell == 0 then
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_AUTOSELL_ON, 0.0, .8, 1)
			autoSell = 1
		else
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_AUTOSELL_OFF, 0.0, .8, 1)
			autoSell = 0
			AutosellButton:Show()
			TreasureModel:Show()
		end
		return
	elseif msg == "silent" then
		if autoSilent == 0 then
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_AUTOREPORT_OFF, 0.0, .8, 1)
			autoSilent = 1
		else
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_AUTOREPORT_ON, 0.0, .8, 1)
			autoSilent = 0
		end
		return
	elseif msg == "list" then
		if table.getn(autoProfitExceptions) > 0 then
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_EXPENTIONS, 0.0, .8, 1)
			for i=1,table.getn(autoProfitExceptions) do
				DEFAULT_CHAT_FRAME:AddMessage("[|c00bfffff" .. i .. "|r] " .. autoProfitExceptions[i], 0.0, .8, 1)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_EXPENTIONS_EMPTY, 0.0, .8, 1)
		end
		return
	elseif msg == "purge" then
		autoProfitExceptions = { }
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_EXPENTIONS_DELETE, 0.0, .8, 1)
		return
	end
	
	if string.len(msg) < 6 then
		if tonumber(msg) == nil then return end
		if tonumber(msg) > table.getn(autoProfitExceptions) then 
			return
		else
			DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_EXPENTIONS_REMOVED..autoProfitExceptions[tonumber(msg)]..AUTOPROFIT_EXPENTIONSLIST, 0.0, .8, 1)
			table.remove(autoProfitExceptions, tonumber(msg))
			return
		end
	end
	
	if string.find(msg, "Hitem:") == nil then return end
	local removed = 0
	if table.getn(autoProfitExceptions) > 0 then
		for i=1,table.getn(autoProfitExceptions) do
			if msg == autoProfitExceptions[i] then
				DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_EXPENTIONS_REMOVED..autoProfitExceptions[i]..AUTOPROFIT_EXPENTIONSLIST, 0.0, .8, 1)
				table.remove(autoProfitExceptions, i)
				removed = 1
			end
		end
	end
	if removed == 0 then
		table.insert(autoProfitExceptions, msg)
		DEFAULT_CHAT_FRAME:AddMessage(AUTOPROFIT_EXPENTIONS_ADDED.. msg ..AUTOPROFIT_EXPENTIONSLIST2, 0.0, .8, 1)
	end
end