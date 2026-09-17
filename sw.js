const CACHE_NAME = 'sigae-polo-csu-v1';
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/app/css/custom.css',
  '/app/js/main.js',
  '/app/js/config.js',
  '/app/js/db.js',
  '/app/js/store.js',
  '/app/js/router.js',
  '/app/js/utils.js',
  '/app/pages/dashboard.html',
  '/app/pages/turmas.html',
  '/app/pages/matriculas.html',
  '/app/pages/frequencia.html',
  '/app/pages/alunos.html',
  '/app/pages/professores.html',
  '/app/pages/modalidades.html',
  '/app/pages/relatorios.html',
  '/app/pages/login.html'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
