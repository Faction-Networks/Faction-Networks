-- Server handlers for vn_vicroads

-- Function to check if location is open
local function isLocationOpen(location)
    if not location.openHours then return true end
    
    local hour = os.date('*t').hour
    local openHour = location.openHours.open
    local closeHour = location.openHours.close
    
    -- Handle 24/7 locations
    if openHour == 0 and closeHour == 24 then
        return true
    end
    
    -- Handle times that cross midnight
    if closeHour < openHour then
        return hour >= openHour or hour < closeHour
    end
    
    -- Normal hours
    return hour >= openHour and hour < closeHour
end

RegisterNetEvent('vn_vicroads:requestName', function()
    local src = source
    
    -- Check if player is near an open location
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local nearOpenLocation = false
    
    for _, location in ipairs(Config.Locations) do
        local distance = #(playerCoords - vector3(location.coords.x, location.coords.y, location.coords.z))
        if distance < 5.0 then -- Within 5 meters
            if isLocationOpen(location) then
                nearOpenLocation = true
                break
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = 'VicRoads',
                    description = string.format('This office is closed. Open hours: %02d:00 - %02d:00 AEDT', location.openHours.open, location.openHours.close),
                    type = 'error'
                })
                return
            end
        end
    end
    
    if not nearOpenLocation then
        return
    end
    
    local name = nil
    local dob = nil

    local identifiers = GetPlayerIdentifiers(src) or {}
    local identifier = identifiers[1]

    local function finish()
        if not name or name == '' then
            -- fallback to game-provided player name
            local okName = GetPlayerName(src)
            name = name or okName or ('Player '..tostring(src))
        end
        TriggerClientEvent('vn_vicroads:openWithName', src, { name = name, dob = dob })
    end

    -- Try framework-provided character data first (QB/ESX)
    local function tryFramework()
        -- QBCore
        if exports and exports['qb-core'] then
            local ok, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
            if ok and QBCore then
                local suc, player = pcall(function() return QBCore.Functions.GetPlayer(src) end)
                if suc and player and player.PlayerData and player.PlayerData.charinfo then
                    local ci = player.PlayerData.charinfo
                    if type(ci) == 'table' then
                        name = ((ci.firstname or '') .. ' ' .. (ci.lastname or '')):gsub('%s+$','')
                        dob = dob or ci.birthdate or ci.dateofbirth or ci.dob
                        return true
                    elseif type(ci) == 'string' then
                        local ok2, parsed = pcall(json.decode, ci)
                        if ok2 and parsed then
                            name = ((parsed.firstname or '') .. ' ' .. (parsed.lastname or '')):gsub('%s+$','')
                            dob = dob or parsed.birthdate or parsed.dateofbirth or parsed.dob
                            return true
                        end
                    end
                end
            end
        end

        -- ESX
        -- ESX (try common exported methods)
        local esxFound = false
        if exports and exports['es_extended'] then
            esxFound = true
            local ok, x = pcall(function() return exports['es_extended'] end)
            if ok and x and x.GetPlayerFromId then
                local suc, xPlayer = pcall(function() return x.GetPlayerFromId(src) end)
                if suc and xPlayer then
                    if xPlayer.getName then name = name or xPlayer.getName() end
                    if xPlayer.get then dob = dob or (xPlayer.get('dateofbirth') or xPlayer.get('birthdate') or xPlayer.get('dob')) end
                    return true
                end
            end
        end
        -- try global ESX variable fallback
        if not esxFound and _G and _G.ESX then
            local suc, xPlayer = pcall(function() return _G.ESX.GetPlayerFromId and _G.ESX.GetPlayerFromId(src) end)
            if suc and xPlayer then
                if xPlayer.getName then name = name or xPlayer.getName() end
                if xPlayer.get then dob = dob or (xPlayer.get('dateofbirth') or xPlayer.get('birthdate') or xPlayer.get('dob')) end
                return true
            end
        end

        return false
    end

    if tryFramework() then finish() return end

    if identifier and exports and exports.oxmysql then
        local function queryPlayersCharinfo(cb)
            exports.oxmysql:execute("SELECT COLUMN_NAME FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = @t", { ['@t'] = 'players' }, function(cols)
                local colMap = {}
                if cols and #cols > 0 then for _, c in ipairs(cols) do colMap[c.COLUMN_NAME] = true end end
                local candidates = { 'identifier', 'citizenid', 'steam', 'license', 'owner' }
                local col = nil
                for _, c in ipairs(candidates) do if colMap[c] then col = c break end end
                if not col then cb(nil) return end
                local query = ("SELECT charinfo FROM players WHERE %s = @id LIMIT 1"):format(col)
                exports.oxmysql:execute(query, { ['@id'] = identifier }, function(res)
                    cb(res)
                end)
            end)
        end
        -- check if `users` table exists and which columns it has, then query only existing columns
        exports.oxmysql:execute("SELECT TABLE_NAME FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = @t", { ['@t'] = 'users' }, function(tbl)
            if not tbl or #tbl == 0 then
                -- no users table; try players
                queryPlayersCharinfo(function(res2)
                    if res2 and res2[1] and res2[1].charinfo then
                        local ok2, pci = pcall(json.decode, res2[1].charinfo)
                        if ok2 and pci then
                            if (pci.firstname or pci.lastname) then
                                name = ((pci.firstname or '') .. ' ' .. (pci.lastname or '')):gsub('%s+$','')
                            elseif pci.name then
                                name = pci.name
                            end
                            dob = dob or pci.birthdate or pci.dateofbirth or pci.dob
                        end
                    end
                    finish()
                end)
                return
            end

            -- get columns present on users table
            exports.oxmysql:execute("SELECT COLUMN_NAME FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = @t", { ['@t'] = 'users' }, function(cols)
                local colsMap = {}
                if cols and #cols > 0 then for _, c in ipairs(cols) do colsMap[c.COLUMN_NAME] = true end end
                -- build select list from known candidate columns
                local candidates = { 'charinfo', 'dateofbirth', 'birthdate', 'dob', 'name', 'firstname', 'lastname' }
                local selectCols = {}
                for _, c in ipairs(candidates) do if colsMap[c] then table.insert(selectCols, c) end end

                if #selectCols == 0 then
                    -- nothing useful to select; fallback to players
                    queryPlayersCharinfo(function(res2)
                        if res2 and res2[1] and res2[1].charinfo then
                            local ok2, pci = pcall(json.decode, res2[1].charinfo)
                            if ok2 and pci then
                                print('vn_vicroads:requestName -> parsed charinfo from players')
                                if (pci.firstname or pci.lastname) then
                                    name = ((pci.firstname or '') .. ' ' .. (pci.lastname or '')):gsub('%s+$','')
                                elseif pci.name then
                                    name = pci.name
                                end
                                dob = dob or pci.birthdate or pci.dateofbirth or pci.dob
                            end
                        end
                        finish()
                    end)
                    return
                end

                local sel = table.concat(selectCols, ', ')
                local query = ("SELECT %s FROM users WHERE identifier = @id LIMIT 1"):format(sel)
                exports.oxmysql:execute(query, { ['@id'] = identifier }, function(res)
                    if res and res[1] then
                        local row = res[1]
                        -- prefer simple name columns
                        if row.name and row.name ~= '' then name = row.name end
                        if row.firstname or row.lastname then name = ((row.firstname or '') .. ' ' .. (row.lastname or '')):gsub('%s+$','') end
                        dob = dob or row.dateofbirth or row.birthdate or row.dob
                        if (not name or name == '') and row.charinfo then
                            local ok, ci = pcall(json.decode, row.charinfo)
                            if ok and ci then
                                if (ci.firstname or ci.lastname) then
                                    name = ((ci.firstname or '') .. ' ' .. (ci.lastname or '')):gsub('%s+$','')
                                elseif ci.name then
                                    name = ci.name
                                end
                                dob = dob or ci.birthdate or ci.dateofbirth or ci.dob
                            end
                        end
                    end

                    if name and name ~= '' then
                        finish()
                        return
                    end

                    -- final fallback: players charinfo
                    queryPlayersCharinfo(function(res2)
                        if res2 and res2[1] and res2[1].charinfo then
                            local ok2, pci = pcall(json.decode, res2[1].charinfo)
                            if ok2 and pci then
                                print('vn_vicroads:requestName -> parsed charinfo from players')
                                if (pci.firstname or pci.lastname) then
                                    name = ((pci.firstname or '') .. ' ' .. (pci.lastname or '')):gsub('%s+$','')
                                elseif pci.name then
                                    name = pci.name
                                end
                                dob = dob or pci.birthdate or pci.dateofbirth or pci.dob
                            end
                        end
                        finish()
                    end)
                end)
            end)
        end)
    else
        -- no oxmysql or no identifier: try framework or client fallback
        finish()
    end
end)

-- client-provided name fallback
RegisterNetEvent('vn_vicroads:clientOpenWithName', function(name)
    local src = source
    TriggerClientEvent('vn_vicroads:openWithName', src, { name = name })
end)

-- Cancel license
RegisterNetEvent('vn_vicroads:cancelLicense', function(license)
    local src = source
    local identifier = Framework.GetIdentifier(src)
    if not identifier then return end
    -- Remove from players.charinfo via exported helper
    if exports and exports['instants_vicroads'] and exports['instants_vicroads'].RemoveLicenseFromPlayersCharinfo then
        pcall(function()
            exports['instants_vicroads']:RemoveLicenseFromPlayersCharinfo(identifier, license)
        end)
    end
    
    -- Clear test progress for this license
    exports['vn_vicroads']:ClearTestProgress(identifier, license)
    
    lib.notify(src, {
        title = 'VicRoads',
        description = 'License cancelled successfully',
        type = 'success'
    })
    
    -- Refresh licenses by triggering the name request again
    TriggerEvent('vn_vicroads:requestName', src)
end)
