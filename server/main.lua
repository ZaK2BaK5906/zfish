ESX = exports["es_extended"]:getSharedObject()

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

local function GetPlayerFishingData(identifier)
    local result = MySQL.query.await('SELECT * FROM player_fishing WHERE identifier = ?', {identifier})

    if result and #result > 0 then
        return result[1]
    else
        MySQL.insert('INSERT INTO player_fishing (identifier, level, xp) VALUES (?, ?, ?)', {
            identifier, 1, 0
        })
        return {
            identifier = identifier,
            level = 1,
            xp = 0,
            total_fish_caught = 0,
            biggest_fish_weight = 0,
            biggest_fish_name = nil,
            legendary_caught = 0,
            epic_caught = 0,
            rare_caught = 0,
            uncommon_caught = 0,
            common_caught = 0
        }
    end
end

local function CalculateLevel(xp)
    local level = 1
    for i = Config.MaxLevel, 1, -1 do
        if xp >= Config.Levels[i].xp then
            level = i
            break
        end
    end
    return level
end

local function GetNextLevelXP(currentLevel)
    if currentLevel >= Config.MaxLevel then
        return Config.Levels[Config.MaxLevel].xp
    end
    return Config.Levels[currentLevel + 1].xp
end

local function UpdatePlayerStats(identifier, fishData, fishWeight, fishRarity)
    local rarityColumn = string.lower(fishRarity) .. '_caught'

    MySQL.update([[
        UPDATE player_fishing
        SET
            total_fish_caught = total_fish_caught + 1,
            biggest_fish_weight = GREATEST(biggest_fish_weight, ?),
            biggest_fish_name = IF(? > biggest_fish_weight, ?, biggest_fish_name),
            ]] .. rarityColumn .. [[ = ]] .. rarityColumn .. [[ + 1
        WHERE identifier = ?
    ]], {fishWeight, fishWeight, fishData.label, identifier})
end

-- =====================================================
-- ÉVÉNEMENTS SERVEUR
-- =====================================================

ESX.RegisterServerCallback('zfish:getPlayerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end

    local data = GetPlayerFishingData(xPlayer.identifier)
    cb(data)
end)

ESX.RegisterServerCallback('zfish:getFishingHistory', function(source, cb, limit)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end

    local history = MySQL.query.await(
        'SELECT * FROM player_fishing_history WHERE identifier = ? ORDER BY caught_at DESC LIMIT ?',
        {xPlayer.identifier, limit or 50}
    )

    cb(history)
end)

ESX.RegisterServerCallback('zfish:checkItems', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({hasRod = false, hasBait = false}) end

    local hasRod = false
    local hasBait = false
    local rodItem = nil
    local baitItem = nil

    -- Vérifier les cannes
    for _, rod in pairs(Config.FishingRods) do
        local count = exports.ox_inventory:GetItemCount(source, rod.item)
        if count and count > 0 then
            hasRod = true
            rodItem = rod.item
            break
        end
    end

    -- Vérifier les appâts
    for _, bait in pairs(Config.Baits) do
        local count = exports.ox_inventory:GetItemCount(source, bait.item)
        if count and count > 0 then
            hasBait = true
            baitItem = bait.item
            break
        end
    end

    cb({
        hasRod = hasRod,
        hasBait = hasBait,
        rodItem = rodItem,
        baitItem = baitItem
    })
end)

-- Démarrer la pêche
RegisterNetEvent('zfish:startFishing')
AddEventHandler('zfish:startFishing', function(baitItem)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Vérifier et retirer l'appât
    local baitCount = exports.ox_inventory:GetItemCount(source, baitItem)
    if not baitCount or baitCount <= 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Messages.noBait
        })
        return
    end

    exports.ox_inventory:RemoveItem(source, baitItem, 1)
end)

