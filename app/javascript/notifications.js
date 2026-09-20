// Events pushed with notify: true trigger a browser notification the moment
// they stream in over Action Cable. Only fires for real-time inserts, never
// for the events already on the page at initial load.
document.addEventListener("turbo:before-stream-render", (event) => {
  const stream = event.target
  if (stream.action !== "prepend") return

  const template = stream.querySelector("template")
  const row = template && template.content.firstElementChild
  if (!row || row.dataset.notify !== "true") return

  if (typeof Notification === "undefined") return

  if (Notification.permission === "granted") {
    new Notification(row.dataset.notifyTitle || "New event", { body: row.dataset.notifyBody || "" })
  } else if (Notification.permission !== "denied") {
    Notification.requestPermission()
  }
})
