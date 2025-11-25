$(document).ready(function() {
    let fishInventory = [];
    let totalValue = 0;

    // Écouter les messages du client Lua
    window.addEventListener('message', function(event) {
        const data = event.data;

        if (data.type === 'openIllegal') {
            openIllegal(data);
        }
    });

    function openIllegal(data) {
        fishInventory = data.fish || [];

        // Charger la liste de poissons
        loadFishList();

        // Afficher l'interface
        $('#app').fadeIn(300);
    }

    function loadFishList() {
        const container = $('#fishList');
        container.empty();
        totalValue = 0;

        if (fishInventory.length === 0) {
            container.html(`
                <div class="empty-state">
                    <i class="fas fa-skull-crossbones"></i>
                    <p>Vous n'avez aucun poisson illégal</p>
                </div>
            `);
            $('#sellAllBtn').prop('disabled', true);
            $('#totalValue').text('$0');
            return;
        }

        fishInventory.forEach(fish => {
            const itemTotal = fish.price * fish.quantity;
            totalValue += itemTotal;

            const fishItem = $(`
                <div class="fish-item">
                    <div class="fish-left">
                        <div class="fish-icon">
                            <i class="fas fa-skull-crossbones"></i>
                        </div>
                        <div class="fish-details">
                            <h3>${fish.label}</h3>
                            <div class="fish-meta">
                                <span><i class="fas fa-weight"></i> ${(fish.weight / 1000).toFixed(2)}kg</span>
                                <span><i class="fas fa-exclamation-triangle"></i> Illégal</span>
                            </div>
                        </div>
                    </div>
                    <div class="fish-right">
                        <div class="fish-quantity">x${fish.quantity}</div>
                        <div class="fish-price">$${itemTotal.toLocaleString()}</div>
                    </div>
                </div>
            `);

            container.append(fishItem);
        });

        // Mettre à jour le total
        $('#totalValue').text('$' + totalValue.toLocaleString());
        $('#sellAllBtn').prop('disabled', false);
    }

    function closeUI() {
        $('#app').fadeOut(300);
        $.post('https://zfish/closeIllegal', JSON.stringify({}));
        // Notifier le parent
        if (window.parent !== window) {
            window.parent.postMessage({ action: 'closeIllegal' }, '*');
        }
    }

    function sellAll() {
        if (totalValue === 0) return;

        // Animation du bouton
        $('#sellAllBtn').html('<i class="fas fa-spinner fa-spin"></i><span>Vente...</span>');
        $('#sellAllBtn').prop('disabled', true);

        // Envoyer au serveur
        $.post('https://zfish/sellIllegalFish', JSON.stringify({}));

        // Fermer après un délai
        setTimeout(() => {
            closeUI();
        }, 500);
    }

    // Events
    $('#closeBtn').click(function() {
        closeUI();
    });

    $('#sellAllBtn').click(function() {
        sellAll();
    });

    // Fermer avec ESC
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            if ($('#app').is(':visible')) {
                closeUI();
            }
        }
    });
});
