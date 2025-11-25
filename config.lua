Config = {}

-- ========================
-- CONFIGURATION GÉNÉRALE
-- ========================
Config.Debug = false -- Mode debug pour les développeurs
Config.FishingTime = 15 -- Temps entre chaque pêche en secondes
Config.MaxLevel = 20 -- Niveau maximum de pêche

-- ========================
-- CONFIGURATION DU PNJ BOUTIQUE
-- ========================
Config.ShopPed = {
    model = 'a_m_m_hillbilly_01', -- Modèle du PNJ
    coords = vector4(-1816.71, -1193.78, 13.3, 237.89), -- Pier de plage
    scenario = 'WORLD_HUMAN_STAND_FISHING'
}

-- ========================
-- ZONES DE PÊCHE
-- ========================
Config.FishingZones = {
    {
        name = "Quai de Vespucci",
        coords = vector3(-1850.54, -1248.59, 8.62),
        radius = 100.0,
        blip = {
            enabled = true,
            sprite = 68,
            color = 3,
            scale = 0.8
        }
    },
    {
        name = "Pier de Del Perro",
        coords = vector3(-1607.07, -1026.61, 13.02),
        radius = 80.0,
        blip = {
            enabled = true,
            sprite = 68,
            color = 3,
            scale = 0.8
        }
    },
    {
        name = "Plage de Chumash",
        coords = vector3(-3426.13, 967.66, 8.35),
        radius = 120.0,
        blip = {
            enabled = true,
            sprite = 68,
            color = 3,
            scale = 0.8
        }
    },
    {
        name = "Lac Alamo Sea",
        coords = vector3(1330.23, 4228.34, 33.91),
        radius = 200.0,
        blip = {
            enabled = true,
            sprite = 68,
            color = 3,
            scale = 0.8
        }
    }
}

-- ========================
-- SYSTÈME D'EXPÉRIENCE
-- ========================
Config.Levels = {
    [1] = {xp = 0, name = "Débutant"},
    [2] = {xp = 100, name = "Apprenti"},
    [3] = {xp = 250, name = "Novice"},
    [4] = {xp = 450, name = "Amateur"},
    [5] = {xp = 700, name = "Pêcheur"},
    [6] = {xp = 1000, name = "Pêcheur Confirmé"},
    [7] = {xp = 1400, name = "Expert"},
    [8] = {xp = 1900, name = "Vétéran"},
    [9] = {xp = 2500, name = "Maître"},
    [10] = {xp = 3200, name = "Grand Maître"},
    [11] = {xp = 4000, name = "Professionnel"},
    [12] = {xp = 5000, name = "As de la Pêche"},
    [13] = {xp = 6200, name = "Champion"},
    [14] = {xp = 7600, name = "Expert Ultime"},
    [15] = {xp = 9200, name = "Légende"},
    [16] = {xp = 11000, name = "Maître Légendaire"},
    [17] = {xp = 13000, name = "Virtuose"},
    [18] = {xp = 15500, name = "Titan de la Pêche"},
    [19] = {xp = 18500, name = "Dieu de la Mer"},
    [20] = {xp = 22000, name = "Neptune"}
}

-- ========================
-- CANNES À PÊCHE
-- ========================
Config.FishingRods = {
    {
        item = 'fishing_rod_basic',
        label = 'Canne Basique',
        price = 250,
        requiredLevel = 1,
        prop = 'prop_fishing_rod_01',
        description = 'Une canne simple pour débuter'
    },
    {
        item = 'fishing_rod_amateur',
        label = 'Canne Amateur',
        price = 850,
        requiredLevel = 4,
        prop = 'prop_fishing_rod_01',
        description = 'Pour les pêcheurs en progression'
    },
    {
        item = 'fishing_rod_professional',
        label = 'Canne Professionnelle',
        price = 2500,
        requiredLevel = 8,
        prop = 'prop_fishing_rod_01',
        description = 'Équipement de qualité supérieure'
    },
    {
        item = 'fishing_rod_expert',
        label = 'Canne Expert',
        price = 5500,
        requiredLevel = 13,
        prop = 'prop_fishing_rod_01',
        description = 'Pour les maîtres de la pêche'
    },
    {
        item = 'fishing_rod_legendary',
        label = 'Canne Légendaire',
        price = 12000,
        requiredLevel = 18,
        prop = 'prop_fishing_rod_01',
        description = 'La meilleure canne disponible'
    }
}

