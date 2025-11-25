ESX = exports["es_extended"]:getSharedObject()

local isFishing = false
local fishingProp = nil
local playerData = nil
local currentBait = nil
local currentRod = nil

-- =====================================================
-- INITIALISATION
-- =====================================================

CreateThread(function()
    -- Créer les blips des zones de pêche
    for _, zone in pairs(Config.FishingZones) do
        if zone.blip.enabled then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, zone.blip.scale)
            SetBlipColour(blip, zone.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.name)
            EndTextCommandSetBlipName(blip)
        end
    end

    -- Créer le PNJ de la boutique
    CreatePedAtLocation(Config.ShopPed, function(ped)
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'fishing_shop',
                icon = 'fas fa-fish',
                label = 'Boutique de Pêche',
                onSelect = function()
                    OpenFishingShop()
                end
            }
        })
    end)

    -- Créer le PNJ du vendeur de poissons
    CreatePedAtLocation(Config.FishSeller.ped, function(ped)
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'fish_seller',
                icon = 'fas fa-store',
                label = 'Vendre des Poissons',
                onSelect = function()
                    OpenFishSeller()
                end
            }
        })
    end)

    -- Créer le PNJ de l'acheteur illégal
    CreatePedAtLocation(Config.IllegalBuyer.ped, function(ped)
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'illegal_buyer',
                icon = 'fas fa-user-secret',
                label = 'Marché Noir',
                onSelect = function()
                    OpenIllegalBuyer()
                end
            }
        })
    end)

    -- Créer le blip de la boutique
    if Config.ShopPed.coords then
        CreateBlipAtCoords(Config.ShopPed.coords, 52, 3, "Boutique de Pêche")
    end

    -- Créer le blip du vendeur
    if Config.FishSeller.blip.enabled then
        CreateBlipAtCoords(Config.FishSeller.ped.coords, Config.FishSeller.blip.sprite, Config.FishSeller.blip.color, Config.FishSeller.blip.name)
    end
end)

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

function CreatePedAtLocation(pedConfig, callback)
    RequestModel(GetHashKey(pedConfig.model))
    while not HasModelLoaded(GetHashKey(pedConfig.model)) do
        Wait(1)
    end

    local ped = CreatePed(4, GetHashKey(pedConfig.model),
        pedConfig.coords.x,
        pedConfig.coords.y,
        pedConfig.coords.z - 1.0,
        pedConfig.coords.w,
        false, true)

    SetEntityHeading(ped, pedConfig.coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if pedConfig.scenario then
        TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)
    end

    if callback then
        callback(ped)
    end
end

