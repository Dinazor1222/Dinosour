import 'core-js/es';
import 'core-js/web/immediate';
import 'core-js/web/queue-microtask';
import 'core-js/web/timers';
import 'regenerator-runtime/runtime';
import './polyfills';

import { loadCSS } from 'fg-loadcss';
import { render } from 'inferno';
import { setupHotReloading } from 'tgui-dev-server/link/client';
import { backendUpdate } from './backend';
import { tridentVersion } from './byond';
import { setupDrag } from './drag';
import { createLogger } from './logging';
import { createStore } from './store';

const logger = createLogger();
const store = createStore();
const reactRoot = document.getElementById('react-root');

let initialRender = true;

const renderLayout = () => {
  // Mark the beginning of the render
  let startedAt;
  if (process.env.NODE_ENV !== 'production') {
    startedAt = Date.now();
  }
  try {
    const state = store.getState();
    // Initial render setup
    if (initialRender) {
      logger.log('initial render', state);
      // Setup dragging
      setupDrag(state);
    }
    // Start rendering
    const { Layout } = require('./layout');
    const element = <Layout state={state} dispatch={store.dispatch} />;
    render(element, reactRoot);
  }
  catch (err) {
    logger.error('rendering error', err);
  }
  // Report rendering time
  if (process.env.NODE_ENV !== 'production') {
    const finishedAt = Date.now();
    const diff = finishedAt - startedAt;
    const diffFrames = (diff / 16.6667).toFixed(2);
    logger.debug(`rendered in ${diff}ms (${diffFrames} frames)`);
    if (initialRender) {
      const diff = finishedAt - window.__inception__;
      const diffFrames = (diff / 16.6667).toFixed(2);
      logger.log(`fully loaded in ${diff}ms (${diffFrames} frames)`);
    }
  }
  if (initialRender) {
    initialRender = false;
  }
};

// Parse JSON and report all abnormal JSON strings coming from BYOND
const parseStateJson = json => {
  let reviver = (key, value) => {
    if (typeof value === 'object' && value !== null) {
      if (value.__number__) {
        return parseFloat(value.__number__);
      }
    }
    return value;
  };
  // IE8: No reviver for you!
  // See: https://stackoverflow.com/questions/1288962
  if (tridentVersion <= 4) {
    reviver = undefined;
  }
  try {
    return JSON.parse(json, reviver);
  }
  catch (err) {
    logger.log(err);
    logger.log('What we got:', json);
    const msg = err && err.message;
    throw new Error('JSON parsing error: ' + msg);
  }
};

const setupApp = () => {
  // Subscribe for redux state updates
  store.subscribe(() => {
    renderLayout();
  });

  // Subscribe for bankend updates
  window.update = window.initialize = stateJson => {
    const state = parseStateJson(stateJson);
    // Backend update dispatches a store action
    store.dispatch(backendUpdate(state));
  };

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept(['./layout', './routes'], () => {
      renderLayout();
    });
  }

  // Process the early update queue
  while (true) {
    let stateJson = window.__updateQueue__.shift();
    if (!stateJson) {
      break;
    }
    window.update(stateJson);
  }

  // Dynamically load font-awesome from browser's cache
  loadCSS('font-awesome.css');
};

// IE8: Wait for DOM to properly load
if (tridentVersion <= 4 && document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setupApp);
}
else {
  setupApp();
}