-- ========================
-- APPÂTS
-- ========================
Config.Baits = {
    -- APPÂTS BASIQUES
    {
        item = 'bait_worm',
        label = 'Ver de Terre',
        price = 5,
        requiredLevel = 1,
        multiplier = 1.0,
        xpBonus = 0,
        rarityBonus = 0,
        description = 'Appât de base'
    },
    {
        item = 'bait_bread',
        label = 'Pain',
        price = 3,
        requiredLevel = 1,
        multiplier = 1.0,
        xpBonus = 0,
        rarityBonus = 0,
        description = 'Simple mais efficace'
    },
    -- APPÂTS AMÉLIORÉS
    {
        item = 'bait_shrimp',
        label = 'Crevette',
        price = 15,
        requiredLevel = 3,
        multiplier = 1.2,
        xpBonus = 5,
        rarityBonus = 5,
        description = 'Attire de meilleurs poissons'
    },
    {
        item = 'bait_squid',
        label = 'Calamar',
        price = 25,
        requiredLevel = 6,
        multiplier = 1.4,
        xpBonus = 10,
        rarityBonus = 10,
        description = 'Pour les gros poissons'
    },
    -- LEURRES
    {
        item = 'lure_basic',
        label = 'Leurre Basique',
        price = 45,
        requiredLevel = 5,
        multiplier = 1.5,
        xpBonus = 15,
        rarityBonus = 15,
        description = 'Leurre artificiel efficace'
    },
    {
        item = 'lure_advanced',
        label = 'Leurre Avancé',
        price = 85,
        requiredLevel = 10,
        multiplier = 1.8,
        xpBonus = 25,
        rarityBonus = 20,
        description = 'Leurre haute performance'
    },
    {
        item = 'lure_professional',
        label = 'Leurre Pro',
        price = 150,
        requiredLevel = 14,
        multiplier = 2.1,
        xpBonus = 40,
        rarityBonus = 25,
        description = 'Pour les professionnels'
    },
    -- AMORCES SPÉCIALES
    {
        item = 'chum_basic',
        label = 'Amorce Basique',
        price = 35,
        requiredLevel = 7,
        multiplier = 1.3,
        xpBonus = 20,
        rarityBonus = 10,
        description = 'Attire les poissons'
    },
    {
        item = 'chum_premium',
        label = 'Amorce Premium',
        price = 120,
        requiredLevel = 12,
        multiplier = 1.9,
        xpBonus = 35,
        rarityBonus = 30,
        description = 'Amorce de qualité supérieure'
    },
    {
        item = 'chum_legendary',
        label = 'Amorce Légendaire',
        price = 300,
        requiredLevel = 17,
        multiplier = 2.5,
        xpBonus = 60,
        rarityBonus = 40,
        description = 'La meilleure amorce'
    }
}

-- ========================
-- ÉQUIPEMENTS ADDITIONNELS
-- ========================
Config.Equipment = {
    {
        item = 'tackle_box',
        label = 'Boîte à Leurres',
        price = 180,
        requiredLevel = 6,
        description = 'Augmente vos chances'
    },
    {
        item = 'fishing_net',
        label = 'Épuisette',
        price = 320,
        requiredLevel = 9,
        description = 'Pour ne pas perdre vos prises'
    },
    {
        item = 'fish_finder',
        label = 'Détecteur de Poissons',
        price = 1500,
        requiredLevel = 15,
        description = 'Technologie avancée'
    }
}