function CreateBlipAtCoords(coords, sprite, color, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

function IsInFishingZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in pairs(Config.FishingZones) do
        local distance = #(playerCoords - zone.coords)
        if distance <= zone.radius then
            return true
        end
    end
    return false
end

function GetPlayerData()
    ESX.TriggerServerCallback('zfish:getPlayerData', function(data)
        playerData = data
    end)
end

function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function CreateFishingRod()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    RequestModel(GetHashKey('prop_fishing_rod_01'))
    while not HasModelLoaded(GetHashKey('prop_fishing_rod_01')) do
        Wait(1)
    end

    fishingProp = CreateObject(GetHashKey('prop_fishing_rod_01'), coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(fishingProp, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(GetHashKey('prop_fishing_rod_01'))
end

function DeleteFishingRod()
    if fishingProp then
        DeleteObject(fishingProp)
        fishingProp = nil
    end
end

-- =====================================================
-- SYSTÈME DE PÊCHE
-- =====================================================

function UseFishingRod(rodItem, baitItem)
    if isFishing then
        lib.notify({
            type = 'error',
            description = Config.Messages.alreadyFishing
        })
        return
    end

    if not IsInFishingZone() then
        lib.notify({
            type = 'error',
            description = Config.Messages.notInZone
        })
        return
    end

    currentBait = baitItem
    currentRod = rodItem
    StartFishing(rodItem, baitItem)
end

function StartFishing(rodItem, baitItem)
    isFishing = true
    local playerPed = PlayerPedId()

    -- Charger l'animation
    LoadAnimDict(Config.Animations.fishing.dict)

    -- Créer le prop
    CreateFishingRod()

    -- Jouer l'animation
    TaskPlayAnim(playerPed, Config.Animations.fishing.dict, Config.Animations.fishing.anim, 8.0, -8.0, -1, Config.Animations.fishing.flag, 0, false, false, false)

    -- Notifier le serveur (retire l'appât)
    TriggerServerEvent('zfish:startFishing', baitItem)

    lib.notify({
        type = 'info',
        description = Config.Messages.fishingStarted
    })

    -- Attendre le temps de pêche
    Wait(Config.FishingTime * 1000)

    if not isFishing then return end -- Annulé

    -- Lancer le mini-jeu
    TriggerServerEvent('zfish:requestMinigame', baitItem, rodItem)
end

function StopFishing()
    if not isFishing then return end

    isFishing = false
    local playerPed = PlayerPedId()

    -- Arrêter l'animation
    ClearPedTasksImmediately(playerPed)

    -- Supprimer le prop
    DeleteFishingRod()
end

-- =====================================================
-- MINI-JEU DE PÊCHE
-- =====================================================

RegisterNetEvent('zfish:showMinigame')
AddEventHandler('zfish:showMinigame', function(fishData, baitItem, rodItem)
    local rarity = fishData.rarity
    local config = Config.FishingMinigame

    -- Calculer la difficulté selon la rareté
    local difficulty = 1
    if rarity == 'uncommon' then difficulty = 2
    elseif rarity == 'rare' then difficulty = 3
    elseif rarity == 'epic' then difficulty = 4
    elseif rarity == 'legendary' then difficulty = 5
    elseif rarity == 'illegal' then difficulty = 5
    end

    -- Envoyer les données au NUI
    SetNuiFocus(false, false) -- Pas besoin de focus pour le mini-jeu
    SendNUIMessage({
        type = 'startMinigame',
        fishName = fishData.label,
        barSpeed = config.barSpeed[rarity] or 3.0,
        successZoneSize = config.successZoneSize[rarity] or 20,
        clicksRequired = config.clicksRequired[rarity] or 5,
        duration = config.duration,
        difficulty = difficulty
    })
end)

-- Résultat du mini-jeu
RegisterNUICallback('minigameResult', function(data, cb)
    cb('ok')

    if data.success then
        -- Succès - attraper le poisson
        TriggerServerEvent('zfish:catchFish', currentBait, currentRod)
    else
        -- Échec
        lib.notify({
            type = 'error',
            description = Config.Messages.fishEscaped
        })
    end

    -- Arrêter la pêche
    StopFishing()
end)

-- =====================================================
-- ÉVÉNEMENTS CLIENT
-- =====================================================

RegisterNetEvent('zfish:fishCaught')
AddEventHandler('zfish:fishCaught', function(data)
    GetPlayerData()
end)

RegisterNetEvent('zfish:levelUp')
AddEventHandler('zfish:levelUp', function()
    local playerPed = PlayerPedId()

    -- Animation de célébration
    LoadAnimDict(Config.Animations.success.dict)
    TaskPlayAnim(playerPed, Config.Animations.success.dict, Config.Animations.success.anim, 8.0, -8.0, 3000, Config.Animations.success.flag, 0, false, false, false)

    -- Effets visuels
    CreateThread(function()
        local coords = GetEntityCoords(playerPed)
        for i = 1, 20 do
            DrawMarker(2, coords.x, coords.y, coords.z + 2.0 + i * 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 215, 0, 200, false, false, 2, false, nil, nil, false)
            Wait(50)
        end
    end)
end)

-- =====================================================
-- OX_INVENTORY INTEGRATION
-- =====================================================

exports('useFishingRod', function(data, slot)
    local rodItem = slot.name

    -- Vérifier les appâts disponibles
    ESX.TriggerServerCallback('zfish:checkItems', function(items)
        if not items.hasBait then
            lib.notify({
                type = 'error',
                description = Config.Messages.noBait
            })
            return
        end

        -- Menu pour choisir l'appât
        local baitOptions = {}

        for _, bait in pairs(Config.Baits) do
            local count = exports.ox_inventory:Search('count', bait.item)
            if count and count > 0 then
                table.insert(baitOptions, {
                    title = bait.label,
                    description = string.format('%s (x%d) - %s', bait.description, count, bait.label),
                    icon = 'fish',
                    onSelect = function()
                        UseFishingRod(rodItem, bait.item)
                    end
                })
            end
        end

        if #baitOptions == 0 then
            lib.notify({
                type = 'error',
                description = Config.Messages.noBait
            })
            return
        end

        lib.registerContext({
            id = 'bait_selection',
            title = 'Choisir un appât',
            options = baitOptions
        })

        lib.showContext('bait_selection')
    end)
end)

exports('useFishingTablet', function(data, slot)
    OpenFishingTablet()
end)

-- =====================================================
-- NUI CALLBACKS
-- =====================================================

-- Boutique de pêche
function OpenFishingShop()
    ESX.TriggerServerCallback('zfish:getPlayerData', function(data)
        if not data then return end

        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openShop',
            playerLevel = data.level,
            playerMoney = ESX.GetPlayerData().money,
            rods = Config.FishingRods,
            baits = Config.Baits,
            equipment = Config.Equipment
        })
    end)
end

RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent('zfish:buyItem', data.itemType, data.itemName)
    cb('ok')
    Wait(500)
    SetNuiFocus(false, false)
    Wait(100)
    OpenFishingShop()
end)

-- Tablette de pêche
function OpenFishingTablet()
    ESX.TriggerServerCallback('zfish:getPlayerData', function(playerData)
        if not playerData then return end

        ESX.TriggerServerCallback('zfish:getFishingHistory', function(history)
            local nextLevelXP = 0
            if playerData.level < Config.MaxLevel then
                nextLevelXP = Config.Levels[playerData.level + 1].xp
            else
                nextLevelXP = Config.Levels[Config.MaxLevel].xp
            end

            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'openTablet',
                playerData = playerData,
                history = history,
                nextLevelXP = nextLevelXP,
                levels = Config.Levels
            })
        end, 50)
    end)
