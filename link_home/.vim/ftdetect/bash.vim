au BufRead,BufNewFile .envrc set filetype=bash
au BufRead,BufNewFile .env,.env.*,*.env let b:ale_linters_ignore = ['shellcheck']
