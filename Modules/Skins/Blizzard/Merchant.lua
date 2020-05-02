local W, F, E, L = unpack(select(2, ...))
local S = W:GetModule('Skins')

local _G = _G

function S:MerchantFrame()
    if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant) then return end
    if not (E.private.WT.skins.blizzard.enable and E.private.WT.skins.blizzard.merchant) then return end

    S:CreateTabShadow(_G.MerchantFrame)

    for i= 1, 2 do
		S:CreateTabShadow(_G["MerchantFrameTab"..i])
	end
end

S:AddCallback('MerchantFrame')