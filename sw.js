// Service worker mínimo: no guarda nada en caché a propósito.
// Solo existe para que Android/Chrome reconozca la app como instalable
// de verdad (ícono propio, sin barra del navegador). Cada pedido va
// siempre directo a la red, así las actualizaciones futuras se ven
// enseguida, sin quedar pegado a una versión vieja guardada.
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
  event.respondWith(fetch(event.request));
});
