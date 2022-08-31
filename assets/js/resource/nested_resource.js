export const addNewNestedResourceListener = (itemsTransforms = [], itemTransforms = []) => {
    const newResourceBtn = document.querySelector('.new-resource-btn');
    let existingResources = document.querySelector('.resource-list');

    if (newResourceBtn && existingResources) {
        newResourceBtn.addEventListener('click', () => {
            const newRandVal = new Date().getTime().toString();

            const newResourceTemplate = document.querySelector('.new-resource-template');
            const newResourceBtn = newResourceTemplate.content.cloneNode(true);
            let newResourceEl = newResourceBtn.querySelector('.resource-item');

            const tempIdInput = newResourceEl.querySelector('.temp-id');
            if (tempIdInput) {
                tempIdInput.value = newRandVal;
            }

            // Set unique 'id' for fields in this resource so that ORM may know how to insert them
            const nodeInputs = newResourceBtn.querySelectorAll('input');
            const nodeTextAreas = newResourceBtn.querySelectorAll('textarea');
            [...Array.from(nodeInputs), ...Array.from(nodeTextAreas)].forEach((nodeInput) => {
                nodeInput.name = nodeInput.name.replace(/\[0]/g, `[${newRandVal}]`)
                nodeInput.id = nodeInput.id.replace(/_0_/g, `_${newRandVal}_`)
            });

            existingResources.appendChild(newResourceEl);

            itemsTransforms.forEach((transform) => {
                existingResources = transform(existingResources)
            });
            itemTransforms.forEach((transform) => {
                newResourceEl = transform(existingResources, newResourceEl)
            });
        })
    }
}
const updateResourceOrder = (existingResources) => {
    const currentItemOrders = existingResources.querySelectorAll('.ordered-item');
    currentItemOrders.forEach((item, idx) => {
        item.value = idx + 1
    });

    return existingResources
}

export const removeNewNestedResourceListener = (itemsTransforms = [], itemTransforms = []) => {
    let existingResources = document.querySelector('.resource-list');

    if (existingResources) {
        existingResources.addEventListener('click', (event) => {
            const clickedBtn = event.target;
            if (clickedBtn.classList.contains('remove-new-resource-btn')) {
                const removedResource = clickedBtn.closest('li.resource-item');

                if (removedResource) {
                    removedResource.remove();

                    itemsTransforms.forEach((transform) => {
                        existingResources = transform(existingResources)
                    });
                } else {
                    console.warn('Item to remove was not found.');
                }
            }
        });
    }
}

export const detectNestedItemContainerTransforms = () => {
    if (document.querySelector('#recipe_steps')) {
        return [
            updateResourceOrder
        ];
    } else {
        return [];
    }
}

export const detectNestedItemTransforms = () => {
    if (document.querySelector('#recipe_steps')) {
        return [];
    } else {
        return [];
    }
}