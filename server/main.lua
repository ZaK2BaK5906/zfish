ESX = exports["es_extended"]:getSharedObject()

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

-- Obtenir ou créer les données de pêche d'un joueur
local function GetPlayerFishingData(identifier)
    local result = MySQL.query.await('SELECT * FROM player_fishing WHERE identifier = ?', {identifier})

    if result and #result > 0 then
        return result[1]
    else
        -- Créer une nouvelle entrée
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

-- Calculer le niveau en fonction de l'XP
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

-- Obtenir l'XP nécessaire pour le prochain niveau
local function GetNextLevelXP(currentLevel)
    if currentLevel >= Config.MaxLevel then
        return Config.Levels[Config.MaxLevel].xp
    end
    return Config.Levels[currentLevel + 1].xp
end

-- Mettre à jour les stats du joueur
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

-- Obtenir les données du joueur
ESX.RegisterServerCallback('zfish:getPlayerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end

    local data = GetPlayerFishingData(xPlayer.identifier)
    cb(data)
end)

-- Obtenir l'historique de pêche
ESX.RegisterServerCallback('zfish:getFishingHistory', function(source, cb, limit)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end

    local history = MySQL.query.await(
        'SELECT * FROM player_fishing_history WHERE identifier = ? ORDER BY caught_at DESC LIMIT ?',
        {xPlayer.identifier, limit or 50}
    )

    cb(history)
end)

-- Vérifier si le joueur possède les items nécessaires
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
    TriggerClientEvent('zfish:fishingStarted', source, baitItem)
end)

-- Attraper un poisson
RegisterNetEvent('zfish:catchFish')
AddEventHandler('zfish:catchFish', function(baitItem, rodItem)
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

    -- Créer une liste de poissons possibles
    local possibleFish = {}
    for _, fish in pairs(Config.Fish) do
        -- Vérifier si le joueur a le niveau requis
        if playerLevel >= fish.requiredLevel then
            -- Vérifier si l'appât est compatible
            local baitCompatible = false
            for _, compatibleBait in pairs(fish.requiredBait) do
                if compatibleBait == baitItem then
                    baitCompatible = true
                    break
                end
            end

            if baitCompatible then
                -- Calculer la chance modifiée par l'appât
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

    -- Sélectionner un poisson aléatoire basé sur les chances
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

        -- Animation de célébration
        TriggerClientEvent('zfish:levelUp', source)
    end

    TriggerClientEvent('zfish:fishCaught', source, {
        fish = selectedFish,
        weight = fishWeight,
        xp = xpGained,
        newLevel = newLevel
    })
end)

-- Acheter un item dans la boutique
RegisterNetEvent('zfish:buyItem')
AddEventHandler('zfish:buyItem', function(itemType, itemName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local playerData = GetPlayerFishingData(xPlayer.identifier)
    local itemData = nil

    -- Trouver l'item dans la config
    if itemType == 'rod' then
        for _, rod in pairs(Config.FishingRods) do
            if rod.item == itemName then
                itemData = rod
                break
            end
        end
    elseif itemType == 'bait' then
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

    -- Ajouter l'item (quantité spéciale pour les appâts)
    local quantity = 1
    if itemType == 'bait' then
        quantity = 10 -- 10 appâts par achat
    end

    exports.ox_inventory:AddItem(source, itemName, quantity)

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format(Config.Messages.itemPurchased, itemData.label, itemData.price)
    })
end)

-- Vendre un poisson
RegisterNetEvent('zfish:sellFish')
AddEventHandler('zfish:sellFish', function(fishItem, quantity)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    -- Trouver le poisson dans la config
    local fishData = nil
    for _, fish in pairs(Config.Fish) do
        if fish.item == fishItem then
            fishData = fish
            break
        end
    end

    if not fishData then return end

    -- Vérifier que le joueur a le poisson
    local count = exports.ox_inventory:GetItemCount(source, fishItem)
    if not count or count < quantity then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Vous n\'avez pas assez de poissons'
        })
        return
    end

    -- Retirer les poissons
    exports.ox_inventory:RemoveItem(source, fishItem, quantity)

    -- Ajouter l'argent
    local totalPrice = fishData.price * quantity
    xPlayer.addMoney(totalPrice)

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = string.format('Vous avez vendu %dx %s pour $%d', quantity, fishData.label, totalPrice)
    })
end)

-- =====================================================
-- COMMANDES
-- =====================================================

-- Commande pour voir ses stats
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
