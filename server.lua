local QBCore = nil
local ESX = nil
local Webhook = '' -- insert your webhook in here

-- ESX = exports["dc_core"]:getSharedObject()


local function logEvent(source)
    local src = source
    local license = GetPlayerIdentifier(src)
    local steamname = GetPlayerName(src)
    local playerTrust = false

    -- Player data
    if Config.Framework == 'qb' then
        if QBCore.Functions.HasPermission(src, 'god') or QBCore.Functions.HasPermission(src, 'admin') or QBCore.Functions.HasPermission(src, 'mod') then
            playerTrust = true
        end
    elseif Config.Framework == 'esx' then
        if ESX.GetPlayerFromId(src).getGroup() == 'admin' or ESX.GetPlayerFromId(src).getGroup() == 'mod' then
            playerTrust = true
        end
    end

    if Config.PlayerAcePermission and string.len(Config.PlayerAcePermission) > 0 and IsPlayerAceAllowed(src, Config.PlayerAcePermission) then
        playerTrust = true
    end

    -- If player is not trusted, kick them and send a log to the discord
    if not playerTrust then
        -- 1st we create the embed, this is a JSON object
        local embedData = {
            {
                ['title'] = '[DONTCRY BATTLEGROUND] Modified RPF files detected',
                ['color'] = 16711680,
                ['footer'] = {
                    ['text'] = os.date('%c'),
                },
                ['description'] = 'Player: ' .. steamname .. '\nLicense: ' .. license .. '\nSteamID: ' .. GetPlayerIdentifier(src, 1) .. '\nIP: ||' .. GetPlayerEndpoint(src) .. '||',
                ['author'] = {
                    ['name'] = 'DONTCRY BATTLEGROUND',
                    ['icon_url'] = Config.Avatar,
                },
            }
        }
        PerformHttpRequest(Webhook, function() end, 'POST', json.encode({ username = '[DONTCRY BATTLEGROUND]', embeds = embedData}), { ['Content-Type'] = 'application/json' })
        if not Config.DropStaff then
            print('^1[AntiAim] ^USING MODIFIED RPF FILES: ' .. steamname .. ' ^7')
            return
        end
        print('^1[AntiAim] ^1Player ' .. steamname .. ' has been kicked for using modified RPF files. ^7')
        -- DropPlayer(src, 'You have been kicked for using modified RPF files.')
    end
end


RegisterNetEvent('antiaim:log', function()
    if QBCore == nil and ESX == nil then
        print('^1[AntiAim] ^3Framework not found. Please check your config.lua ^7')
        return
    end
    local src = source
    logEvent(src)
end)

-- Test command, use this to test if the webhook is working
-- RegisterCommand('tWebhook', function(source, args)
--    local src = source
--    logEvent(src)
-- end)
