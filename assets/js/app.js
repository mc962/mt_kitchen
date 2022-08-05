// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"
// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

document.addEventListener('DOMContentLoaded', () => {
   addNewNestedResourceListener(detectNestedItemTransforms());
   removeNewNestedResourceListener();
});

const addNewNestedResourceListener = (itemTransforms = []) => {
    const newResourceBtn = document.querySelector('.new-resource-btn');
    const existingResources = document.querySelector('.resource-list');
    newResourceBtn.addEventListener('click', () => {
        const newResourceTemplate = document.querySelector('.new-resource-template');
        const newResourceBtn = newResourceTemplate.content.cloneNode(true);
        let newResourceEl = newResourceBtn.querySelector('.resource-item');

        // Set unique 'id' for fields in this resource so that ORM may know how to insert them
        const nodeInputs = newResourceBtn.querySelectorAll('input');
        const nodeTextAreas = newResourceBtn.querySelectorAll('textarea');
        [...Array.from(nodeInputs), ...Array.from(nodeTextAreas)].forEach((nodeInput) => {
            const newRandVal = new Date().getTime().toString();
            nodeInput.name = nodeInput.name.replace(/\[0]/g, `[${newRandVal}]`)
            nodeInput.id = nodeInput.id.replace(/_0_/g, `_${newRandVal}_`)
        });

        itemTransforms.forEach((transform) => {
           newResourceEl = transform(existingResources, newResourceEl)
        });

        existingResources.appendChild(newResourceEl);
    })
}

const setNewStepOrder = (existingResources, newResourceEl) => {
    // Add a current order to the new step, which is required, based on the list length (so a new step would have
    //   an order 1 beyond the existing list length).
    newResourceEl.querySelector('.recipe-step-order').value = existingResources.getElementsByTagName('li').length + 1;

    return newResourceEl
}

const removeNewNestedResourceListener = () => {
    const existingResources = document.querySelector('.resource-list');
    existingResources.addEventListener('click', (event) => {
        const clickedBtn = event.target;
        if (clickedBtn.classList.contains('remove-new-resource-btn')) {
            const removedResource = clickedBtn.closest('li.resource-item');

            if (removedResource) {
                removedResource.remove();
            } else {
                console.warn('Item to remove was not found.');
            }
        }
    });
}

const detectNestedItemTransforms = () => {
    if (document.querySelector('#recipe_steps')) {
        return [
            setNewStepOrder
        ];
    } else {
        return [];
    }
}