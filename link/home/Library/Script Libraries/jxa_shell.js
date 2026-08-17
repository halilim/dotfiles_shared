//  JXA doesn't have a `quoted form of`
// Lifted from npm: shell-quote. Modifications:
//  - var -> const
//  - xs -> (Array.isArray(xs) ? xs : [xs])

const OPS = [
  "||",
  "&&",
  ";;",
  "|&",
  "<(",
  "<<<",
  ">>",
  ">&",
  "<&",
  "&",
  ";",
  "(",
  ")",
  "|",
  "<",
  ">",
];
const LINE_TERMINATORS = /[\n\r\u2028\u2029]/;
const GLOB_SHELL_SPECIAL = /[\s#!"$&'():;<=>@\\^`|~]/g;

/**
 * @param {any} xs
 */
function quote(xs) {
  return (Array.isArray(xs) ? xs : [xs])
    .map(function (s) {
      if (s === "") {
        return /** @type {const} */ ("''");
      }
      if (s && typeof s === "object") {
        if ("op" in s && s.op === "glob") {
          if (typeof s.pattern !== "string") {
            throw new TypeError("glob token requires a string `pattern`");
          }
          if (LINE_TERMINATORS.test(s.pattern)) {
            throw new TypeError(
              "glob `pattern` must not contain line terminators",
            );
          }
          if (s.pattern === "") {
            return /** @type {const} */ ("''");
          }
          return s.pattern.replace(GLOB_SHELL_SPECIAL, "\\$&");
        }
        if ("op" in s && typeof s.op === "string") {
          if (OPS.indexOf(s.op) < 0) {
            throw new TypeError("invalid `op` value: " + JSON.stringify(s.op));
          }
          return s.op.replace(/[\s\S]/g, "\\$&");
        }
        if ("comment" in s && typeof s.comment === "string") {
          if (LINE_TERMINATORS.test(s.comment)) {
            throw new TypeError("`comment` must not contain line terminators");
          }
          return "#" + s.comment;
        }
        throw new TypeError("unrecognized object token shape");
      }
      if (/["\s\\]/.test(s) && !/'/.test(s)) {
        return "'" + s.replace(/(['])/g, "\\$1") + "'";
      }
      if (/["'\s]/.test(s)) {
        return '"' + s.replace(/(["\\$`!])/g, "\\$1") + '"';
      }
      return String(s).replace(
        /([A-Za-z]:)?([#!"$&'()*,:;<=>?@[\\\]^`{|}~])/g,
        "$1\\$2",
      );
    })
    .join(" ");
}
