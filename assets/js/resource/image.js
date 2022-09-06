export const setupPrimaryPicture = () => {
    if (document.querySelector('.resource-primary-img-container')) {
        const primaryPictureInput = document.querySelector('.recipe-primary-picture');
        const previewImg = document.querySelector('.recipe-profile-img');
        syncPrimaryPicture(primaryPictureInput, previewImg);
        undoPrimaryPicture(primaryPictureInput, previewImg);
    }
};

/**
 * Syncs the contents of a file input with a container for previewing a single image to upload, creating a small
 * preview img for the item that will be uploaded
 *
 * @param {HTMLInputElement} primaryPictureInput HTML File Input that triggered a click on attach
 * @param {HTMLImageElement} previewImg Img tag for previewing uploaded image
 */
const syncPrimaryPicture = (primaryPictureInput, previewImg) => {
    window.addEventListener('phx:sync-primary-picture', (event) => {
        const imageFile = primaryPictureInput.files[0];

        if (imageFile) {
            const currentImgUrl = previewImg.src;
            if (currentImgUrl.length) {
                // Ensure that any existing image urls are revoked before attaching a new one, for performance reasons.
                URL.revokeObjectURL(currentImgUrl);
            }

            previewImg.src = URL.createObjectURL(imageFile)
        } else {
            console.warn('Image file was not attached to browser properly.');
        }
    });
};

/**
 * "Cancels" the potential upload of an un-uploaded single image, clearing out the file input as well as the
 * corresponding preview img
 *
 * @param {HTMLInputElement} primaryPictureInput HTML File Input that triggered a click on attach
 * @param {HTMLImageElement} previewImg Img tag for previewing uploaded image
 */
const undoPrimaryPicture = (primaryPictureInput, previewImg) => {
    const cancelBtn = document.querySelector('.cancel-primary-picture-upload-btn');
    cancelBtn.addEventListener('click', () => {
        // Free existing image preview file URL and clear file from input
        URL.revokeObjectURL(previewImg.src);
        primaryPictureInput.value = '';

        // Reset image tag back to initial value
        previewImg.src = previewImg.dataset.originalSrc;
    });
};