-- ========================
-- POISSONS
-- ========================
Config.Fish = {
    -- POISSONS COMMUNS
    {
        item = 'fish_anchovy',
        label = 'Anchois',
        price = 8,
        weight = {min = 50, max = 150},
        rarity = 'common',
        xpReward = 5,
        requiredLevel = 1,
        requiredBait = {'bait_worm', 'bait_bread', 'bait_shrimp'},
        chance = 35
    },
    {
        item = 'fish_mackerel',
        label = 'Maquereau',
        price = 12,
        weight = {min = 200, max = 500},
        rarity = 'common',
        xpReward = 8,
        requiredLevel = 1,
        requiredBait = {'bait_worm', 'bait_bread', 'bait_shrimp', 'bait_squid'},
        chance = 30
    },
    {
        item = 'fish_sardine',
        label = 'Sardine',
        price = 10,
        weight = {min = 80, max = 200},
        rarity = 'common',
        xpReward = 6,
        requiredLevel = 1,
        requiredBait = {'bait_worm', 'bait_bread'},
        chance = 32
    },

    -- POISSONS PEU COMMUNS
    {
        item = 'fish_seabass',
        label = 'Bar',
        price = 25,
        weight = {min = 500, max = 1500},
        rarity = 'uncommon',
        xpReward = 15,
        requiredLevel = 3,
        requiredBait = {'bait_shrimp', 'bait_squid', 'lure_basic'},
        chance = 20
    },
    {
        item = 'fish_cod',
        label = 'Cabillaud',
        price = 30,
        weight = {min = 800, max = 2000},
        rarity = 'uncommon',
        xpReward = 18,
        requiredLevel = 4,
        requiredBait = {'bait_shrimp', 'bait_squid', 'lure_basic', 'chum_basic'},
        chance = 18
    },
    {
        item = 'fish_flounder',
        label = 'Flet',
        price = 28,
        weight = {min = 400, max = 1200},
        rarity = 'uncommon',
        xpReward = 16,
        requiredLevel = 3,
        requiredBait = {'bait_worm', 'bait_shrimp', 'lure_basic'},
        chance = 19
    },

    -- POISSONS RARES
    {
        item = 'fish_salmon',
        label = 'Saumon',
        price = 50,
        weight = {min = 2000, max = 4000},
        rarity = 'rare',
        xpReward = 30,
        requiredLevel = 7,
        requiredBait = {'bait_squid', 'lure_basic', 'lure_advanced', 'chum_basic'},
        chance = 12
    },
    {
        item = 'fish_trout',
        label = 'Truite',
        price = 45,
        weight = {min = 1500, max = 3500},
        rarity = 'rare',
        xpReward = 28,
        requiredLevel = 6,
        requiredBait = {'bait_shrimp', 'lure_basic', 'lure_advanced'},
        chance = 13
    },
    {
        item = 'fish_tuna',
        label = 'Thon',
        price = 75,
        weight = {min = 5000, max = 10000},
        rarity = 'rare',
        xpReward = 40,
        requiredLevel = 9,
        requiredBait = {'bait_squid', 'lure_basic', 'lure_advanced', 'chum_basic', 'chum_premium'},
        chance = 10
    },

    -- POISSONS ÉPIQUES
    {
        item = 'fish_swordfish',
        label = 'Espadon',
        price = 120,
        weight = {min = 10000, max = 20000},
        rarity = 'epic',
        xpReward = 60,
        requiredLevel = 12,
        requiredBait = {'lure_advanced', 'lure_professional', 'chum_premium'},
        chance = 7
    },
    {
        item = 'fish_marlin',
        label = 'Marlin',
        price = 150,
        weight = {min = 15000, max = 25000},
        rarity = 'epic',
        xpReward = 75,
        requiredLevel = 14,
        requiredBait = {'lure_advanced', 'lure_professional', 'chum_premium'},
        chance = 6
    },
    {
        item = 'fish_shark',
        label = 'Requin',
        price = 200,
        weight = {min = 30000, max = 50000},
        rarity = 'epic',
        xpReward = 90,
        requiredLevel = 16,
        requiredBait = {'lure_professional', 'chum_premium', 'chum_legendary'},
        chance = 5
    },

    -- POISSONS LÉGENDAIRES
    {
        item = 'fish_giant_squid',
        label = 'Calmar Géant',
        price = 350,
        weight = {min = 50000, max = 80000},
        rarity = 'legendary',
        xpReward = 150,
        requiredLevel = 18,
        requiredBait = {'lure_professional', 'chum_legendary'},
        chance = 3
    },
    {
        item = 'fish_manta_ray',
        label = 'Raie Manta',
        price = 400,
        weight = {min = 60000, max = 90000},
        rarity = 'legendary',
        xpReward = 180,
        requiredLevel = 19,
        requiredBait = {'lure_professional', 'chum_legendary'},
        chance = 2
    },
    {
        item = 'fish_whale',
        label = 'Baleine (Petite)',
        price = 500,
        weight = {min = 80000, max = 120000},
        rarity = 'legendary',
        xpReward = 250,
        requiredLevel = 20,
        requiredBait = {'chum_legendary'},
        chance = 1
    }
}

