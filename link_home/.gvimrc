set guifont=SauceCodePro\ Nerd\ Font:h13
" set guifont=FiraCode\ Nerd\ Font:h13
" set guifont=Hasklug\ Nerd\ Font:h12
" set guifont=IntoneMono\ NF:h13
" set guifont=JetBrainsMono\ Nerd\ Font:h12
" set guifont=SauceCodePro\ Nerd\ Font:h13
set guioptions+=T

" https://superuser.com/a/249483/59919
if has("gui_macvim")
  " For Fira Code, JetBrains Mono, Hasklig etc.
  set macligatures

  " Cmd + n, new buffer
  macmenu File.New\ Window key=<D-N>
  nnoremap <D-n> :enew<CR>

  " Cmd + Shift + t, reopen last buffer
  " Doesn't work, <C-T> (Ctrl + Shift + t) in .vimrc
  " macmenu File.Open\ Tab... key=<nop>
  " nnoremap <D-T> :e#<CR>

  " Cmd + w, close buffer
  macmenu File.Close key=<nop>
  nnoremap <D-w> :bd<CR>

  " Cmd + p, files
  macmenu File.Print key=<nop>
  nnoremap <D-p> :call MyFZF()<CR>
  " This is Cmd + Alt + p, entered via Ctrl + v :) https://vi.stackexchange.com/a/18080/6891
  " To use <D-M-p>, nomacmeta needs to be set, which would disable certain Alt-characters.
  nnoremap <D-π> :call MyFZF('<C-R><C-W>')<CR>

  " Move line up/down - Why no <D-M-j> / <D-M-k>? See the note above about nomacmeta
  nmap <D-j> <M-j>
  nmap <D-∆> <M-j>
  " D-¨ (Cmd+Opt+k) doesn't work
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-∆> <M-j>
  " D-¨ (Cmd+Opt+k) doesn't work
  vmap <D-k> <M-k>

  macmenu Edit.Find.Use\ Selection\ for\ Find key=<nop>
  nnoremap <D-e> <C-w><C-w>

  " https://github.com/macvim-dev/macvim/pull/929/
  fun! ChangeBackground()
    if (v:os_appearance == 1)
      call SetupDark()
    else
      call SetupLight()
    endif

    redraw!

    AirlineRefresh
  endfun
  au OSAppearanceChanged * call ChangeBackground()
endif
