AllowedUsers = {}

AddEventHandler('playerDropped', function (reason, resourceName, clientDropReason)
    print('Player ' .. GetPlayerName(source) .. ' Removing from OnlineUsers')
    table.remove(AllowedUsers, source)  -- Remove the player from the OnlineUsers list
end)

local function OnPlayerConnecting(name)
    print("Player connecting: " .. name .. " Adding to allow by default")
    table.insert(AllowedUsers, source)  -- Add the player to the OnlineUsers list
end

RegisterNetEvent('Waze:toggle')
AddEventHandler('Waze:toggle', function()
print("Removing user from AllowedUsers: " .. GetPlayerName(source))

    if AllowedUsers[source] then
        AllowedUsers[source] = nil  -- Remove the user from the list if they are already there
        print("User removed from AllowedUsers list: " .. GetPlayerName(source))
    else
        AllowedUsers[source] = true  -- Add the user to the list
        print("User added to AllowedUsers list: " .. GetPlayerName(source))
    end
    
end)

RegisterNetEvent('Waze:Report')
AddEventHandler('Waze:Report', function(postal, street, arg)
    print("Handling a Waze report for postal: " .. postal .. " and street: " .. street)
    for playerId, allowed in pairs(AllowedUsers) do

        local rgb = nil
        local textc = nil

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
            print("Invalid argument: " .. arg .. "WE DIDN'T PREPARE FOR THIS ONE?!")
            rgb = {255, 0, 0}
            textc = "~r~"
        end

        if allowed then
            TriggerClientEvent('chat:addMessage', playerId, {
                color = rgb,
                multiline = true,
                args = {"[Waze Traffic Alerts]", arg .. " spotted near " .. textc .. postal .. " " .. street .. "~s~.  Slow down when approaching the area."}
            })
        end
    end
end)

AddEventHandler("playerConnecting", OnPlayerConnecting)