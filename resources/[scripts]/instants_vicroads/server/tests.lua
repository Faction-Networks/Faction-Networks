-- Track test progress for players
local testProgress = {}
-- Format: testProgress[identifier] = { license = 'driver', theoryPassed = true, practicalPassed = false }

-- Function to clear test progress for a license
function ClearTestProgress(identifier, license)
    if testProgress[identifier] and testProgress[identifier][license] then
        testProgress[identifier][license] = nil
    end
end

exports('ClearTestProgress', ClearTestProgress)

-- Helper: read charinfo from players table and return parsed table (or nil)
local function getPlayersCharinfo(identifier)
    local cols = MySQL.query.await("SELECT COLUMN_NAME FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'players'")
    local colMap = {}
    if cols and #cols > 0 then for _, c in ipairs(cols) do colMap[c.COLUMN_NAME] = true end end
    local candidates = { 'identifier', 'citizenid', 'steam', 'license', 'owner' }
    local col = nil
    for _, c in ipairs(candidates) do if colMap[c] then col = c break end end
    if not col then return nil end
    local row = MySQL.single.await(("SELECT charinfo FROM players WHERE %s = ? LIMIT 1"):format(col), { identifier })
    if row and row.charinfo then
        local ok, pci = pcall(json.decode, row.charinfo)
        if ok and pci then return pci end
    end
    return nil
end

-- Helper: determine if parsed charinfo contains the license
local function charinfoHasLicense(pci, license)
    if not pci then return false end
    -- common patterns
    local checkList = { pci.licenses, pci.license, pci.driver_license, pci.driverlicense }
    for _, v in ipairs(checkList) do
        if not v then goto cont end
        if type(v) == 'table' then
            for k, val in pairs(v) do
                if type(k) == 'number' then
                    if tostring(val) == license then return true end
                else
                    if tostring(k) == license then
                        if val == true or val == 1 or type(val) == 'table' then return true end
                    end
                end
            end
        elseif type(v) == 'string' then
            for item in v:gmatch('[^,]+') do if item:match(license) then return true end end
        elseif type(v) == 'number' then
            if tostring(v) == license then return true end
        end
        ::cont::
    end

    -- fallback: sometimes licenses stored as keys on top-level
    for k, val in pairs(pci) do
        if tostring(k):lower():match('license') or tostring(k):lower():match('driver') then
            if type(val) == 'string' and val:match(license) then return true end
            if type(val) == 'table' then
                for kk, vv in pairs(val) do
                    if tostring(kk) == license or tostring(vv) == license then return true end
                end
            end
        end
    end

    return false
end

-- Update players.charinfo using a modifier function (synchronous)
local function updatePlayersCharinfo(identifier, modifier)
    local cols = MySQL.query.await("SELECT COLUMN_NAME FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'players'")
    local colMap = {}
    if cols and #cols > 0 then for _, c in ipairs(cols) do colMap[c.COLUMN_NAME] = true end end
    local candidates = { 'identifier', 'citizenid', 'steam', 'license', 'owner' }
    local col = nil
    for _, c in ipairs(candidates) do if colMap[c] then col = c break end end
    if not col then return false end

    local row = MySQL.single.await(("SELECT charinfo FROM players WHERE %s = ? LIMIT 1"):format(col), { identifier })
    local pci = nil
    if row and row.charinfo then
        local ok, decoded = pcall(json.decode, row.charinfo)
        if ok and decoded then pci = decoded end
    end

    local newpci = modifier(pci) or pci
    if not newpci then return false end
    local ok2, encoded = pcall(json.encode, newpci)
    if not ok2 then return false end

    MySQL.execute.await(("UPDATE players SET charinfo = ? WHERE %s = ?"):format(col), { encoded, identifier })
    return true
end

-- Add license entry into players.charinfo (non-destructive)
local function addLicenseToPlayersCharinfo(identifier, license, expiry)
    return updatePlayersCharinfo(identifier, function(pci)
        pci = pci or {}
        if type(pci.licenses) == 'string' then
            local t = {}
            for item in pci.licenses:gmatch('[^,]+') do t[item] = true end
            pci.licenses = t
        end
        pci.licenses = pci.licenses or {}
        pci.licenses[license] = true
        pci.licenses_expiry = pci.licenses_expiry or {}
        if expiry then pci.licenses_expiry[license] = tostring(expiry) end
        return pci
    end)
end

-- Remove license entry from players.charinfo
local function removeLicenseFromPlayersCharinfo(identifier, license)
    return updatePlayersCharinfo(identifier, function(pci)
        if not pci then return pci end
        if type(pci.licenses) == 'string' then
            local t = {}
            for item in pci.licenses:gmatch('[^,]+') do t[item] = true end
            pci.licenses = t
        end
        if pci.licenses and pci.licenses[license] then
            pci.licenses[license] = nil
        end
        if pci.licenses_expiry and pci.licenses_expiry[license] then
            pci.licenses_expiry[license] = nil
        end
        return pci
    end)
end