end

RegisterNUICallback('closeTablet', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Vendeur de poissons
function OpenFishSeller()
    ESX.TriggerServerCallback('zfish:getPlayerFish', function(fish)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openSeller',
            fish = fish
        })
    end, false) -- false = poissons légaux
end

RegisterNUICallback('closeSeller', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellAllFish', function(data, cb)
    TriggerServerEvent('zfish:sellAllFish', false) -- false = légal
    cb('ok')
end)

-- Acheteur illégal
function OpenIllegalBuyer()
    ESX.TriggerServerCallback('zfish:getPlayerFish', function(fish)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'openIllegal',
            fish = fish
        })
    end, true) -- true = poissons illégaux
end

RegisterNUICallback('closeIllegal', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellIllegalFish', function(data, cb)
    TriggerServerEvent('zfish:sellAllFish', true) -- true = illégal
    cb('ok')
end)

-- =====================================================
-- ARRÊTER LA PÊCHE AVEC TOUCHE D'ANNULATION D'EMOTE
-- =====================================================

-- Détection de l'annulation d'emote (touche X par défaut)
CreateThread(function()
    while true do
        Wait(0)
        if isFishing then
            -- Vérifier si le joueur n'est plus en animation
            if not IsEntityPlayingAnim(PlayerPedId(), Config.Animations.fishing.dict, Config.Animations.fishing.anim, 3) then
                StopFishing()
                lib.notify({
                    type = 'info',
                    description = 'Pêche annulée'
                })
            end
        else
            Wait(500)
        end
    end
end)

-- =====================================================
-- INITIALISATION DES DONNÉES
-- =====================================================

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    GetPlayerData()
end)

print('^2[ZFISH]^7 Client chargé avec succès !')
