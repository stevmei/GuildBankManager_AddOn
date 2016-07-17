function GBMFrame_OnLoad()
	SLASH_GBM1 = "/gbm";
	SlashCmdList["GBM"] = GBM_SlashHandler;
	GBMFrame:Hide();
	ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c00FFD700Addon geladen!|r");
end

function GBM_SlashHandler(arg)
	local opt;
	if (string.sub(arg, 1, string.len(arg)) == "inventar") then
		saveBagRoster();
		return;
	end
	if (string.sub(arg, 1, string.len(arg)) == "gilde") then
		saveGuildMembers();
		return;
	end
	if (string.sub(arg, 1, 8) == "ausnahme") then
		if (string.sub(arg, 1, string.len(arg)) == "ausnahme") then
			guildExcepts(true, "-");
		else
			guildExcepts(false, arg);
		end
		return;
	end
	if (string.sub(arg, 1, string.len(arg)) == "info") then
		ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: Version 2.1 by Steven M. aka Xeranos <Ultima> - Mail: admin@sigmaroot.de|r");
		return;
	end
	ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c00FF0000Argumente: inventar, gilde, ausnahme, info|r");
end

function guildExcepts(onlyShow, arg)
	if (gbm_excepts == nil) then
		gbm_excepts = {};
	end
	local count = 0;
	local ranks = "";
	for index, value in pairs(gbm_excepts) do
		count = count + 1;
		if (count == 1) then
			ranks = value;
		else
			ranks = ranks..", "..value;
		end		
	end
	if (onlyShow) then
		if (count > 0) then
			ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c0000FF00Gespeicherte Ausnahmen: "..ranks.."|r");
		else
			ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c00FF0000Keine Ausnahmen gefunden!"..ranks.."|r");
		end
	else
		local newrank = string.sub(arg, 10, string.len(arg));
		if (newrank ~= "") then
			local rankfound = false;
			local rankindex = 0;
			for index, value in pairs(gbm_excepts) do
				if (value == newrank) then
					rankfound = true;
					rankindex = index;
					break;
				end
			end
			if (rankfound) then
				table.remove(gbm_excepts, rankindex);
				ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c0000FF00Der Rang '"..newrank.."' wurde als Ausnahme entfernt!|r");
			else
				table.insert(gbm_excepts, newrank);				
				ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c0000FF00Der Rang '"..newrank.."' wurde als Ausnahme gespeichert!|r");
			end
		else
			ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c00FF0000Keinen Rangnamen eingegeben!|r");
		end
	end
end

function saveGuildMembers()
	local index = 1;
	local numMembers = GetNumGuildMembers(true);
	gbm_guildmembers = {};
	local execptranks = {};
	local count = 0;
	if (gbm_excepts == nil) then
		gbm_excepts = {};
	end
	for eindex, value in pairs(gbm_excepts) do
		execptranks[count] = value;
		count = count + 1;		
	end
	for pos = 1, numMembers do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(pos);
		local skipthis = false;
		for eindex = 0, (count - 1) do
			if (rank == execptranks[eindex]) then
				skipthis = true;
			end
		end
		if not (skipthis) then
			gbm_guildmembers[index] = name.."%"..level.."%"..class.."%"..rank;
			index = index + 1;
		end
	end
	if (index == 1) then
		ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c00FF0000Bitte die Gilden-Liste öffnen!|r");
	else
		ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c0000FF00"..(index - 1).." Gilden-Mitglieder gespeichert!|r");
	end
end

function saveBagRoster()
	local index = 1;
	local data_table = nil;
	local data_table = {};
	for bag = -1, (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemID = HyperlinkToShortLink(GetContainerItemLink(bag, slot));
			if (itemID ~= nil) then
				local texture, count = GetContainerItemInfo(bag, slot);
				local itemName, itemLink, itemRarity = GetItemInfo(itemID);
				data_table[index] = count.."%"..itemID.."%"..itemRarity.."%"..itemName;
				index = index + 1;
			end
		end
	end
	local charGold = GetMoney();
	data_table[index] = charGold.."%999999%1%Gold";
	if (gbm_bank == nil) then
		gbm_bank = {};
	end
	local playerName = UnitName("player");
	gbm_bank[playerName] = data_table;
	ChatFrame1:AddMessage("|c00FFD700G|c00FFFFFFuild|c00FFD700B|c00FFFFFFank|c00FFD700M|c00FFFFFFanager: |c0000FF00Inventar-Daten gespeichert!|r");
end

function HyperlinkToShortLink(hyperLink)
	if (hyperLink) then
		local _, _, w, x, y, z = string.find(hyperLink, "item:(%d+):(%d+):(%d+):(%d+)");
		return w;
	end
end
