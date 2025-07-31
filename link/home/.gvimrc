set guifont=SauceCodePro\ Nerd\ Font:h13
" set guifont=FiraCode\ Nerd\ Font:h13
" set guifont=Hasklug\ Nerd\ Font:h12
" set guifont=IntoneMono\ NF:h13
" set guifont=JetBrainsMono\ Nerd\ Font:h12
" set guifont=SauceCodePro\ Nerd\ Font:h13
set guioptions+=T

" https://superuser.com/a/249483/59919
if has("gui_macvim")
  " Cmd + n, new buffer
  macmenu File.New\ Window key=<D-N>

  " Cmd + Shift + t, reopen last buffer
  " Doesn't work, <C-T> (Ctrl + Shift + t) in .vimrc
  " macmenu File.Open\ Tab... key=<nop>
  " nnoremap <D-T> :e#<CR>

  " Cmd + w, close buffer
  macmenu File.Close key=<nop>
  nnoremap <D-w> :bd<CR>

  " Cmd + p, files
  macmenu File.Print key=<nop>
  noremap <D-P> :

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

    silent! AirlineRefresh
  endfun
  au OSAppearanceChanged * call ChangeBackground()
endif