exports('RemoveLicenseFromPlayersCharinfo', removeLicenseFromPlayersCharinfo)
exports('AddLicenseToPlayersCharinfo', addLicenseToPlayersCharinfo)

-- Helper: convenience check; players.charinfo is the single source of truth
local function playerHasLicense(identifier, license)
    local pci = getPlayersCharinfo(identifier)
    if pci and charinfoHasLicense(pci, license) then
        return true
    end
    return false
end

-- Function to parse question strings if they are in multi-line format
local function parseQuestion(q)
    if type(q) == 'string' then
        local lines = {}
        for line in q:gmatch("[^\r\n]+") do
            if line:match("%S") then
                table.insert(lines, line)
            end
        end
        
        local question = lines[1]
        local answers = {}
        local correctIndex = 0
        
        for i = 2, #lines do
            if i == #lines then
                -- Last line could be the answer
                local answerText = lines[i]
                -- Find which answer matches
                for j = 2, #lines - 1 do
                    if lines[j] == answerText then
                        correctIndex = j - 2 -- zero-based
                        break
                    end
                end
                -- If no match found, check if it's a number
                if correctIndex == 0 and tonumber(answerText) then
                    correctIndex = tonumber(answerText)
                end
            else
                table.insert(answers, lines[i])
            end
        end
        
        return {
            question = question,
            answers = answers,
            correct = correctIndex
        }
    else
        return q
    end
end

-- Get questions for a license type
RegisterNetEvent('vn_vicroads:getQuestions', function(license)
    local src = source
    local identifier = Framework.GetIdentifier(src)
    
    if not Config.Licenses[license] or not Config.Licenses[license].questions then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'No questions available for this license',
            type = 'error'
        })
        return
    end
    
    -- Check if player already has this license
    if playerHasLicense(identifier, license) then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'You already have this license',
            type = 'error'
        })
        return
    end
    
    local questions = {}
    for _, q in ipairs(Config.Licenses[license].questions) do
        local parsed = parseQuestion(q)
        table.insert(questions, {
            question = parsed.question,
            answers = parsed.answers
        })
    end
    
    TriggerClientEvent('vn_vicroads:receiveQuestions', src, license, questions)
end)

-- Function to send licenses to client
local function sendLicensesToClient(src)
    local identifier = Framework.GetIdentifier(src)
    -- Prefer licenses stored on the players table (charinfo)
    local licenseList = {}
    local pci = getPlayersCharinfo(identifier)
    if pci then
        local function addLicenseName(name)
            if not name then return end
            local licConfig = Config.Licenses[name]
            table.insert(licenseList, {
                type = name,
                label = licConfig and licConfig.label or name,
                expiry = (pci.licenses_expiry and pci.licenses_expiry[name]) or nil,
                status = 'active',
                statusexpiry = nil,
                demerit_points = 0
            })
        end

        if pci.licenses then
            if type(pci.licenses) == 'table' then
                for k, v in pairs(pci.licenses) do
                    if type(k) == 'number' then
                        addLicenseName(v)
                    else
                        addLicenseName(k)
                    end
                end
            elseif type(pci.licenses) == 'string' then
                for item in pci.licenses:gmatch('[^,]+') do addLicenseName(item) end
            end
        end
        -- also check other common fields
        if pci.license and type(pci.license) == 'string' then addLicenseName(pci.license) end
        if pci.driver_license and type(pci.driver_license) == 'string' then addLicenseName(pci.driver_license) end
    end

    -- Rely on players.charinfo as source of truth
    
    -- Load test progress from DB
    local dbProgress = MySQL.query.await('SELECT license, theoryPassed, practicalPassed FROM vicroads_testprogress WHERE identifier = ?', { identifier })
    local progress = {}
    if dbProgress then
        for _, row in ipairs(dbProgress) do
            progress[row.license] = {
                theoryPassed = row.theoryPassed == 1 or row.theoryPassed == true,
                practicalPassed = row.practicalPassed == 1 or row.practicalPassed == true
            }
            -- Also update in-memory for current session
            if not testProgress[identifier] then testProgress[identifier] = {} end
            testProgress[identifier][row.license] = {
                theoryPassed = row.theoryPassed == 1 or row.theoryPassed == true,
                practicalPassed = row.practicalPassed == 1 or row.practicalPassed == true
            }
        end
    end
    
    TriggerClientEvent('vn_vicroads:sendLicenses', src, licenseList, progress)
end

RegisterNetEvent('vn_vicroads:getLicenses', function()
    sendLicensesToClient(source)
end)

