# dotfiles

Share dotfiles across different machines.

WARNING: Subject to breaking changes. This was open-sourced mostly as a means of personal sharing.

## Setup

```sh
dotfiles_dir=somewhere/dotfiles # E.g. ~/code/dotfiles
mkdir -p "$dotfiles_dir"

# If you have an existing custom repo:
git clone .../user/dotfiles_personal.git "$dotfiles_dir"/custom # Or user-org/dotfiles.git
# If not:
mkdir "$dotfiles_dir"/custom # Add custom config based on `custom_example`

git clone .../dotfiles.git "$dotfiles_dir"/shared
"$dotfiles_dir"/shared/setup
# To dry-run: DRY_RUN=1 "$dotfiles_dir"/shared/setup
```

After that, open a new terminal tab for the changes to take effect. The end result should be:

```plain
somewhere/dotfiles
├── custom
└── shared
```

### Termux

```sh
pkg install curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/halilim/dotfiles_shared/main/share/termux_setup.sh)”
```

## Notes

- `.markdownlint.json` (symlink to `link/home/.markdownlint.jsonc`): Required for Vim >
  [coc-markdownlint](https://github.com/fannheyward/coc-markdownlint/blob/master/src/engine.ts#L24).

## FAQ

- Q: Why not use other dotfile management tools? \
  A: Most don't have what I need. Chezmoi is close, but breaks syntax highlighting and linting
  due to the dual syntax within a single file, and features too much indirection.
