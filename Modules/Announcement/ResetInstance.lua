-- 修改自 InstanceResetAnnouncer
-- Novaspark-Firemaw EU (classic) / Venomisto-Frostmourne OCE (retail).
-- https://www.curseforge.com/members/venomisto/projectsd

local W, F, E, L = unpack(select(2, ...))
local A = W:GetModule("Announcement")

local pairs = pairs
local gsub, format, match = string.gsub, string.format, string.match

local msgList = {
    INSTANCE_RESET_SUCCESS = L["%s has been reset"],
    INSTANCE_RESET_FAILED = L["Cannot reset %s (There are players still inside the instance.)"],
    INSTANCE_RESET_FAILED_ZONING = L[
        "Cannot reset %s (There are players in your party attempting to zone into an instance.)"
    ],
    INSTANCE_RESET_FAILED_OFFLINE = L["Cannot reset %s (There are players offline in your party.)"]
}

function A:ResetInstance(data)
    local config = self.db.resetInstance
    if not config or not config.enable then
        return
    end

    for systemMessage, friendlyMessage in pairs(msgList) do
        systemMessage = _G[systemMessage]
        if (match(data.text, gsub(systemMessage, "%%s", ".+"))) then
            local instance = match(data.text, gsub(systemMessage, "%%s", "(.+)"))
            local prefix = config.prefix and "<WindTools> " or ""
            self:SendMessage(
                format(prefix .. friendlyMessage, instance),
                self:GetChannel(config.channel)
            )
            return
        end
    end
end