RegisterNetEvent('vn_vicroads:submitTest', function(license, answers)
    local src = source
    local identifier = Framework.GetIdentifier(src)

    if not Config.Licenses[license] or not Config.Licenses[license].questions then
        return
    end
    
    -- Check if player already has this license
    if playerHasLicense(identifier, license) then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'You already have this license',
            type = 'error'
        })
        TriggerClientEvent('vn_vicroads:testResult', src, { passed = false, score = 0, license = license, alreadyOwned = true })
        return
    end
    
    local questions = Config.Licenses[license].questions
    
    local correct = 0
    for i, q in ipairs(questions) do
        local parsed = parseQuestion(q)
        if answers[i] == parsed.correct then 
            correct += 1 
        end
    end

    local score = math.floor((correct / #questions) * 100)
    local passed = score >= Config.Licenses[license].passMark

    if passed then
        -- Initialize test progress
        if not testProgress[identifier] then
            testProgress[identifier] = {}
        end
        testProgress[identifier][license] = {
            theoryPassed = true,
            practicalPassed = false
        }
        -- Persist theoryPassed in DB
        MySQL.insert.await(
            'INSERT INTO vicroads_testprogress (identifier, license, theoryPassed, practicalPassed) VALUES (?, ?, TRUE, FALSE) ON DUPLICATE KEY UPDATE theoryPassed = TRUE',
            { identifier, license }
        )
        -- Theory test passed
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'Theory Test Passed - Score: ' .. score .. '%\nNow complete the Practical Test to receive your license.',
            type = 'success'
        })
    else
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'Test Failed - Score: ' .. score .. '% - Please try again',
            type = 'error'
        })
    end
    
    -- Send test result to client
    TriggerClientEvent('vn_vicroads:testResult', src, { passed = passed, score = score, license = license })
end)

-- Complete practical test and give license
RegisterNetEvent('vn_vicroads:completePracticalTest', function(license, success, errors)
    local src = source
    local identifier = Framework.GetIdentifier(src)
    
    if not Config.Licenses[license] then return end
    
    if success then
        -- Check if theory test was passed first
        if not testProgress[identifier] or not testProgress[identifier][license] or not testProgress[identifier][license].theoryPassed then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'VicRoads',
                description = 'You must complete the Theory Test first!',
                type = 'error'
            })
            return
        end
        
        -- Check if player already has license
        if playerHasLicense(identifier, license) then
            TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
                title = 'VicRoads',
                description = 'You already have this license',
                type = 'error'
            })
            return
        end
        
        -- Mark practical test as passed
        testProgress[identifier][license].practicalPassed = true
        
        -- Both tests passed, give license
        Framework.RemoveMoney(src, Config.Licenses[license].price)
        
        -- Persist license into players.charinfo as single source of truth
        local expiry = os.date('%Y-%m-%d %H:%M:%S', os.time() + (30 * 24 * 60 * 60))
        pcall(function()
            addLicenseToPlayersCharinfo(identifier, license, expiry)
        end)
        
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'VicRoads',
            description = 'Both tests passed! License issued.',
            type = 'success'
        })
        
        -- Clear test progress
        testProgress[identifier][license] = nil
        
        -- Refresh licenses
        sendLicensesToClient(src)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'VicRoads',
            description = 'Practical Test Failed - Errors: ' .. errors .. '\nPlease try again.',
            type = 'error'
        })
    end
end)

-- Request to start practical test (with validation)
RegisterNetEvent('vn_vicroads:requestPracticalTest', function(license)
    local src = source
    local identifier = Framework.GetIdentifier(src)
    
    if not Config.Licenses[license] then return end
    
    -- Check if theory test was passed
    if not testProgress[identifier] or not testProgress[identifier][license] or not testProgress[identifier][license].theoryPassed then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'You must complete the Theory Test first!',
            type = 'error'
        })
        return
    end
    
    -- Check if they already have the license
    if playerHasLicense(identifier, license) then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'You already have this license',
            type = 'error'
        })
        return
    end
    
    -- Theory test passed, start practical test
    TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
        title = 'VicRoads',
        description = 'Starting practical driving test...',
        type = 'info'
    })
    
    TriggerClientEvent('vn_vicroads:startPracticalTest', src, license)
end)

-- Purchase physical license card
RegisterNetEvent('vn_vicroads:purchaseCard', function(data)
    local src = source
    local identifier = Framework.GetIdentifier(src)
    local license = data.license
    local paymentMethod = data.paymentMethod or 'cash'
    

    -- Check if player has this license
    if not playerHasLicense(identifier, license) then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'You do not have a valid ' .. license .. ' license',
            type = 'error'
        })
        return
    end
    
    -- Remove $500 from selected payment method
    local success = Framework.RemoveMoney(src, 500, paymentMethod)
    
    if not success then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'Insufficient funds',
            type = 'error'
        })
        return
    end
    
    -- Get license metadata if qbx_idcard is available
    local metadata = nil
    if GetResourceState('qbx_idcard') == 'started' then
        metadata = exports.qbx_idcard:GetMetaLicense(src, {'driver_license'})
    end
    
    -- Give physical card item
    local itemSuccess = Framework.AddItem(src, 'driver_license', 1, metadata)
    
    if itemSuccess then
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'License card purchased for $500',
            type = 'success'
        })
    else
        TriggerClientEvent('vn_vicroads:notifyAndClose', src, {
            title = 'VicRoads',
            description = 'Failed to give license card',
            type = 'error'
        })
        -- Refund the money
        if Framework.type == 'qb' then
            local Player = Framework.core.Functions.GetPlayer(src)
            if Player then
                Player.Functions.AddMoney(paymentMethod, 500)
            end
        end
    end
end)
