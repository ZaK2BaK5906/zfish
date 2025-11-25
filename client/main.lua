ESX = exports["es_extended"]:getSharedObject()

local isFishing = false
local fishingProp = nil
local playerData = nil
local currentBait = nil

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
    RequestModel(GetHashKey(Config.ShopPed.model))
    while not HasModelLoaded(GetHashKey(Config.ShopPed.model)) do
        Wait(1)
    end

    local ped = CreatePed(4, GetHashKey(Config.ShopPed.model),
        Config.ShopPed.coords.x,
        Config.ShopPed.coords.y,
        Config.ShopPed.coords.z - 1.0,
        Config.ShopPed.coords.w,
        false, true)

    SetEntityHeading(ped, Config.ShopPed.coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.ShopPed.scenario, 0, true)

    -- Ajouter ox_target sur le PNJ
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

    -- Créer le blip de la boutique
    local shopBlip = AddBlipForCoord(Config.ShopPed.coords.x, Config.ShopPed.coords.y, Config.ShopPed.coords.z)
    SetBlipSprite(shopBlip, 52)
    SetBlipDisplay(shopBlip, 4)
    SetBlipScale(shopBlip, 0.8)
    SetBlipColour(shopBlip, 3)
    SetBlipAsShortRange(shopBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Boutique de Pêche")
    EndTextCommandSetBlipName(shopBlip)
end)

-- =====================================================
-- FONCTIONS UTILITAIRES
-- =====================================================

-- Vérifier si le joueur est dans une zone de pêche
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

-- Obtenir les données du joueur
function GetPlayerData()
    ESX.TriggerServerCallback('zfish:getPlayerData', function(data)
        playerData = data
    end)
end

-- Charger l'animation
function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

-- Créer le prop de canne à pêche
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

-- Supprimer le prop de canne à pêche
function DeleteFishingRod()
    if fishingProp then
        DeleteObject(fishingProp)
        fishingProp = nil
    end
end

-- =====================================================
-- SYSTÈME DE PÊCHE
-- =====================================================

-- Utiliser la canne à pêche
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
    StartFishing(rodItem, baitItem)
end

-- Démarrer la pêche
function StartFishing(rodItem, baitItem)
    isFishing = true
    local playerPed = PlayerPedId()

    -- Charger l'animation
    LoadAnimDict(Config.Animations.fishing.dict)

    -- Créer le prop
    CreateFishingRod()

    -- Jouer l'animation
    TaskPlayAnim(playerPed, Config.Animations.fishing.dict, Config.Animations.fishing.anim, 8.0, -8.0, -1, Config.Animations.fishing.flag, 0, false, false, false)

    -- Notifier le serveur
    TriggerServerEvent('zfish:startFishing', baitItem)

    lib.notify({
        type = 'info',
        description = Config.Messages.fishingStarted
    })

    -- Attendre le temps de pêche
    Wait(Config.FishingTime * 1000)

    -- Skill check
    local success = lib.skillCheck(Config.SkillCheck.difficulty, Config.SkillCheck.keys)

    if success then
        -- Succès - attraper un poisson
        TriggerServerEvent('zfish:catchFish', baitItem, rodItem)
    else
        -- Échec
        lib.notify({
            type = 'error',
            description = Config.Messages.skillCheckFailed
        })
    end

    -- Arrêter la pêche
    StopFishing()
end

-- Arrêter la pêche
function StopFishing()
    isFishing = false
    local playerPed = PlayerPedId()

    -- Arrêter l'animation
    ClearPedTasksImmediately(playerPed)

    -- Supprimer le prop
    DeleteFishingRod()
end

-- =====================================================
-- ÉVÉNEMENTS CLIENT
-- =====================================================

-- Quand la pêche démarre (confirmation serveur)
RegisterNetEvent('zfish:fishingStarted')
AddEventHandler('zfish:fishingStarted', function(baitItem)
    -- Confirmation que l'appât a été retiré
end)

-- Quand un poisson est attrapé
RegisterNetEvent('zfish:fishCaught')
AddEventHandler('zfish:fishCaught', function(data)
    -- Rafraîchir les données du joueur
    GetPlayerData()
end)

-- Level up
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

-- Utiliser la canne à pêche depuis l'inventaire
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

-- Utiliser la tablette de pêche
exports('useFishingTablet', function(data, slot)
    OpenFishingTablet()
end)

-- =====================================================
-- NUI CALLBACKS
-- =====================================================

-- Ouvrir la boutique de pêche
function OpenFishingShop()
    -- Récupérer les données du joueur
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

-- Fermer la boutique
RegisterNUICallback('closeShop', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Acheter un item
RegisterNUICallback('buyItem', function(data, cb)
    TriggerServerEvent('zfish:buyItem', data.itemType, data.itemName)
    cb('ok')

    -- Fermer et rouvrir la boutique pour rafraîchir
    Wait(500)
    SetNuiFocus(false, false)
    Wait(100)
    OpenFishingShop()
end)

-- Ouvrir la tablette
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

-- Fermer la tablette
RegisterNUICallback('closeTablet', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- =====================================================
-- KEYBIND POUR ARRÊTER LA PÊCHE
-- =====================================================

RegisterCommand('+stopfishing', function()
    if isFishing then
        StopFishing()
        lib.notify({
            type = 'info',
            description = 'Pêche annulée'
        })
    end
end, false)

RegisterCommand('-stopfishing', function()
end, false)

RegisterKeyMapping('+stopfishing', 'Arrêter la pêche', 'keyboard', 'X')

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
