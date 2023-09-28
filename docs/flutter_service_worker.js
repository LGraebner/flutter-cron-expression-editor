'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter-cron-expression-editor/assets/AssetManifest.bin": "693635b5258fe5f1cda720cf224f158c",
"flutter-cron-expression-editor/assets/AssetManifest.json": "2efbb41d7877d10aac9d091f58ccd7b9",
"flutter-cron-expression-editor/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"flutter-cron-expression-editor/assets/fonts/MaterialIcons-Regular.otf": "967ebae20467aa2bd54b2c8e604079d7",
"flutter-cron-expression-editor/assets/NOTICES": "05c974ffe1dde60e115ca3261e76c17c",
"flutter-cron-expression-editor/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"flutter-cron-expression-editor/assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"flutter-cron-expression-editor/canvaskit/canvaskit.js": "5caccb235fad20e9b72ea6da5a0094e6",
"flutter-cron-expression-editor/canvaskit/canvaskit.wasm": "d9f69e0f428f695dc3d66b3a83a4aa8e",
"flutter-cron-expression-editor/canvaskit/chromium/canvaskit.js": "ffb2bb6484d5689d91f393b60664d530",
"flutter-cron-expression-editor/canvaskit/chromium/canvaskit.wasm": "393ec8fb05d94036734f8104fa550a67",
"flutter-cron-expression-editor/canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"flutter-cron-expression-editor/canvaskit/skwasm.wasm": "d1fde2560be92c0b07ad9cf9acb10d05",
"flutter-cron-expression-editor/canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15",
"flutter-cron-expression-editor/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter-cron-expression-editor/flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"flutter-cron-expression-editor/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"flutter-cron-expression-editor/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"flutter-cron-expression-editor/icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"flutter-cron-expression-editor/icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"flutter-cron-expression-editor/index.html": "4b768ce3795b2ff5bb9a8f521b6d21e0",
"flutter-cron-expression-editor/": "4b768ce3795b2ff5bb9a8f521b6d21e0",
"flutter-cron-expression-editor/main.dart.js": "cd950f220f3440dff3cf76079b20fea7",
"flutter-cron-expression-editor/manifest.json": "68d34101ff4313288f37db02a63f73ec",
"flutter-cron-expression-editor/version.json": "cdd708c34f224a5b8b407f652947268c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["flutter-cron-expression-editor/main.dart.js",
"flutter-cron-expression-editor/index.html",
"flutter-cron-expression-editor/assets/AssetManifest.json",
"flutter-cron-expression-editor/assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
