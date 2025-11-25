# ZFISH - Système de Pêche Avancé pour FiveM ESX

Un script de pêche complet avec système de progression, NUI moderne, et intégration complète avec ox_lib, ox_inventory et ox_target.

## Fonctionnalités

### Système de Progression
- **20 niveaux de pêche** avec noms personnalisés (Débutant → Neptune)
- **Système d'expérience** avec gains progressifs
- **Stockage en base de données** de toutes les statistiques
- **Statistiques détaillées** : total de poissons, plus gros poisson, poissons par rareté

### Équipement Évolutif
- **5 cannes à pêche** débloquées par niveau
- **10 types d'appâts et leurres** avec bonus différents
- **3 équipements additionnels** pour améliorer vos chances
- **Animations et props** réalistes

### Système de Pêche
- **Utilisation depuis l'inventaire** avec ox_inventory
- **Skill check ox_lib** avec 3 niveaux easy
- **Temps de pêche configurable** (15 secondes par défaut)
- **Animations complètes** avec prop de canne à pêche
- **Zones de pêche multiples** avec blips sur la carte

### Poissons
- **16 types de poissons** avec 5 niveaux de rareté
- **Commun, Peu commun, Rare, Épique, Légendaire**
- **Poids aléatoires** pour chaque poisson
- **Prix de vente variables** selon la rareté

### Interface NUI
- **Boutique de pêche moderne** avec PNJ
- **Tablette de progression** pour suivre vos stats
- **Design élégant** inspiré de votre exemple
- **Animations fluides** et responsive

## Prérequis

- [es_extended](https://github.com/esx-framework/esx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

### 1. Base de données

Exécutez le fichier SQL dans votre base de données :

```bash
mysql -u votre_utilisateur -p votre_base_de_donnees < sql/install.sql
```

Ou manuellement via phpMyAdmin/HeidiSQL en important `sql/install.sql`

### 2. Ajout des items dans ox_inventory

Ouvrez `ox_inventory/data/items.lua` et ajoutez tous les items contenus dans le fichier `items.lua` de ce script.

**IMPORTANT** : Assurez-vous de bien ajouter tous les items (cannes, appâts, leurres, amorces, équipements, poissons, tablette).

### 3. Installation du script

1. Placez le dossier `zfish` dans votre répertoire `resources`
2. Ajoutez `ensure zfish` dans votre `server.cfg`
3. Redémarrez votre serveur

### 4. Configuration

Éditez le fichier `config.lua` pour personnaliser :
- Les zones de pêche
- Les niveaux et XP requis
- Les prix des items
- Les poissons et leurs chances
- Les animations
- Les messages
- Et bien plus !

## Utilisation

### Pour les joueurs

#### Débuter la pêche
1. Rendez-vous au **PNJ de la boutique** (marqué sur la carte)
2. Achetez une **canne à pêche** et des **appâts**
3. Allez dans une **zone de pêche** (blips bleus sur la carte)
4. Ouvrez votre inventaire et **utilisez la canne à pêche**
5. Sélectionnez un **appât**
6. Réussissez le **skill check** pour attraper un poisson

#### Arrêter la pêche
- Appuyez sur la touche **X** pour arrêter de pêcher

#### Voir vos statistiques
- Commande : `/fishstats`
- Ou utilisez la **Tablette de Pêche** depuis votre inventaire

### Progression

- Chaque poisson attrapé vous donne de l'**XP**
- Plus le poisson est rare, plus vous gagnez d'XP
- Les appâts avancés donnent des **bonus d'XP**
- Débloquez de **nouvelles cannes** et **équipements** en montant de niveau
- Plus votre niveau est élevé, plus vous pouvez attraper de **poissons rares**

### Système d'appâts

Les appâts ont différents effets :
- **Multiplicateur de chances** : augmente vos chances d'attraper de meilleurs poissons
- **Bonus XP** : XP supplémentaire à chaque capture
- **Bonus de rareté** : augmente les chances de poissons rares

## Configuration des zones de pêche

Dans `config.lua`, section `Config.FishingZones` :

```lua
{
    name = "Nom de la zone",
    coords = vector3(x, y, z),
    radius = 100.0, -- Rayon de la zone en mètres
    blip = {
        enabled = true,
        sprite = 68,
        color = 3,
        scale = 0.8
    }
}
```

## Configuration du PNJ

Dans `config.lua`, section `Config.ShopPed` :

```lua
Config.ShopPed = {
    model = 'a_m_m_hillbilly_01',
    coords = vector4(x, y, z, heading),
    scenario = 'WORLD_HUMAN_STAND_FISHING'
}
```

## Personnalisation des niveaux

Modifiez les niveaux dans `Config.Levels` :

```lua
[1] = {xp = 0, name = "Votre nom"},
[2] = {xp = 100, name = "Votre nom"},
-- ...
```

## Commandes

### Joueurs
- `/fishstats` - Afficher vos statistiques de pêche

### Keybinds
- **X** - Arrêter la pêche en cours

## Support et Contact

Pour toute question ou problème :
- Créez une issue sur GitHub
- Contactez ZaK2BaK5906

## Structure des fichiers

```
zfish/
├── fxmanifest.lua
├── config.lua
├── items.lua
├── README.md
├── client/
│   └── main.lua
├── server/
│   └── main.lua
├── sql/
│   └── install.sql
└── nui/
    ├── boutique/
    │   ├── index.html
    │   ├── style.css
    │   └── script.js
    └── tablette/
        ├── index.html
        ├── style.css
        └── script.js
```

## Captures d'écran

### Boutique de Pêche
Interface moderne pour acheter cannes, appâts et équipements.

### Tablette de Progression
Suivez vos statistiques, votre niveau et votre historique de pêche.

### Zones de Pêche
Plusieurs zones disponibles sur toute la carte avec blips personnalisés.

## Changelog

### Version 1.0.0
- Système de pêche complet
- 20 niveaux de progression
- 5 cannes à pêche évolutives
- 10 types d'appâts/leurres
- 16 espèces de poissons
- NUI boutique et tablette
- Intégration ox_lib, ox_inventory, ox_target
- Système de base de données complet
- Animations et props
- Zones de pêche multiples

## Crédits

- **Développeur** : ZaK2BaK5906
- **Framework** : ESX
- **Librairies** : ox_lib, ox_inventory, ox_target, oxmysql

## Licence

Ce script est fourni tel quel. Vous êtes libre de le modifier pour votre serveur.

---

**Bon jeu et bonne pêche !** 🎣
