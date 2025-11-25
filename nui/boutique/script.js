$(document).ready(function() {
    let playerLevel = 1;
    let playerMoney = 0;

    // Écouter les messages du client Lua
    window.addEventListener('message', function(event) {
        const data = event.data;

        switch(data.type) {
            case 'openShop':
                openShop(data);
                break;
        }
    });

    // Fonction pour ouvrir la boutique
    function openShop(data) {
        playerLevel = data.playerLevel;
        playerMoney = data.playerMoney;

        // Mettre à jour l'affichage
        $('#playerLevel').text('Niveau ' + playerLevel);
        $('#playerMoney').text('$' + playerMoney.toLocaleString());

        // Charger les items
        loadItems('rods', data.rods);
        loadItems('baits', data.baits);
        loadItems('equipment', data.equipment);

        // Afficher l'interface
        $('#app').fadeIn(300);
    }

    // Fonction pour charger les items
    function loadItems(type, items) {
        const grid = $(`#${type}Grid`);
        grid.empty();

        items.forEach(item => {
            const isUnlocked = playerLevel >= item.requiredLevel;
            const canAfford = playerMoney >= item.price;

            let icon = 'fa-fish';
            if (type === 'rods') icon = 'fa-hockey-puck';
            else if (type === 'baits') icon = 'fa-worm';
            else if (type === 'equipment') icon = 'fa-toolbox';

            const card = $(`
                <div class="item-card ${!isUnlocked ? 'locked' : ''}">
                    <div class="item-icon">
                        <i class="fas ${icon}"></i>
                    </div>
                    <div class="item-content">
                        <div class="item-header">
                            <div class="item-name">${item.label}</div>
                            <div class="item-price">$${item.price.toLocaleString()}</div>
                        </div>
                        <div class="item-description">${item.description}</div>
                        <div class="item-level ${isUnlocked ? 'unlocked' : ''}">
                            <i class="fas ${isUnlocked ? 'fa-check-circle' : 'fa-lock'}"></i>
                            <span>${isUnlocked ? 'Débloqué' : 'Niveau ' + item.requiredLevel + ' requis'}</span>
                        </div>
                        <button class="buy-btn" ${!isUnlocked || !canAfford ? 'disabled' : ''} data-type="${type}" data-item="${item.item}">
                            <i class="fas fa-shopping-cart"></i>
                            <span>${!isUnlocked ? 'Verrouillé' : (!canAfford ? 'Pas assez d\'argent' : 'Acheter')}</span>
                        </button>
                    </div>
                </div>
            `);

            grid.append(card);
        });
    }

    // Fonction pour fermer la boutique
    function closeShop() {
        $('#app').fadeOut(300);
        $.post('https://zfish/closeShop', JSON.stringify({}));
        // Notifier le parent pour cacher l'iframe
        if (window.parent !== window) {
            window.parent.postMessage({ action: 'closeShop' }, '*');
        }
    }

    // Fonction pour acheter un item
    function buyItem(itemType, itemName) {
        $.post('https://zfish/buyItem', JSON.stringify({
            itemType: itemType,
            itemName: itemName
        }));
    }

    // Events handlers
    $('#closeBtn').click(function() {
        closeShop();
    });

    // Délégation d'événement pour les boutons d'achat
    $(document).on('click', '.buy-btn', function() {
        if (!$(this).prop('disabled')) {
            const itemType = $(this).data('type');
            const itemName = $(this).data('item');

            // Animation du bouton
            $(this).html('<i class="fas fa-spinner fa-spin"></i><span>Achat...</span>');
            $(this).prop('disabled', true);

            buyItem(itemType, itemName);
        }
    });

    // Gestion des onglets
    $('.tab-btn').click(function() {
        const tab = $(this).data('tab');

        // Retirer la classe active de tous les onglets
        $('.tab-btn').removeClass('active');
        $('.tab-content').removeClass('active');

        // Ajouter la classe active à l'onglet cliqué
        $(this).addClass('active');
        $(`#${tab}-content`).addClass('active');
    });

    // Fermer avec ESC
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#app').is(':visible')) {
                closeShop();
            }
        }
    });

    // Effet hover sur les cartes
    $(document).on('mouseenter', '.item-card:not(.locked)', function() {
        $(this).addClass('hover-effect');
    });

    $(document).on('mouseleave', '.item-card', function() {
        $(this).removeClass('hover-effect');
    });
});
