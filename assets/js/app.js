// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"
// import "./webauthn_utils.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
// import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import Cookies from 'js-cookie';

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Alpine from 'alpinejs'
import phxFeedbackDom from "./phx_feedback_dom"
window.Alpine = Alpine
Alpine.start()
// https://alpinejs.dev/globals/alpine-data

let Hooks = {}

// Hooks.Flash = {
//     mounted(){
//       let hide = () => liveSocket.execJS(this.el, this.el.getAttribute("phx-click"))
//       this.timer = setTimeout(() => hide(), 8000)
//       this.el.addEventListener("phx:hide-start", () => clearTimeout(this.timer))
//       this.el.addEventListener("mouseover", () => {
//         clearTimeout(this.timer)
//         this.timer = setTimeout(() => hide(), 8000)
//       })
//     },
//     destroyed(){ clearTimeout(this.timer) }
// }


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
// Without Alpine
// let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

let liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks,
    params: {
        _csrf_token: csrfToken
    },
    dom: {
        
        // make LiveView work nicely with AlpineJS
        onBeforeElUpdated(from, to) {
            if (from._x_dataStack) {
                window.Alpine.clone(from, to);
            }
        },
        // phxFeedbackDom({})
    },
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

document.addEventListener("DOMContentLoaded", function (event) { 
    Cookies.set('#__timezone__#', Intl.DateTimeFormat().resolvedOptions().timeZone, { sameSite: 'Lax' })
});




