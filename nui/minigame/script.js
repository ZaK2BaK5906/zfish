$(document).ready(function() {
    let minigameActive = false;
    let barPosition = 0;
    let barDirection = 1;
    let barSpeed = 3;
    let successZoneStart = 30;
    let successZoneSize = 20;
    let clickCount = 0;
    let clicksRequired = 10;
    let gameTimer = null;
    let barAnimation = null;
    let timeLeft = 10;
    let timerInterval = null;
    let fishName = '';
    let difficulty = 1;

    // Écouter les messages du client Lua
    window.addEventListener('message', function(event) {
        const data = event.data;

        if (data.type === 'startMinigame') {
            startMinigame(data);
        }
    });

    function startMinigame(data) {
        minigameActive = true;
        clickCount = 0;
        barPosition = 0;
        barDirection = 1;
        timeLeft = data.duration / 1000 || 10;

        // Paramètres du mini-jeu
        barSpeed = data.barSpeed || 3;
        successZoneSize = data.successZoneSize || 20;
        clicksRequired = data.clicksRequired || 10;
        fishName = data.fishName || 'Poisson Mystérieux';
        difficulty = data.difficulty || 1;

        // Position aléatoire de la zone de succès
        successZoneStart = Math.random() * (100 - successZoneSize);

        // Afficher l'interface
        $('#minigameApp').fadeIn(300);
        $('#fishName').text(fishName);
        $('#clickCount').text(clickCount);
        $('#clickRequired').text(clicksRequired);
        $('#timer').text(timeLeft + 's');

        // Positionner la zone de succès
        $('#successZone').css({
            left: successZoneStart + '%',
            width: successZoneSize + '%'
        });

        // Afficher la difficulté
        updateDifficultyStars(difficulty);

        // Démarrer l'animation de la barre
        startBarAnimation();

        // Démarrer le timer
        startTimer();
    }

    function updateDifficultyStars(diff) {
        const stars = $('#difficultyStars');
        stars.empty();

        for (let i = 0; i < 5; i++) {
            if (i < diff) {
                stars.append('<i class="fas fa-star"></i>');
            } else {
                stars.append('<i class="far fa-star"></i>');
            }
        }
    }

    function startBarAnimation() {
        barAnimation = setInterval(function() {
            // Déplacer la barre
            barPosition += barSpeed * barDirection;

            // Inverser la direction aux bords
            if (barPosition >= 100) {
                barPosition = 100;
                barDirection = -1;
            } else if (barPosition <= 0) {
                barPosition = 0;
                barDirection = 1;
            }

            // Mettre à jour la position
            $('#fishingBar').css('left', barPosition + '%');
        }, 16); // ~60 FPS
    }

    function startTimer() {
        timerInterval = setInterval(function() {
            timeLeft -= 0.1;

            if (timeLeft <= 0) {
                timeLeft = 0;
                endMinigame(false);
            }

            // Mettre à jour l'affichage
            $('#timer').text(Math.ceil(timeLeft) + 's');

            // Mettre à jour la barre de progression
            const progress = ((10 - timeLeft) / 10) * 100;
            $('#progressBar').css('width', progress + '%');
        }, 100);
    }

    function checkSuccess() {
        const barEnd = barPosition;
        const zoneEnd = successZoneStart + successZoneSize;

        // Vérifier si la barre est dans la zone de succès
        return barPosition >= successZoneStart && barPosition <= zoneEnd;
    }

    // Gestion des clics
    $(document).on('click', function(e) {
        if (!minigameActive) return;

        clickCount++;
        $('#clickCount').text(clickCount);

        // Ralentir la barre à chaque clic
        if (clickCount >= clicksRequired) {
            // Vérifier si on est dans la zone de succès
            if (checkSuccess()) {
                endMinigame(true);
            } else {
                // Shake effect
                $('.minigame-box').addClass('shake');
                setTimeout(() => {
                    $('.minigame-box').removeClass('shake');
                }, 300);

                // Donner une dernière chance
                setTimeout(() => {
                    if (checkSuccess()) {
                        endMinigame(true);
                    } else {
                        endMinigame(false);
                    }
                }, 500);
            }
        } else {
            // Effet visuel de clic
            $('#clickCount').css('transform', 'scale(1.3)');
            setTimeout(() => {
                $('#clickCount').css('transform', 'scale(1)');
            }, 100);
        }
    });

    function endMinigame(success) {
        if (!minigameActive) return;

        minigameActive = false;

        // Arrêter les animations
        clearInterval(barAnimation);
        clearInterval(timerInterval);

        // Effet visuel
        if (success) {
            $('.minigame-box').addClass('success-flash');
        } else {
            $('.minigame-box').addClass('fail-flash');
        }

        // Envoyer le résultat au client Lua
        $.post('https://zfish/minigameResult', JSON.stringify({
            success: success,
            clickCount: clickCount,
            timeLeft: timeLeft
        }));

        // Fermer l'interface
        setTimeout(() => {
            $('.minigame-box').removeClass('success-flash fail-flash');
            $('#minigameApp').fadeOut(300);
        }, 500);
    }

    // Fermer avec ESC (annulation)
    $(document).keyup(function(e) {
        if (e.key === "Escape" && minigameActive) {
            endMinigame(false);
        }
    });
});
