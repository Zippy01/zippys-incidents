AllowedUsers = {}


local function AddAllPlayersToAllowedUsers()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        AllowedUsers[tonumber(playerId)] = true
    end
end

AddEventHandler('playerDropped', function(reason)
    local playerName = GetPlayerName(source)
    print('Player ' .. playerName .. ' Removing from AllowedUsers')
    AllowedUsers[source] = nil  -- Remove the player from the AllowedUsers list
end)

local function OnPlayerConnecting(name)
    print("Player connecting: " .. name .. " Adding to allow by default")
    AllowedUsers[source] = true  -- Add the player to the AllowedUsers list
end

RegisterNetEvent('Waze:toggle')
AddEventHandler('Waze:toggle', function()
    local playerName = GetPlayerName(source)
    print("Toggling user in AllowedUsers: " .. playerName)

    if AllowedUsers[source] then
        AllowedUsers[source] = nil  -- Remove the user from the list if they are already there
        print("User removed from AllowedUsers list: " .. playerName)
    else
        AllowedUsers[source] = true  -- Add the user to the list
        print("User added to AllowedUsers list: " .. playerName)
    end
end)

RegisterNetEvent('Waze:Report')
AddEventHandler('Waze:Report', function(postal, street, arg)
    print("Handling a Waze report for postal: " .. postal .. " and street: " .. street)
    for playerId, allowed in pairs(AllowedUsers) do
        local rgb, textc

        if arg == "Police" then
            rgb = {93, 182, 229}
            textc = "~b~"
        elseif arg == "Crash" then
            rgb = {224, 50, 50}
            textc = "~r~"
        elseif arg == "Hazard" then
            rgb = {240, 200, 80}
            textc = "~y~"
        else
            print("Invalid argument: " .. arg .. " WE DIDN'T PREPARE FOR THIS ONE?!")
            rgb = {255, 0, 0}
            textc = "~r~"
        end

        if allowed then
            TriggerClientEvent('chat:addMessage', playerId, {
                color = rgb,
                multiline = true,
                args = {"[Waze Traffic Alerts]", arg .. " spotted near " .. textc .. postal .. " " .. street .. "~s~. Slow down when approaching the area."}
            })
        end
    end
end)

RegisterNetEvent('Waze:CreateBlip')
AddEventHandler('Waze:CreateBlip', function(x, y, z, icon, color, label, cleanup)
    print("Creating a blip from the server side, only allowed clients should receive it.")
    for playerId, allowed in pairs(AllowedUsers) do
        if allowed then
            TriggerClientEvent('Waze:CreateBlip', playerId, x, y, z, icon, color, label, cleanup)
        end
    end
end)

AddEventHandler("playerConnecting", OnPlayerConnecting)

AddAllPlayersToAllowedUsers()