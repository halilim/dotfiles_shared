# Git: `could not delete references`

## Example

```plain
error: could not delete references: cannot lock ref 'refs/remotes/origin/foo': Unable to create
'.../.git/refs/remotes/origin/foo.lock': File exists.

Another git process seems to be running in this repository, e.g.
an editor opened by 'git commit'. Please make sure all processes
are terminated then try again. If it still fails, a git process
may have crashed in this repository earlier:
remove the file manually to continue.
```

## Root cause

Both uppercase and lowercase versions of the same branch names exist in the repository.

## Fix

```sh
git update-ref -d refs/remotes/origin/foo
git update-ref -d refs/remotes/origin/FOO
```
