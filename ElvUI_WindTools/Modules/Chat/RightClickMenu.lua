-- 原作：TinyUntitled 的 Menu lua中的一段
-- loudsoul (http://bbs.ngacn.cc/read.php?tid=10240957)
-- 修改：houshuu
-------------------
-- 主要修改条目：
-- 模块化
-- 增加自定义功能设定项

local E, L, V, P, G = unpack(ElvUI)
local WT = E:GetModule("WindTools")
local EnhancedRCMenu = E:NewModule('EnhancedRCMenu');

P["WindTools"]["Right-click Menu"] = {
	["enabled"] = true,
	["friend"] = {
		["ARMORY"] = true,
		["SEND_WHO"] = true,
		["NAME_COPY"] = true,
		["GUILD_ADD"] = true,
		["FRIEND_ADD"] = true,
		["MYSTATS"] = true,
	},
	["chat_roster"] = {
		["NAME_COPY"]  = true,
		["SEND_WHO"] = true,
		["FRIEND_ADD"] = true,
		["INVITE"] = true,
	},
	["guild"] = {
		["ARMORY"] = true,
		["NAME_COPY"] = true,
		["FRIEND_ADD"] = true,
	}
}

local function urlencode(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c)
			return format("%%%02X", string.byte(c))
		end)
	return string.gsub(s, " ", "+")
end

local function gethost()
	local host = "http://us.battle.net/wow/en/character/"
	if (locale == "zhTW") then
		host = "http://tw.battle.net/wow/zh/character/"
	elseif (locale == "zhCN") then
		host = "http://www.battlenet.com.cn/wow/zh/character/"
	end
	return host
end

local function popupClick(self, info)
	local editBox
	local name, server = UnitName(info.unit)
	if (info.value == "ARMORY") then
		local armory = gethost() .. urlencode(server or GetRealmName()) .. "/" .. urlencode(name) .. "/advanced"
		editBox = ChatEdit_ChooseBoxForSend()
		ChatEdit_ActivateChat(editBox)
		editBox:SetText(armory)
		editBox:HighlightText()
	elseif (info.value == "NAME_COPY") then
		editBox = ChatEdit_ChooseBoxForSend()
		local hasText = (editBox:GetText() ~= "")
		ChatEdit_ActivateChat(editBox)
		editBox:Insert(name)
		if (not hasText) then editBox:HighlightText() end
	end
end

