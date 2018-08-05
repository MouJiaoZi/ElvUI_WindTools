-- 作者：houshuu
local E, L, V, P, G = unpack(ElvUI)
local WT = E:GetModule("WindTools")
local WMS = E:NewModule('WorldMapScale', 'AceHook-3.0');
local _G = _G
-- 默认开启
P["WindTools"]["World Map Scale"] = {
	["enabled"] = true,
	["scale"] = 1.2,
}

local function SetMapScale()
	_G["WorldMapFrame"]:SetScale(E.db.WindTools["World Map Scale"]["scale"])
	-- 修复指针错误 方案来源 NDui
	RunScript("WorldMapFrame.ScrollContainer.GetCursorPosition=function(f) local x,y=MapCanvasScrollControllerMixin.GetCursorPosition(f);local s=WorldMapFrame:GetScale();return x/s,y/s;end")
end

local function InsertOptions()
	E.Options.args.WindTools.args["Interface"].args["World Map Scale"].args["settings"] = {
		order = 10,
		type = "group",
		name = L["Setting"],
		args = {
			EmN = {
				order = 1,
				type = "range",
				name = L["Scale"],
				min = 0.5, max = 2, step = 0.1,
				get = function(info) return E.db.WindTools["World Map Scale"]["scale"] end,
				set = function(info, value) E.db.WindTools["World Map Scale"]["scale"] = value; setMapScale(); end
			},
		}
	}
end

function WMS:Initialize()
	if E.db.WindTools["World Map Scale"]["enabled"] then SetMapScale() end
end

WT.ToolConfigs["World Map Scale"] = InsertOptions
E:RegisterModule(WMS:GetName())