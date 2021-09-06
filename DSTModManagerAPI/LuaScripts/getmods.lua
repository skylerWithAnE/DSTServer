json = require "LuaScripts/json"

modOverridesFilePath = "/home/dst/.klei/DoNotStarveTogether/TheHive/Master/modoverrides.lua"
ugcModsFilePath = "/home/dst/server_dst/ugc_mods/TheHive/Master/content/322330/%s/modinfo.lua"
modsFilePath = "/home/dst/server_dst/mods/%s/modinfo.lua"
steamWorkshopUrl = "https://steamcommunity.com/sharedfiles/filedetails/?id=%s"

function stripWorkshopPreamble(id)
    local v = id
    startIndex, endIndex = string.find(v, "workshop")
    if startIndex and endIndex then
        -- why the fuck do i have to add 2??
        v = string.sub(v, endIndex+2, string.len(v))
    end
    return v
end

function getModInfo(n)
    -- mods are either in server_dst/mods, or server_dst/ugc_mods/{server name}/{Master | Caves}/content/322330/ (not sure to what the 322330 refers)
    local filePath = string.format(modsFilePath, n)
    local v, err = loadfile(filePath)
    if err ~= nil then 
        -- might refactor this to be a recursive call.
        n = stripWorkshopPreamble(n)
        v, err = loadfile(string.format(ugcModsFilePath, n))
        if (err == nil and v ~= nil) then
            v()
        end
        -- might need to check both Master and Caves for mod. Or maybe all folders under ugc_mods/{server name}/
        -- v2, err2 = loadfile(string.format("/home/dst/server_dst/ugc_mods/TheHive/Caves/content/322330/%s/modinfo.lua", n))
    else
        if v~= nil then v() end
    end
    return json.encode({name = name, description = description, author = author, version = version, allClientsRequireMod = all_clients_require_mod, priority = priority})
end

function modUrl(id)
    local v = stripWorkshopPreamble(id)
    return string.format(steamWorkshopUrl, v)
end

val, err = loadfile(modOverridesFilePath)
if (err == nil) then
    val = dofile(modOverridesFilePath)
else
    return json.encode({error = "An error occurred"})
end
i = 0
jArr = {}
for k, v in pairs(val) do
    modInfo = getModInfo(k)
    if modInfo then
        print(modInfo)
        jArr[i] = modInfo
    else
        print(string.format("Error loading a mod", k))
        print(modUrl(k))
    end
    i = i + 1
end

return jArr