function EnhancedRCMenu:Initialize()
	if not E.db.WindTools["Right-click Menu"]["enabled"] then return end

	local locale = GetLocale()

	local UnitPopupButtonsExtra = {
		["ARMORY"] = L["Armory"],
		["SEND_WHO"] = L["Query Detail"],
		["NAME_COPY"] = L["Get Name"],
		["GUILD_ADD"] = L["Guild Invite"],
		["FRIEND_ADD"] = L["Add Friend"],
		["MYSTATS"] = L["Report MyStats"],
	}

	for k, v in pairs(UnitPopupButtonsExtra) do
		UnitPopupButtons[k] = {}
		UnitPopupButtons[k].text = v
	end

	-- 好友功能
	local friend_features = {
		"ARMORY",
		"MYSTATS",
		"NAME_COPY",
		"SEND_WHO",
		"FRIEND_ADD",
		"GUILD_ADD",
	}
	for _, v in pairs(friend_features) do
		if E.db.WindTools["Right-click Menu"]["friend"][v] then
			tinsert(UnitPopupMenus["FRIEND"], 1, v)
		end
	end
	-- 聊天名单功能
	local cr_features = {
		"NAME_COPY",
		"SEND_WHO",
		"FRIEND_ADD",
		"INVITE",
	}
	for _, v in pairs(cr_features) do
		if E.db.WindTools["Right-click Menu"]["chat_roster"][v] then
			tinsert(UnitPopupMenus["CHAT_ROSTER"], 1, v)
		end
	end
	-- 公会功能
	local guild_features = {
		"ARMORY",
		"NAME_COPY",
		"FRIEND_ADD",
	}
	for _, v in pairs(guild_features) do
		if E.db.WindTools["Right-click Menu"]["guild"][v] then
			tinsert(UnitPopupMenus["GUILD"], 1, v)
		end
	end

	hooksecurefunc("UnitPopup_ShowMenu", function(dropdownMenu, which, unit, name, userData)
		if (UIDROPDOWNMENU_MENU_LEVEL > 1) then return end
		if (unit and (unit == "target" or string.find(unit, "party"))) then
			local info
			if (UnitIsPlayer(unit)) then
				info = UIDropDownMenu_CreateInfo()
				info.text = UnitPopupButtonsExtra["ARMORY"]
				info.arg1 = {value="ARMORY",unit=unit}
				info.func = popupClick
				info.notCheckable = true
				UIDropDownMenu_AddButton(info)
			end
			info = UIDropDownMenu_CreateInfo()
			info.text = UnitPopupButtonsExtra["NAME_COPY"]
			info.arg1 = {value="NAME_COPY",unit=unit}
			info.func = popupClick
			info.notCheckable = true
			UIDropDownMenu_AddButton(info)
		end
	end)

	hooksecurefunc("UnitPopup_OnClick", function(self)
		local unit = UIDROPDOWNMENU_INIT_MENU.unit
		local name = UIDROPDOWNMENU_INIT_MENU.name
		local server = UIDROPDOWNMENU_INIT_MENU.server
		local fullname = name
		local editBox
		if (server and (not unit or UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME)) then
			fullname = name .. "-" .. server
		end
		if (self.value == "ARMORY") then
			local armory = gethost() .. urlencode(server or GetRealmName()) .. "/" .. urlencode(name) .. "/advanced"
			editBox = ChatEdit_ChooseBoxForSend()
			ChatEdit_ActivateChat(editBox)
			editBox:SetText(armory)
			editBox:HighlightText()
		elseif (self.value == "MYSTATS") then
			local CRITICAL = TEXT_MODE_A_STRING_RESULT_CRITICAL or STAT_CRITICAL_STRIKE
			CRITICAL = gsub(CRITICAL, "[()]","")
			SendChatMessage(format("%s:%.1f %s:%s", ITEM_LEVEL_ABBR, select(2,GetAverageItemLevel()), HP, AbbreviateNumbers(UnitHealthMax("player"))), "WHISPER", nil, fullname)
			SendChatMessage(format(" - %s:%.2f%%", STAT_HASTE, GetHaste()), "WHISPER", nil, fullname)
			SendChatMessage(format(" - %s:%.2f%%", STAT_MASTERY, GetMasteryEffect()), "WHISPER", nil, fullname)
			--SendChatMessage(format(" - %s:%.2f%%", STAT_LIFESTEAL, GetLifesteal()), "WHISPER", nil, fullname)
			SendChatMessage(format(" - %s:%.2f%%", CRITICAL, max(GetRangedCritChance(), GetCritChance(), GetSpellCritChance(2))), "WHISPER", nil, fullname)
			SendChatMessage(format(" - %s:%.2f%%", STAT_VERSATILITY, GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)), "WHISPER", nil, fullname)
		elseif (self.value == "NAME_COPY") then
			editBox = ChatEdit_ChooseBoxForSend()
			local hasText = (editBox:GetText() ~= "")
			ChatEdit_ActivateChat(editBox)
			editBox:Insert(fullname)
			if (not hasText) then editBox:HighlightText() end
		elseif (self.value == "FRIEND_ADD") then
			AddFriend(fullname)
		elseif (self.value == "SEND_WHO") then
			SendWho("n-"..name)
		elseif (self.value == "GUILD_ADD") then
			GuildInvite(fullname)
		end
	end)
end

local function InsertOptions()
	E.Options.args.WindTools.args["Chat"].args["Right-click Menu"].args["additionalconfig"] = {
		order = 10,
		type = "group",
		name = L["Features"],
		disabled = function() return not E.db.WindTools["Right-click Menu"]["enabled"] end,
		args = {
			custom_text = {
				order = 1,
				type = "toggle",
				name = L["Use feature 1"],
				
				get = function(info) return E.db.WindTools["Right-click Menu"]["feature1"] end,
				set = function(info, value) E.db.WindTools["Right-click Menu"]["feature1"] = value; E:StaticPopup_Show("PRIVATE_RL")  end,
			},
		}
	}
end
WT.ToolConfigs["Right-click Menu"] = InsertOptions
E:RegisterModule(EnhancedRCMenu:GetName())