-- Demander le mini-jeu
RegisterNetEvent('zfish:requestMinigame')
AddEventHandler('zfish:requestMinigame', function(baitItem, rodItem)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Obtenir les données du joueur
    local playerData = GetPlayerFishingData(xPlayer.identifier)
    local playerLevel = playerData.level

    -- Obtenir les informations de l'appât
    local baitData = nil
    for _, bait in pairs(Config.Baits) do
        if bait.item == baitItem then
            baitData = bait
            break
        end
    end

    if not baitData then return end

    -- Créer une liste de poissons possibles (légaux + illégaux)
    local allFish = {}
    for _, fish in pairs(Config.Fish) do
        table.insert(allFish, fish)
    end
    for _, fish in pairs(Config.IllegalFish) do
        table.insert(allFish, fish)
    end

    -- Filtrer les poissons disponibles
    local possibleFish = {}
    for _, fish in pairs(allFish) do
        if playerLevel >= fish.requiredLevel then
            local baitCompatible = false
            for _, compatibleBait in pairs(fish.requiredBait) do
                if compatibleBait == baitItem then
                    baitCompatible = true
                    break
                end
            end

            if baitCompatible then
                local modifiedChance = fish.chance * baitData.multiplier
                table.insert(possibleFish, {
                    data = fish,
                    chance = modifiedChance
                })
            end
        end
    end

    if #possibleFish == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Aucun poisson disponible avec cet appât'
        })
        return
    end

    -- Sélectionner un poisson aléatoire
    local totalChance = 0
    for _, fish in pairs(possibleFish) do
        totalChance = totalChance + fish.chance
    end

    local random = math.random() * totalChance
    local cumulativeChance = 0
    local selectedFish = nil

    for _, fish in pairs(possibleFish) do
        cumulativeChance = cumulativeChance + fish.chance
        if random <= cumulativeChance then
            selectedFish = fish.data
            break
        end
    end

    if not selectedFish then
        selectedFish = possibleFish[1].data
    end

    -- Stocker temporairement le poisson sélectionné
    if not GlobalState.pendingFish then
        GlobalState.pendingFish = {}
    end
    GlobalState.pendingFish[source] = {
        fish = selectedFish,
        baitItem = baitItem,
        rodItem = rodItem,
        baitData = baitData
    }

    -- Envoyer le mini-jeu au client
    TriggerClientEvent('zfish:showMinigame', source, selectedFish, baitItem, rodItem)
end)

-- Attraper un poisson (après mini-jeu réussi)
RegisterNetEvent('zfish:catchFish')
AddEventHandler('zfish:catchFish', function(baitItem, rodItem)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Récupérer le poisson en attente
    local pending = GlobalState.pendingFish and GlobalState.pendingFish[source]
    if not pending then return end

    local selectedFish = pending.fish
    local baitData = pending.baitData

    -- Nettoyer les données en attente
    GlobalState.pendingFish[source] = nil

    -- Générer le poids du poisson
    local fishWeight = math.random(selectedFish.weight.min, selectedFish.weight.max)

    -- Calculer l'XP avec bonus d'appât
    local xpGained = selectedFish.xpReward + baitData.xpBonus

    -- Ajouter le poisson à l'inventaire
    local success = exports.ox_inventory:AddItem(source, selectedFish.item, 1, {
        weight = fishWeight,
        description = string.format('Poids: %dg', fishWeight)
    })

    if not success then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Inventaire plein !'
        })
        return
    end

    -- Obtenir les données du joueur
    local playerData = GetPlayerFishingData(xPlayer.identifier)

    -- Mettre à jour l'XP
    local newXP = playerData.xp + xpGained
    local oldLevel = playerData.level
    local newLevel = CalculateLevel(newXP)

    MySQL.update('UPDATE player_fishing SET xp = ?, level = ? WHERE identifier = ?', {
        newXP, newLevel, xPlayer.identifier
    })

    -- Mettre à jour les stats
    UpdatePlayerStats(xPlayer.identifier, selectedFish, fishWeight, selectedFish.rarity)

    -- Ajouter à l'historique
    MySQL.insert([[
        INSERT INTO player_fishing_history
        (identifier, fish_name, fish_weight, fish_rarity, xp_gained, price, caught_at)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
    ]], {
        xPlayer.identifier,
        selectedFish.label,
        fishWeight,
        selectedFish.rarity,
        xpGained,
        selectedFish.price
    })

    -- Notifications
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format(Config.Messages.fishCaught, selectedFish.label, fishWeight)
    })

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = string.format(Config.Messages.xpGained, xpGained)
    })

    -- Vérifier le level up
    if newLevel > oldLevel then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = string.format(Config.Messages.levelUp, newLevel),
            duration = 5000
        })

        TriggerClientEvent('zfish:levelUp', source)
    end

    TriggerClientEvent('zfish:fishCaught', source, {
        fish = selectedFish,
        weight = fishWeight,
        xp = xpGained,
        newLevel = newLevel
    })
end)

-- =====================================================
-- SYSTÈME DE VENTE DE POISSONS
-- =====================================================

-- Obtenir les poissons du joueur
ESX.RegisterServerCallback('zfish:getPlayerFish', function(source, cb, illegalOnly)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb({}) end

    local inventory = exports.ox_inventory:GetInventory(source)
    local fishList = {}

    -- Liste de poissons à chercher
    local fishConfig = illegalOnly and Config.IllegalFish or Config.Fish

    for _, fish in pairs(fishConfig) do
        local count = exports.ox_inventory:Search('count', fish.item)
        if count and count > 0 then
            -- Obtenir le poids moyen
            local items = exports.ox_inventory:Search('slots', fish.item)
            local totalWeight = 0
            local itemCount = 0

            if items then
                for _, item in pairs(items) do
                    if item.metadata and item.metadata.weight then
                        totalWeight = totalWeight + item.metadata.weight
                        itemCount = itemCount + 1
                    end
                end
            end

            local avgWeight = itemCount > 0 and (totalWeight / itemCount) or fish.weight.min

            table.insert(fishList, {
                item = fish.item,
                label = fish.label,
                price = fish.price,
                quantity = count,
                rarity = fish.rarity,
                weight = avgWeight
            })
        end
    end

    cb(fishList)
end)

