// https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/

/**
 * @param {string} name
 * @returns {string}
 */
function getEnv(name) {
  const env = $.NSProcessInfo.processInfo.environment.js;
  return name in env ? env[name].js : "";
}

/**
 * @param {any} obj
 * @param {boolean} [includeInherited=false]
 * @param {number} [level=0]
 * @see https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/Using-JavaScript-for-Automation#running-the-debugger
 */
function props(obj, includeInherited = false, level = 0) {
  const indent = " ".repeat(level * 2);
  console.log(`${indent}(${typeof obj})`);
  Object.getOwnPropertyNames(obj).forEach((name) => {
    console.log(`${indent}${name}: ${typeof obj[name]}`);
  });
  if (includeInherited) {
    const proto = Object.getPrototypeOf(obj);
    if (proto) {
      props(proto, true, level + 1);
    }
  }
}

/**
 * @param {any} obj
 */
function pp(obj) {
  console.log(JSON.stringify(obj, null, 2));
}
