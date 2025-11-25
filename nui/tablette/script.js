$(document).ready(function() {
    // Écouter les messages du client Lua
    window.addEventListener('message', function(event) {
        const data = event.data;

        switch(data.type) {
            case 'openTablet':
                openTablet(data);
                break;
        }
    });

    // Fonction pour ouvrir la tablette
    function openTablet(data) {
        const playerData = data.playerData;
        const history = data.history;
        const nextLevelXP = data.nextLevelXP;
        const levels = data.levels;

        // Mettre à jour les stats principales
        $('#playerLevel').text(playerData.level);
        $('#levelName').text(levels[playerData.level].name);
        $('#playerXP').text(playerData.xp.toLocaleString());
        $('#totalFish').text(playerData.total_fish_caught.toLocaleString());

        // Calculer et afficher la progression XP
        const xpProgress = (playerData.xp / nextLevelXP) * 100;
        $('#xpProgress').css('width', xpProgress + '%');
        $('#xpText').text(playerData.xp.toLocaleString() + ' / ' + nextLevelXP.toLocaleString());

        // Plus gros poisson
        if (playerData.biggest_fish_name) {
            $('#biggestFishWeight').text((playerData.biggest_fish_weight / 1000).toFixed(2) + 'kg');
            $('#biggestFishName').text(playerData.biggest_fish_name);
        } else {
            $('#biggestFishWeight').text('-');
            $('#biggestFishName').text('Aucun poisson attrapé');
        }

        // Stats par rareté
        $('#legendaryCount').text(playerData.legendary_caught || 0);
        $('#epicCount').text(playerData.epic_caught || 0);
        $('#rareCount').text(playerData.rare_caught || 0);
        $('#uncommonCount').text(playerData.uncommon_caught || 0);
        $('#commonCount').text(playerData.common_caught || 0);

        // Charger l'historique
        loadHistory(history);

        // Afficher l'interface
        $('#app').fadeIn(300);
    }

    // Fonction pour charger l'historique
    function loadHistory(history) {
        const container = $('#historyContainer');
        container.empty();

        if (!history || history.length === 0) {
            container.html(`
                <div style="text-align: center; color: rgba(255, 255, 255, 0.5); padding: 40px;">
                    <i class="fas fa-inbox" style="font-size: 48px; margin-bottom: 15px;"></i>
                    <p>Aucun historique de pêche</p>
                </div>
            `);
            return;
        }

        history.forEach((item, index) => {
            const date = new Date(item.caught_at);
            const formattedDate = formatDate(date);

            const rarityColors = {
                'legendary': { bg: 'linear-gradient(135deg, #fbbf24, #f59e0b)', icon: 'fa-gem' },
                'epic': { bg: 'linear-gradient(135deg, #a855f7, #9333ea)', icon: 'fa-crown' },
                'rare': { bg: 'linear-gradient(135deg, #3b82f6, #2563eb)', icon: 'fa-star' },
                'uncommon': { bg: 'linear-gradient(135deg, #22c55e, #16a34a)', icon: 'fa-certificate' },
                'common': { bg: 'linear-gradient(135deg, #9ca3af, #6b7280)', icon: 'fa-circle' }
            };

            const rarity = rarityColors[item.fish_rarity] || rarityColors['common'];

            const historyItem = $(`
                <div class="history-item" style="animation-delay: ${index * 0.05}s;">
                    <div class="history-left">
                        <div class="history-icon" style="background: ${rarity.bg};">
                            <i class="fas ${rarity.icon}"></i>
                        </div>
                        <div class="history-info">
                            <h3>${item.fish_name}</h3>
                            <div class="history-details">
                                <span><i class="fas fa-weight"></i> ${(item.fish_weight / 1000).toFixed(2)}kg</span>
                                <span><i class="fas fa-tag"></i> ${capitalizeFirst(item.fish_rarity)}</span>
                            </div>
                        </div>
                    </div>
                    <div class="history-right">
                        <div class="history-xp">+${item.xp_gained} XP</div>
                        <div class="history-price">$${item.price.toLocaleString()}</div>
                        <div class="history-date">${formattedDate}</div>
                    </div>
                </div>
            `);

            container.append(historyItem);
        });
    }

    // Fonction pour formater la date
    function formatDate(date) {
        const now = new Date();
        const diff = now - date;
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);

        if (minutes < 1) return 'À l\'instant';
        if (minutes < 60) return `Il y a ${minutes} min`;
        if (hours < 24) return `Il y a ${hours}h`;
        if (days < 7) return `Il y a ${days}j`;

        return date.toLocaleDateString('fr-FR', { day: '2-digit', month: '2-digit', year: 'numeric' });
    }

    // Fonction pour capitaliser la première lettre
    function capitalizeFirst(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    // Fonction pour fermer la tablette
    function closeTablet() {
        $('#app').fadeOut(300);
        $.post('https://zfish/closeTablet', JSON.stringify({}));
        // Notifier le parent pour cacher l'iframe
        if (window.parent !== window) {
            window.parent.postMessage({ action: 'closeTablet' }, '*');
        }
    }

    // Events handlers
    $('#closeBtn').click(function() {
        closeTablet();
    });

    // Fermer avec ESC
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#app').is(':visible')) {
                closeTablet();
            }
        }
    });
});
