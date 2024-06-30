# dotfiles

Share dotfiles across personal and work machines.

## Setup

```sh
dotfiles_dir=somewhere/dotfiles # E.g. ~/code/dotfiles
mkdir -p "$dotfiles_dir"

# If you have an existing personal/work repo:
git clone .../user/dotfiles_personal.git "$dotfiles_dir"/custom # Or user-company/dotfiles.git
# If not:
mkdir "$dotfiles_dir"/custom # Add custom config based on `custom_example`

git clone .../dotfiles.git "$dotfiles_dir"/shared
"$dotfiles_dir"/shared/setup
# To dry-run: EE_DRY_RUN=1 "$dotfiles_dir"/shared/setup
```

After that, open a new terminal tab for the changes to take effect. The end result should be:

```plain
somewhere/dotfiles
├── custom
└── shared
```

## TODO

### Linux

- [ ] Replace/alias/redirect `gfind`, `gnumfmt`, `grealpath`, `gsed`, etc.

### Bash

- [ ] Replace ZSH-specific stuff like `git_*` functions from Oh My Zsh

## FAQ

- Q: Why not use dotfile management tools? \
  A: Most don't have what I need. Chezmoi is close, but breaks syntax highlighting and linting
  due to the dual syntax within a single file, and features too much indirection.