-- Vendre tous les poissons
RegisterNetEvent('zfish:sellAllFish')
AddEventHandler('zfish:sellAllFish', function(isIllegal)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local fishConfig = isIllegal and Config.IllegalFish or Config.Fish
    local priceMultiplier = isIllegal and Config.IllegalBuyer.priceMultiplier or Config.FishSeller.priceMultiplier
    local totalMoney = 0
    local totalFish = 0

    for _, fish in pairs(fishConfig) do
        local count = exports.ox_inventory:GetItemCount(source, fish.item)
        if count and count > 0 then
            -- Retirer les poissons
            exports.ox_inventory:RemoveItem(source, fish.item, count)

            -- Calculer le prix
            local price = math.floor(fish.price * count * priceMultiplier)
            totalMoney = totalMoney + price
            totalFish = totalFish + count
        end
    end

    if totalMoney > 0 then
        xPlayer.addMoney(totalMoney)

        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = string.format('Vous avez vendu %d poissons pour $%d', totalFish, totalMoney),
            duration = 5000
        })

        -- Alerte police pour vente illégale
        if isIllegal then
            local alertChance = Config.IllegalBuyer.policeAlertChance
            if math.random(100) <= alertChance then
                -- Alerter la police (à adapter selon votre système de police)
                TriggerClientEvent('ox_lib:notify', source, {
                    type = 'warning',
                    description = 'Vous avez le sentiment d\'être observé...',
                    duration = 5000
                })

                -- Vous pouvez ajouter ici un dispatch pour la police
                -- TriggerEvent('police:alert', coords, 'Vente illégale de poissons')
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Vous n\'avez aucun poisson à vendre'
        })
    end
end)

-- =====================================================
-- ACHAT D'ITEMS
-- =====================================================

RegisterNetEvent('zfish:buyItem')
AddEventHandler('zfish:buyItem', function(itemType, itemName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local playerData = GetPlayerFishingData(xPlayer.identifier)
    local itemData = nil

    -- Trouver l'item dans la config
    if itemType == 'rods' then
        for _, rod in pairs(Config.FishingRods) do
            if rod.item == itemName then
                itemData = rod
                break
            end
        end
    elseif itemType == 'baits' then
        for _, bait in pairs(Config.Baits) do
            if bait.item == itemName then
                itemData = bait
                break
            end
        end
    elseif itemType == 'equipment' then
        for _, equip in pairs(Config.Equipment) do
            if equip.item == itemName then
                itemData = equip
                break
            end
        end
    end

    if not itemData then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Item introuvable'
        })
        return
    end

    -- Vérifier le niveau
    if playerData.level < itemData.requiredLevel then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = string.format(Config.Messages.levelRequired, itemData.requiredLevel)
        })
        return
    end

    -- Vérifier l'argent
    if xPlayer.getMoney() < itemData.price then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = Config.Messages.notEnoughMoney
        })
        return
    end

    -- Retirer l'argent
    xPlayer.removeMoney(itemData.price)

    -- Ajouter l'item
    local quantity = 1
    if itemType == 'baits' then
        quantity = 10 -- 10 appâts par achat
    end

    exports.ox_inventory:AddItem(source, itemName, quantity)

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format(Config.Messages.itemPurchased, itemData.label, itemData.price)
    })
end)

-- =====================================================
-- COMMANDES
-- =====================================================

ESX.RegisterCommand('fishstats', 'user', function(xPlayer, args, showError)
    local data = GetPlayerFishingData(xPlayer.identifier)
    local nextLevelXP = GetNextLevelXP(data.level)
    local xpNeeded = nextLevelXP - data.xp

    TriggerClientEvent('ox_lib:notify', xPlayer.source, {
        type = 'info',
        title = 'Stats de Pêche',
        description = string.format(
            'Niveau: %d (%s)\nXP: %d/%d\nPoissons attrapés: %d\nPlus gros poisson: %s (%dg)',
            data.level,
            Config.Levels[data.level].name,
            data.xp,
            nextLevelXP,
            data.total_fish_caught,
            data.biggest_fish_name or 'Aucun',
            data.biggest_fish_weight
        ),
        duration = 10000
    })
end, false)

print('^2[ZFISH]^7 Script de pêche chargé avec succès !')