-- ========================
-- POISSONS ILLÉGAUX
-- ========================
Config.IllegalFish = {
    {
        item = 'illegal_great_white_shark',
        label = 'Grand Requin Blanc',
        price = 1200,
        weight = {min = 100000, max = 200000},
        rarity = 'illegal',
        xpReward = 300,
        requiredLevel = 15,
        requiredBait = {'lure_professional', 'chum_premium', 'chum_legendary'},
        chance = 2
    },
    {
        item = 'illegal_tiger_shark',
        label = 'Requin Tigre',
        price = 950,
        weight = {min = 80000, max = 150000},
        rarity = 'illegal',
        xpReward = 250,
        requiredLevel = 14,
        requiredBait = {'lure_advanced', 'lure_professional', 'chum_premium'},
        chance = 3
    },
    {
        item = 'illegal_hammerhead_shark',
        label = 'Requin Marteau',
        price = 850,
        weight = {min = 70000, max = 130000},
        rarity = 'illegal',
        xpReward = 220,
        requiredLevel = 13,
        requiredBait = {'lure_advanced', 'chum_premium'},
        chance = 3
    },
    {
        item = 'illegal_bull_shark',
        label = 'Requin Bouledogue',
        price = 750,
        weight = {min = 60000, max = 110000},
        rarity = 'illegal',
        xpReward = 200,
        requiredLevel = 12,
        requiredBait = {'lure_basic', 'lure_advanced', 'chum_basic'},
        chance = 4
    },
    {
        item = 'illegal_blue_shark',
        label = 'Requin Bleu',
        price = 680,
        weight = {min = 50000, max = 95000},
        rarity = 'illegal',
        xpReward = 180,
        requiredLevel = 11,
        requiredBait = {'lure_basic', 'chum_basic'},
        chance = 4
    },
    {
        item = 'illegal_whale_shark',
        label = 'Requin Baleine',
        price = 1500,
        weight = {min = 150000, max = 250000},
        rarity = 'illegal',
        xpReward = 350,
        requiredLevel = 17,
        requiredBait = {'chum_premium', 'chum_legendary'},
        chance = 1
    },
    {
        item = 'illegal_baby_whale',
        label = 'Bébé Baleine',
        price = 2000,
        weight = {min = 200000, max = 350000},
        rarity = 'illegal',
        xpReward = 400,
        requiredLevel = 18,
        requiredBait = {'chum_legendary'},
        chance = 1
    },
    {
        item = 'illegal_dolphin',
        label = 'Dauphin',
        price = 1100,
        weight = {min = 120000, max = 180000},
        rarity = 'illegal',
        xpReward = 280,
        requiredLevel = 15,
        requiredBait = {'lure_professional', 'chum_premium'},
        chance = 2
    },
    {
        item = 'illegal_orca',
        label = 'Orque',
        price = 1800,
        weight = {min = 180000, max = 300000},
        rarity = 'illegal',
        xpReward = 380,
        requiredLevel = 19,
        requiredBait = {'chum_legendary'},
        chance = 1
    },
    {
        item = 'illegal_giant_turtle',
        label = 'Tortue Géante',
        price = 900,
        weight = {min = 90000, max = 140000},
        rarity = 'illegal',
        xpReward = 240,
        requiredLevel = 14,
        requiredBait = {'lure_advanced', 'chum_basic'},
        chance = 3
    },
    {
        item = 'illegal_stingray',
        label = 'Raie Pastenague',
        price = 650,
        weight = {min = 55000, max = 90000},
        rarity = 'illegal',
        xpReward = 190,
        requiredLevel = 12,
        requiredBait = {'lure_basic', 'bait_squid'},
        chance = 4
    },
    {
        item = 'illegal_giant_octopus',
        label = 'Pieuvre Géante',
        price = 800,
        weight = {min = 70000, max = 120000},
        rarity = 'illegal',
        xpReward = 210,
        requiredLevel = 13,
        requiredBait = {'lure_advanced', 'bait_squid'},
        chance = 3
    },
    {
        item = 'illegal_bluefin_tuna',
        label = 'Thon Rouge',
        price = 1300,
        weight = {min = 100000, max = 170000},
        rarity = 'illegal',
        xpReward = 290,
        requiredLevel = 16,
        requiredBait = {'lure_professional', 'chum_premium'},
        chance = 2
    },
    {
        item = 'illegal_sawfish',
        label = 'Poisson-Scie',
        price = 950,
        weight = {min = 85000, max = 145000},
        rarity = 'illegal',
        xpReward = 260,
        requiredLevel = 15,
        requiredBait = {'lure_advanced', 'chum_basic'},
        chance = 2
    },
    {
        item = 'illegal_napoleon_fish',
        label = 'Napoléon (Protégé)',
        price = 1400,
        weight = {min = 95000, max = 160000},
        rarity = 'illegal',
        xpReward = 310,
        requiredLevel = 17,
        requiredBait = {'lure_professional', 'chum_premium'},
        chance = 2
    }
}

