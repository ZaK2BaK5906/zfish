-- =====================================================
-- ZATM FISHING SCRIPT - DATABASE INSTALLATION
-- =====================================================

CREATE TABLE IF NOT EXISTS `player_fishing` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `level` INT(11) NOT NULL DEFAULT 1,
    `xp` INT(11) NOT NULL DEFAULT 0,
    `total_fish_caught` INT(11) NOT NULL DEFAULT 0,
    `biggest_fish_weight` INT(11) NOT NULL DEFAULT 0,
    `biggest_fish_name` VARCHAR(100) DEFAULT NULL,
    `legendary_caught` INT(11) NOT NULL DEFAULT 0,
    `epic_caught` INT(11) NOT NULL DEFAULT 0,
    `rare_caught` INT(11) NOT NULL DEFAULT 0,
    `uncommon_caught` INT(11) NOT NULL DEFAULT 0,
    `common_caught` INT(11) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `player_fishing_history` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `fish_name` VARCHAR(100) NOT NULL,
    `fish_weight` INT(11) NOT NULL,
    `fish_rarity` VARCHAR(50) NOT NULL,
    `xp_gained` INT(11) NOT NULL,
    `price` INT(11) NOT NULL,
    `caught_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes pour optimiser les requêtes
CREATE INDEX idx_player_level ON player_fishing(level);
CREATE INDEX idx_player_xp ON player_fishing(xp);
CREATE INDEX idx_history_date ON player_fishing_history(caught_at);
CREATE INDEX idx_history_rarity ON player_fishing_history(fish_rarity);
