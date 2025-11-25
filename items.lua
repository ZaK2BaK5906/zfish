-- =====================================================
-- ITEMS À AJOUTER DANS ox_inventory/data/items.lua
-- =====================================================

-- CANNES À PÊCHE
['fishing_rod_basic'] = {
    label = 'Canne Basique',
    weight = 1500,
    stack = false,
    close = true,
    description = 'Une canne simple pour débuter',
    client = {
        export = 'zfish.useFishingRod'
    }
},

['fishing_rod_amateur'] = {
    label = 'Canne Amateur',
    weight = 1800,
    stack = false,
    close = true,
    description = 'Pour les pêcheurs en progression',
    client = {
        export = 'zfish.useFishingRod'
    }
},

['fishing_rod_professional'] = {
    label = 'Canne Professionnelle',
    weight = 2200,
    stack = false,
    close = true,
    description = 'Équipement de qualité supérieure',
    client = {
        export = 'zfish.useFishingRod'
    }
},

['fishing_rod_expert'] = {
    label = 'Canne Expert',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Pour les maîtres de la pêche',
    client = {
        export = 'zfish.useFishingRod'
    }
},

['fishing_rod_legendary'] = {
    label = 'Canne Légendaire',
    weight = 3000,
    stack = false,
    close = true,
    description = 'La meilleure canne disponible',
    client = {
        export = 'zfish.useFishingRod'
    }
},

-- APPÂTS BASIQUES
['bait_worm'] = {
    label = 'Ver de Terre',
    weight = 10,
    stack = true,
    close = true,
    description = 'Appât de base'
},

['bait_bread'] = {
    label = 'Pain',
    weight = 15,
    stack = true,
    close = true,
    description = 'Simple mais efficace'
},

['bait_shrimp'] = {
    label = 'Crevette',
    weight = 20,
    stack = true,
    close = true,
    description = 'Attire de meilleurs poissons'
},

['bait_squid'] = {
    label = 'Calamar',
    weight = 30,
    stack = true,
    close = true,
    description = 'Pour les gros poissons'
},

-- LEURRES
['lure_basic'] = {
    label = 'Leurre Basique',
    weight = 25,
    stack = true,
    close = true,
    description = 'Leurre artificiel efficace'
},

['lure_advanced'] = {
    label = 'Leurre Avancé',
    weight = 30,
    stack = true,
    close = true,
    description = 'Leurre haute performance'
},

['lure_professional'] = {
    label = 'Leurre Pro',
    weight = 35,
    stack = true,
    close = true,
    description = 'Pour les professionnels'
},

-- AMORCES
['chum_basic'] = {
    label = 'Amorce Basique',
    weight = 40,
    stack = true,
    close = true,
    description = 'Attire les poissons'
},

['chum_premium'] = {
    label = 'Amorce Premium',
    weight = 50,
    stack = true,
    close = true,
    description = 'Amorce de qualité supérieure'
},

['chum_legendary'] = {
    label = 'Amorce Légendaire',
    weight = 60,
    stack = true,
    close = true,
    description = 'La meilleure amorce'
},

-- ÉQUIPEMENTS
['tackle_box'] = {
    label = 'Boîte à Leurres',
    weight = 500,
    stack = false,
    close = true,
    description = 'Augmente vos chances'
},

['fishing_net'] = {
    label = 'Épuisette',
    weight = 800,
    stack = false,
    close = true,
    description = 'Pour ne pas perdre vos prises'
},

['fish_finder'] = {
    label = 'Détecteur de Poissons',
    weight = 1200,
    stack = false,
    close = true,
    description = 'Technologie avancée'
},

-- POISSONS COMMUNS
['fish_anchovy'] = {
    label = 'Anchois',
    weight = 100,
    stack = true,
    close = true,
    description = 'Un petit poisson commun'
},

['fish_mackerel'] = {
    label = 'Maquereau',
    weight = 350,
    stack = true,
    close = true,
    description = 'Poisson commun des côtes'
},

['fish_sardine'] = {
    label = 'Sardine',
    weight = 150,
    stack = true,
    close = true,
    description = 'Petit poisson argenté'
},

-- POISSONS PEU COMMUNS
['fish_seabass'] = {
    label = 'Bar',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Poisson apprécié des pêcheurs'
},

['fish_cod'] = {
    label = 'Cabillaud',
    weight = 1400,
    stack = true,
    close = true,
    description = 'Poisson blanc de qualité'
},

['fish_flounder'] = {
    label = 'Flet',
    weight = 800,
    stack = true,
    close = true,
    description = 'Poisson plat peu commun'
},

-- POISSONS RARES
['fish_salmon'] = {
    label = 'Saumon',
    weight = 3000,
    stack = true,
    close = true,
    description = 'Poisson noble et recherché'
},

['fish_trout'] = {
    label = 'Truite',
    weight = 2500,
    stack = true,
    close = true,
    description = 'Poisson d\'eau douce rare'
},

['fish_tuna'] = {
    label = 'Thon',
    weight = 7500,
    stack = true,
    close = true,
    description = 'Grand poisson pélagique'
},

-- POISSONS ÉPIQUES
['fish_swordfish'] = {
    label = 'Espadon',
    weight = 15000,
    stack = true,
    close = true,
    description = 'Poisson combatif épique'
},

['fish_marlin'] = {
    label = 'Marlin',
    weight = 20000,
    stack = true,
    close = true,
    description = 'Le roi des océans'
},

['fish_shark'] = {
    label = 'Requin',
    weight = 40000,
    stack = true,
    close = true,
    description = 'Prédateur redoutable'
},

-- POISSONS LÉGENDAIRES
['fish_giant_squid'] = {
    label = 'Calmar Géant',
    weight = 65000,
    stack = true,
    close = true,
    description = 'Créature légendaire des profondeurs'
},

['fish_manta_ray'] = {
    label = 'Raie Manta',
    weight = 75000,
    stack = true,
    close = true,
    description = 'Majestueuse raie géante'
},

['fish_whale'] = {
    label = 'Baleine (Petite)',
    weight = 100000,
    stack = true,
    close = true,
    description = 'Le plus grand des mammifères marins'
},

-- TABLETTE
['fishing_tablet'] = {
    label = 'Tablette de Pêche',
    weight = 500,
    stack = false,
    close = true,
    description = 'Affiche vos statistiques de pêche',
    client = {
        export = 'zfish.useFishingTablet'
    }
},
