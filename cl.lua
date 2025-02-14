local wazevisble = true  -- Variable to track visibility of the chat notis

RegisterCommand('waze', function(source, args)
    local arg = args[1]

    local ped = PlayerPedId() -- Get the player's ped ID
    local x, y, z = table.unpack(GetEntityCoords(ped, false))  -- Get the player's coordinates
    local street = exports["tlrp-locations"]:getStreetName() -- Get the street name using the tlrp-locations resource
    local postal = exports["ImperialLocation"]:getPostal()  -- Get the postal code using the ImperialLocation resource
    local cleanup = Config.timer or 300000  -- Default to 5 minutes if not set in config
    local label = nil -- Set the label based on the command argument
    local icon = nil
    local color = nil

    if arg == "police" then
        label = Config.Speedlabel  -- Set the label to "Speed Trap"
        icon = 3
        arg = "Police"
    elseif arg == "crash" then
        label = Config.CrashLabel  -- Set the label to "Crash"
        icon = 380
        color = 59
        arg = "Crash"
    elseif arg == "hazard" then
        label = Config.HazardLabel  -- Set the label to "Hazard"
        icon = 653
        color = 81
        arg = "Hazard"
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Waze Traffic Alerts]", "Invalid argument. Use /waze police, /waze crash, or /waze hazard."}
        })
        return
    end

    -- Send the blip information to the server
    TriggerServerEvent('Waze:CreateBlip', x, y, z, icon, color, label, cleanup)
    TriggerServerEvent('Waze:Report', postal, street, arg)
end, false)

-- Listen for the server event to create the blip on the client
RegisterNetEvent('Waze:CreateBlip')
AddEventHandler('Waze:CreateBlip', function(x, y, z, icon, color, label, cleanup)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, icon)  -- Icon for speed trap

    if icon == 3 then
        SetBlipScale(blip, 0.7)  -- Scale for speed trap blip
    else
        SetBlipScale(blip, 1.0)  -- Scale for other blips
    end

    if color then
        SetBlipColour(blip, color)
    end

    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)  -- String for the blip name defined by the config key "label"
    EndTextCommandSetBlipName(blip)

    Citizen.SetTimeout(cleanup, function()  -- Cleanup after the specified time
        print("Removing blip after timeout")
        RemoveBlip(blip)
    end)
end)

RegisterCommand('twaze', function()

    TriggerEvent('chat:addSuggestion', '/twaze', 'Toggle the visibility of Waze alerts')

    if wazevisble then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[Waze Traffic Alerts]", "You have hidden the Waze alerts."}
        })
        wazevisble = false
        TriggerServerEvent('Waze:toggle', source)
    else
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[Waze Traffic Alerts]", "You have shown the Waze alerts."}
        })
        wazevisble = true
        TriggerServerEvent('Waze:toggle', source)
    end

end, false)