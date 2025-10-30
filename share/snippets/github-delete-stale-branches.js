// 1. Go to https://github.com/foo/bar/branches/stale
// 2. Open DevTools Console
// 3. Paste the following code

const sleep = async (/** @type {number} */ ms) => new Promise((r) => setTimeout(r, ms));

// To stop it anytime, set stopPageIteration = true;
// (e.g., when it reaches a page you want to stop at, or it hits rate limits (429 Too Many Requests))
// To resume, set stopPageIteration = false; and call iteratePages(...) again.
let stopPageIteration = false;
const iteratePages = async (
  /** @type {{ (): Promise<number> | number; }} */ fn,
  /** @type {number} */ sleepMs
) => {
  while (!stopPageIteration && (await fn()) > 0) {
    let nextLink = document.querySelector('a[rel=next]');
    if (!nextLink) {
      break;
    }
    // @ts-ignore
    nextLink.click();
    await sleep(sleepMs);
  }
};

// 4. a) If there are only ~ a few hundred branches, you can do it in the browser:
//       If more, this gets "429 Too Many Requests" a lot earlier; see 4. b).

const deleteStaleBranchesOnPage = async () => {
  let btns = document.querySelectorAll('td:nth-child(6) button:has(> .octicon-trash)');
  for (let i = 0; i < btns.length; i++) {
    // @ts-ignore
    btns[i].click();
    if (i % 5 === 4) {
      await sleep(1000);
    }
  }
  return btns.length;
};

iteratePages(deleteStaleBranchesOnPage, 2500);

// 4. b) If there are many branches, or if you got rate-limited in the browser, you can use the API
//       (It seems it's not affected by the rate limits of the WEB UI, and/or it has higher limits,
//       or maybe it's because it processes them a lot slower, one after another sequentially).
//       https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#about-secondary-rate-limits
//       First collect branch names:

/** @type {string[]} */
const branchNames = [];

/** @return {number} */
const listBranchesOnPage = () => {
  const branches = document.querySelectorAll('td:nth-child(1)');
  // @ts-ignore
  branchNames.push(...Array.from(branches).map((b) => b.innerText));
  return branches.length;
};

iteratePages(listBranchesOnPage, 2000);

// 4. b) Continued: After it finishes (or stopPageIteration = true) copy the output from the console:
console.log(branchNames); // Right click -> Copy object, save as branches.json
// In the terminal:
// $DOTFILES_SHARED/share/snippets/github-delete-stale-branches.sh --repo foo/bar --file branches.json
