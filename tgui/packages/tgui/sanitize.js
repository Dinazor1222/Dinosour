/**
 * Uses DOMPurify to purify/sanitise HTML.
 */

import DOMPurify from 'dompurify';

// Default values
let defTag = [
  'br', 'code', 'li', 'p', 'pre',
  'span', 'table', 'td', 'tr', 'i',
  'th', 'ul', 'ol', 'menu', 'font', 'b',
  'center', 'table', 'tr', 'th', 'hr',
];
let defAttr = ['class', 'style'];

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param {string} input
 * @param {array} forbidattr
 * @param {array} allowtags
 */
export const sanitizeText = (input, tags = defTag, forbidAttr = defAttr) => {
  // This is VERY important to think first if you NEED
  // the tag you put in here.  We are pushing all this
  // though dangerouslySetInnerHTML and even though
  // the default DOMPurify kills javascript, it dosn't
  // kill href links or such
  return DOMPurify.sanitize(input, {
    ALLOWED_TAGS: tags,
    FORBID_ATTR: forbidAttr,
  });
};
