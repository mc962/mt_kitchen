const HIDDEN_FLASH_CLASS = 'hidden-flash';

export const closeFlashListener = () => {
    const flashContainers = document.querySelectorAll('.flash-container');

    flashContainers.forEach((container) => {
        if (!window.liveViewEnabled) {
            // Deal with having flash functionality split between live and dumb views. Avoid emitting dumb view changes
            //  if LiveView is enabled

            container.addEventListener('click', () => {
                container.setAttribute('hidden', 'true');
                container.classList.add(HIDDEN_FLASH_CLASS);
            });
        }
    });
};