// app.js — Phoenix LiveView JS entrypoint
import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
})

// Connect LiveSocket
liveSocket.connect()

// Expose for debugging in the browser console
window.liveSocket = liveSocket
