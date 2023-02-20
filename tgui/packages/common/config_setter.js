/**
 * This is a pair file with `tgui_config.js` in config directory
 * @file
 * @copyright 2023 EvilDragonfiend
 * @license MIT
 */

import { PREF_CODEBASE_KEY } from '../../../config/tgui_config';
import { storage } from './storage';

export const getPrefCodebaseKey = () => {
  const thing = '-cfg-' + PREF_CODEBASE_KEY;
  return thing;
};

export const getPrefConfigKey = () => {
  let thing = sessionStorage.getItem(getPrefCodebaseKey());
  if (thing === undefined) {
    return '';
  }
  return thing;
};

export const setPrefConfigKey = (value) => {
  sessionStorage.setItem(getPrefCodebaseKey(), value);
  storage.set_noconfig(getPrefCodebaseKey(), value);
};

export const setupConfigKey = async () => {
  let thing = await storage.get_noconfig(getPrefCodebaseKey());
  if (thing === undefined) {
    thing = '';
  }
  sessionStorage.setItem(getPrefCodebaseKey(), thing);
};
