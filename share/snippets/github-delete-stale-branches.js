// 1. Go to https://github.com/foo/bar/branches/stale
// 2. Open DevTools Console
// 3. Paste the following code

async function sleep(/** @type {number} */ ms) {
  return new Promise((r) => setTimeout(r, ms));
}

// To stop it anytime, set stopPageIteration = true;
// (e.g., when it reaches a page you want to stop at, or it hits rate limits (429 Too Many Requests))
// To resume, set stopPageIteration = false; and call iteratePages(...) again.
let stopPageIteration = false;

/**
 * @param {{fn: function(any): Promise<number> | number, fnArgs?: any, continueOnEmptyPages?: boolean, sleepMs: number}} args
 * @returns {Promise<void>}
 */
async function iteratePages({ fn, fnArgs = [], continueOnEmptyPages = false, sleepMs }) {
  while (
    !stopPageIteration &&
    // @ts-ignore
    ((await fn.apply(null, [fnArgs].flat())) > 0 || continueOnEmptyPages)
  ) {
    let nextLink = document.querySelector('a[rel=next]');
    if (!nextLink) {
      break;
    }
    // @ts-ignore
    nextLink.click();
    await sleep(sleepMs);
  }
}

// 4. a) If there are only ~ a few hundred branches, you can do it in the browser:
//       If more, this gets "429 Too Many Requests" a lot earlier; see 4. b).

async function deleteStaleBranchesOnPage() {
  let btns = document.querySelectorAll('td:nth-child(6) button:has(.octicon-trash)');
  for (let i = 0; i < btns.length; i++) {
    // @ts-ignore
    btns[i].click();
    if (i % 5 === 4) {
      await sleep(1000);
    }
  }
  return btns.length;
}

iteratePages({ fn: deleteStaleBranchesOnPage, sleepMs: 2500 });

// 4. b) If there are many branches, or if you got rate-limited in the browser, you can use the API
//       (It seems it's not affected by the rate limits of the WEB UI, and/or it has higher limits,
//       or maybe it's because it processes them a lot slower, one after another sequentially).
//       https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#about-secondary-rate-limits
//       First collect branch names:

/** @type {string[]} */
const branchNames = [];

/**
 * @param {{onlyMergedOrClosedPRs?: boolean}} args
 * @returns {number}
 */
function collectBranchesOnPage({ onlyMergedOrClosedPRs = false } = {}) {
  let selector = 'td:nth-child(1)';
  if (onlyMergedOrClosedPRs) {
    selector = `tr:has(.octicon-git-pull-request-closed, .octicon-git-merge) ${selector}`;
  }
  const branches = document.querySelectorAll(selector);
  // @ts-ignore
  branchNames.push(...Array.from(branches).map((b) => b.innerText));
  return branches.length;
}

iteratePages({ fn: collectBranchesOnPage, sleepMs: 2000 });

// To collect only branches with merged or closed PRs (exclude open PRs, or branches without PRs):
iteratePages({
  fn: collectBranchesOnPage,
  fnArgs: { onlyMergedOrClosedPRs: true },
  continueOnEmptyPages: true,
  sleepMs: 2000,
});

// 4. b) Continued: After it finishes (or stopPageIteration = true) copy the output from the console:
console.log(branchNames); // Right click -> Copy object, save as branches.json
// In the terminal:
// $DOTFILES_SHARED/share/snippets/github-delete-stale-branches.sh --repo foo/bar --file branches.json
