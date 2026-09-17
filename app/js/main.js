// main.js - Entry point da aplicação
import { initStore } from './store.js';
import { initRouter } from './router.js';

document.addEventListener('alpine:init', () => {
  initStore();
});

document.addEventListener('DOMContentLoaded', () => {
  initRouter();
});