-- ========================
-- ANIMATIONS
-- ========================
Config.Animations = {
    fishing = {
        dict = 'amb@world_human_stand_fishing@idle_a',
        anim = 'idle_c',
        flag = 11
    },
    success = {
        dict = 'anim@mp_player_intcelebrationmale@air_synth',
        anim = 'air_synth',
        flag = 48
    }
}

-- ========================
-- MINI-JEU DE PÊCHE
-- ========================
Config.FishingMinigame = {
    enabled = true, -- Activer le mini-jeu personnalisé
    barSpeed = {
        common = 2.5,      -- Vitesse de la barre pour poissons communs
        uncommon = 3.5,    -- Vitesse pour peu communs
        rare = 4.5,        -- Vitesse pour rares
        epic = 5.5,        -- Vitesse pour épiques
        legendary = 7.0,   -- Vitesse pour légendaires
        illegal = 8.0      -- Vitesse pour illégaux
    },
    successZoneSize = {
        common = 25,       -- Taille de la zone de succès (en %)
        uncommon = 20,
        rare = 15,
        epic = 12,
        legendary = 8,
        illegal = 6
    },
    clicksRequired = {    -- Nombre de clics souris requis pour stopper la barre
        common = 3,
        uncommon = 5,
        rare = 7,
        epic = 10,
        legendary = 15,
        illegal = 20
    },
    duration = 10000     -- Durée maximale du mini-jeu (ms)
}

-- ========================
-- MESSAGES
-- ========================
Config.Messages = {
    notInZone = "Vous n'êtes pas dans une zone de pêche",
    noRod = "Vous n'avez pas de canne à pêche",
    noBait = "Vous n'avez pas d'appât",
    alreadyFishing = "Vous êtes déjà en train de pêcher",
    fishingStarted = "Vous commencez à pêcher...",
    fishCaught = "Vous avez attrapé %s (%dg) !",
    fishEscaped = "Le poisson s'est échappé !",
    skillCheckFailed = "Vous avez raté le skill check !",
    levelUp = "Niveau de pêche augmenté ! Niveau %d atteint",
    xpGained = "+%d XP de pêche",
    notEnoughMoney = "Vous n'avez pas assez d'argent",
    itemPurchased = "Vous avez acheté %s pour $%d",
    levelRequired = "Niveau %d requis"
}

-- ========================
-- ITEM TABLETTE
-- ========================
Config.TabletItem = 'fishing_tablet'

-- ========================
-- VENDEUR DE POISSONS LÉGAL
-- ========================
Config.FishSeller = {
    ped = {
        model = 'a_m_m_business_01',
        coords = vector4(-1820.34, -1197.89, 13.3, 325.45),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    blip = {
        enabled = true,
        sprite = 356,
        color = 2,
        scale = 0.8,
        name = "Vendeur de Poissons"
    },
    priceMultiplier = 1.0 -- Multiplicateur du prix (1.0 = prix normal, 1.5 = +50%, etc.)
}

-- ========================
-- ACHETEUR ILLÉGAL
-- ========================
Config.IllegalBuyer = {
    ped = {
        model = 's_m_m_MovAlien_01',  -- PNJ louche
        coords = vector4(730.12, -3000.45, 6.07, 180.0), -- Docks industriels
        scenario = 'WORLD_HUMAN_SMOKING'
    },
    blip = {
        enabled = false, -- Pas de blip pour l'illégal
        sprite = 280,
        color = 1,
        scale = 0.0,
        name = "???"
    },
    priceMultiplier = 3.0, -- Les poissons illégaux rapportent 3x plus
    policeAlertChance = 15 -- 15% de chance d'alerter la police à chaque vente
}
