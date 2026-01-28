let g:is_root = system("whoami") == 'root'

set nocompatible        " We're running Vim, not Vi!
set clipboard=unnamed   " Use system clipboard as default clipboard
set cursorline          " highlight current line
set number              " show line numbers

set showcmd             " show command in the last line
set showmatch           " highlight matching [{()}]
set splitbelow
set wildmenu            " visual autocomplete for command menu

" set textwidth=100
set colorcolumn=100     " See `highlight ColorColumn` below

set hlsearch            " highlight matches
set ignorecase          " case-insensitive search by default
set smartcase           " except when an upper-case letter used in the search
set incsearch           " search as characters are entered
" set nofoldenable        " Disable folding by default

set redrawtime=3000

set selection=exclusive " don't include newline in selection

" NOTE: Vim requires these to end in .add
set spellfile=~/.vim/spell/shared.en.utf-8.add,~/.vim/spell/custom.en.utf-8.add

augroup SpellIgnore
  autocmd!
  " Ignore hashes, hex color codes, UUIDs, etc.
  autocmd BufEnter * :syn match HexWords +\<\p*[0-9A-F]\{4,}\p*\c\>+ contains=@NoSpell
augroup end

" cSpell:ignore neoclide
" More under neoclide/coc.nvim settings

" set list                " Show whitespace
" set listchars=nbsp:·,tab:▸\ ,trail:~

set tabstop=2 shiftwidth=2 expandtab
" Based on :h 'tabstop' but shows tabs as 8 spaces
" set tabstop=8 softtabstop=2 shiftwidth=2 noexpandtab

packadd! editorconfig

" Utils

fun! InArray(array, value)
  return index(a:array, a:value) != -1
endfun

" End: Utils

fun! TitleStringCwd()
  if stridx(expand('%:p'), getcwd()) == 0 " within cwd
    let l:suffix = ' // '
  else
    let l:suffix = '  •  '
  endif

  return fnamemodify(getcwd(), ":p:~:h") . l:suffix
endfun
set title titlestring=%{TitleStringCwd()}%f

" remember the last session - only when opened without args, e.g. through Cmd+Space
set viminfo=%,'1000,f1

set wildignore+=*.o,*~,*.pyc
" These disable editing ./.git/config etc. too
" if has("win16") || has("win32")
"   set wildignore+=.git\*,.hg\*,.svn\*
" else
"   set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
" endif

" https://tomjwatson.com/blog/vim-tips/#persistent-undo
if has("persistent_undo")
  set undodir=~/.vim/undodir
  set undofile
endif

filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

" Needs to be after `filetype plugin` - see :h csv-syntax-error
syntax on             " Enable syntax highlighting

let mapleader=","     " Leader is comma

" Only disable the plugin, but not the whole netrw. It's needed for e.g. vim-fugitive's :Gbrowse
" https://github.com/tpope/vim-fugitive/issues/1010
" let g:loaded_netrw = 1 " Disable netrw
let g:loaded_netrwPlugin = 1 " Disable netrw
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 2
let g:netrw_altv = 1
let g:netrw_winsize = 20
let g:netrw_list_hide = '.*\.DS_Store$'
" augroup ProjectDrawer
  " autocmd!
  " autocmd VimEnter * :Vexplore
" augroup END

" https://stackoverflow.com/questions/3431184/highlight-all-occurrence-of-a-selected-word/7779339#7779339
nnoremap <silent> <2-LeftMouse> :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<CR>:set hls<CR>

nnoremap 0 ^

nnoremap <C-T> :e#<CR>
nnoremap <C-Tab> :b#<CR>

nnoremap <leader>* :Rg <C-R><C-W><CR>

" MacVim has its own settings mapped to Cmd+,
" noremap <D-,>, :e $MYVIMRC<CR>

nnoremap <D-.> :ALEFix<CR>

" Doesn't work: nnoremap <leader>g gx<CR>
nnoremap <leader>g :!open <cWORD><CR>
" https://example.com/

nnoremap <leader><leader>c :CocConfig<CR>
nnoremap <leader><leader>g :e ~/.gvimrc<CR>
nnoremap <leader><leader>v :e $MYVIMRC<CR>
nnoremap <leader><leader>vc :e $DOTFILES_CUSTOM/link/home/.vim/autoload/custom.vim<CR>
nnoremap <leader><leader>r :source $MYVIMRC<CR>
" nnoremap <leader><leader>ft :e ~/.vim/ftplugin/
nnoremap <leader><leader>ft :exe 'e' '~/.vim/ftplugin/' . &ft . '.vim'<CR>
" nnoremap <leader><leader>fd :e ~/.vim/ftdetect/
nnoremap <leader><leader>fd :exe 'e' '~/.vim/ftdetect/' . &ft . '.vim'<CR>
" nnoremap <leader><leader>se :e ~/.vim/UltiSnips/

" Plugin-native command, not working: https://github.com/SirVer/ultisnips/issues/1483
" nnoremap <leader><leader>s :UltiSnipsEdit<CR>
" Custom command
" <leader><leader>s conflicts with VSCode Vim's EasyMotion
nnoremap <leader><leader>u :SnipEditUltiSnips<CR>

nnoremap <leader><leader>p :e ~/.vim/pythonx/

" nnoremap <leader><space> :set hlsearch! hlsearch?<CR>
nnoremap <leader><space> :nohl<CR>
nnoremap <leader>% :MtaJumpToOtherTag<CR>
nnoremap <leader><Tab> :b#<CR>
nnoremap <leader>a :A<CR>

" Interferes with CamelCaseMotion in VS Code (which loads this file)
" (But not wordmotion in Vim, probably because it's loaded later)
" nnoremap <leader>b :Buffers<CR>

fun! CopyProblem()
  let [l:info, l:loc] = ale#util#FindItemAtCursor(bufnr(''))
  if empty(l:loc) || empty(l:loc['code'])
    echo 'No lint code'
  else
    call CopyAndEcho(l:loc['code'])
  endif
endfun
nnoremap <leader>cpp :call CopyProblem()<CR>

nnoremap <leader>cp :CopyGitPathLine<CR>
nnoremap <leader>cps :call CopyAndEcho('s ' . GitPathLine())<CR>

" Why did I need this (vs. plain bd)?
" nnoremap <leader>dd :bp\|bd#<CR>
nnoremap q :bd<CR>
nnoremap <leader>d :bd<CR>
nnoremap <leader>d! :bd!<CR>

" Close/Delete All - See .gvimrc for <D-w> alias
nnoremap <leader>da :%bd<CR>

" Close/Delete Others/Except current - https://stackoverflow.com/a/42071865/372654
nnoremap <leader>de :%bd\|e#<CR>
nnoremap <leader>do :%bd\|e#<CR>

fun! MyFZF(query = '')
  let dir = getcwd()
  if dir == $HOME
    let dir = $DOTFILES
  endif

  if empty(a:query)
    let l:fzf_options = []
  else
    let l:fzf_options = ['-q' . a:query]
  endif
  call fzf#vim#files(dir, fzf#vim#with_preview({'options': l:fzf_options}, 'right:50%:hidden', 'ctrl-space'))
endfun

if has("gui_macvim")
  nnoremap <D-p> :call MyFZF()<CR>
  vnoremap <D-p> :call MyFZF('<C-R><C-W>')<CR>
else
  nnoremap <C-p> :call MyFZF()<CR>
  vnoremap <C-p> :call MyFZF('<C-R><C-W>')<CR>
endif

" Disabled in favor of coc-format-selected
" nnoremap <leader>f :call MyFZF()<CR>
" nnoremap <leader>F :call MyFZF('<C-R><C-W>')<CR>

" https://github.com/junegunn/fzf.vim/issues/800
" Can't get line number
" debug: call fzf#vim#tags('change_table', {'options': '--preview ""'})
" let s:preview_file = '~/.vim/plugged/fzf.vim/bin/preview.sh'
" let s:preview_file = 'echo'
" command! -bang -nargs=* MyTags
"   \ call fzf#vim#tags(<q-args>, {
"   \      'options': '
"   \         --with-nth 1,2
"   \         --preview-window="50%"
"   \         --preview ''' . s:preview_file . ' {2}:{3}'''
"   \ }, <bang>0)

nnoremap <leader>h :History<CR>
nnoremap <leader>l :ls<CR>

nnoremap <leader>n :enew<CR>
if has("gui_macvim")
  nnoremap <D-n> :enew<CR>
else
  nnoremap <C-n> :enew<CR>
endif

" netrw is disabled
" nnoremap <leader>nr :exe 'Vexplore' getcwd()<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
nnoremap <leader>nt :NERDTreeToggle<CR>
nnoremap <D-E> :CocCommand explorer<CR>
" https://unix.stackexchange.com/a/88719/4678
nnoremap <leader>p ciw<C-R>0<ESC>
" For snippets
" nnoremap <leader>s :enew\|setf<Space>
nnoremap <leader>s :e ~/Desktop/test_code/test.
nnoremap <leader>t :BTags<CR>
nnoremap <leader>T :Tags<CR>

" nnoremap g] :Tags<CR><C-R><C-W>
" This treats the word in vim-wordmotion mode
" NOTE: Modified in ftplugin files, e.g. in Ruby to properly recognize identifiers
nnoremap g] :exe('Tags '.expand('<cword>')) <CR>

nnoremap <leader>tt :PreviewTag<CR>
" nnoremap <leader>T :TagbarOpenAutoClose<CR>
nnoremap <leader>vf :verbose function <C-R><C-W><CR>
nnoremap <leader>vc :verbose command <C-R><C-W><CR>
nnoremap <leader>q :qa<CR>
nnoremap <leader>x :x<CR>

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" nmap <leader>c <Plug>NERDCommenterToggle<CR>

" https://stackoverflow.com/a/7078429/372654
" Save with sudo when vim started without sudo
cmap w!! w !sudo tee > /dev/null %

nmap <D-C-j> :m +1<CR>
nmap <D-C-k> :m -2<CR>

fun! SelectionHeight()
  return line("'>") - line("'<") + 1
endfun

vmap <expr> <D-C-j> ':m +' . SelectionHeight() . '<CR>gv'
vmap <expr> <D-C-k> ':m -' . SelectionHeight() . '<CR>gv'

" See .gvimrc for mac keys

" " https://neovim.io/doc/user/nvim.html#nvim-from-vim
" if !has('nvim')
  " set ttymouse=xterm2
" endif
" if exists(':tnoremap')
  " tnoremap <Esc> <C-\><C-n>
" endif

" https://github.com/jcs/dotfiles/blob/master/.vimrc#L77
" When writing new files, mkdir -p their paths
augroup BWCCreateDir
    au!
    au BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END

" Check if the buffer was modified outside Vim and reload
set autoread
fun! MyChecktime() " cSpell:ignore Checktime
  " let l:buf_name = bufname('%')
  " echo {
  "       \ 'buftype': &buftype,
  "       \ 'bufname': l:buf_name,
  "       \ 'getcmdwintype': getcmdwintype()
  "       \ }
  if getcmdwintype() == ''
  " if &buftype != 'nofile'
  " if l:buf_name && l:buf_name != '[Command Line]'
    checktime
  endif
endfun
" https://unix.stackexchange.com/a/383044/4678
augroup my_checktime
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
        \ call MyChecktime()
        " \ if !getcmdwintype() | checktime | endif
        " \ if InArray(['', '[Command Line]'], bufname('%')) | checktime | endif
  autocmd FileChangedShellPost *
        \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
augroup end

" cSpell:ignore nelstrom
" Required for nelstrom/vim-textobj-rubyblock
" See note around the plugin
" runtime macros/matchit.vim

silent! call custom#begin()

" https://github.com/junegunn/vim-plug#usage
" call plug#begin('~/.config/nvim/plugged')
call plug#begin()

if !is_root && exists('g:custom_ai_plugin')
  " cSpell:ignore Exafunction madox2
  if g:custom_ai_plugin == 'windsurf'
    " See also: AirlineAddCustomSections
    Plug 'Exafunction/windsurf.vim'
  elseif g:custom_ai_plugin == 'copilot'
    Plug 'github/copilot.vim' , { 'do': ':Copilot setup' }
  elseif g:custom_ai_plugin == 'openai'
    Plug 'madox2/vim-ai' " ~/.config/openai.token
  elseif g:custom_ai_plugin != ''
    autocmd VimEnter * echoerr 'Unknown AI plugin: ' . g:custom_ai_plugin
  endif
endif

" cSpell:ignore junegunn airblade AndrewRadev chaoren chrisbra darfink inkarkat jiangmiao kshenoy luochen1990

" https://github.com/junegunn/fzf.vim#using-vim-plug
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

if !is_root
  Plug 'airblade/vim-gitgutter'
endif

Plug 'airblade/vim-rooter'
Plug 'AndrewRadev/switch.vim'
" Extend words to camel case etc.
Plug 'chaoren/vim-wordmotion'
Plug 'Chiel92/vim-autoformat'
" , { 'for': 'csv' } -:h csv-syntax-error
Plug 'chrisbra/csv.vim'
Plug 'darfink/vim-plist'
Plug 'dense-analysis/ale'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'jiangmiao/auto-pairs'
Plug 'kshenoy/vim-signature'
Plug 'luochen1990/rainbow'

" Plug 'kana/vim-textobj-user' " Required by nelstrom/vim-textobj-rubyblock
" Plug 'vim-scripts/ruby-matchit' " Might be required by nelstrom/vim-textobj-rubyblock
" Doesn't work with inline blocks, ar is the whole paragraph instead of the
" block part etc, and do/end can be covered by vim-indent-object
" Plug 'nelstrom/vim-textobj-rubyblock' " ar/ir

" cSpell:ignore mechatroner michaeljsmith ludovicchabant skywind3000 majutsushi mattn mbbill mhinz

Plug 'mechatroner/rainbow_csv'
Plug 'michaeljsmith/vim-indent-object' " ai/ii/aI

if executable('ctags')
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'skywind3000/gutentags_plus'
endif

" Plug 'majutsushi/tagbar', { 'on': 'TagbarOpenAutoClose' }
" Plug 'mattn/emmet-vim', { 'for': ['*html', '*css', '*jsx', 'php', 'erb'] }
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'

" cSpell:ignore nathanaelkane Yggdroot osyo prabirshrestha godlygeek preservim scrooloose honza

Plug 'nathanaelkane/vim-indent-guides'
" Plug 'Yggdroot/indentLine' " Alternative with lines instead of bg color

if !is_root && (executable('node') || executable('bun'))
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

Plug 'osyo-manga/vim-anzu' " Search status on n/N, e.g. query(1/3)

Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

Plug 'godlygeek/tabular' " Format tables etc., must come before vim-markdown
Plug 'preservim/vim-markdown'

Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

if has('python3')
  Plug 'SirVer/ultisnips' " Snippet manager
  Plug 'honza/vim-snippets' " Actual snippets - both snipMate & UltiSnips formats exist
endif

" cSpell:ignore tpope tommcdo valloric

" Plug 'skywind3000/vim-preview'
" Plug 'slim-template/vim-slim', { 'for': 'slim' }
Plug 'tpope/vim-abolish' " :Abolish / :Subvert / coerce (e.g. crs = coerce to snake case)
Plug 'tpope/vim-dotenv'
Plug 'tpope/vim-eunuch' " :Delete, :Rename, :Move, :Mkdir etc.

Plug 'tpope/vim-fugitive' " git
Plug 'tpope/vim-rhubarb' " GitHub
Plug 'tommcdo/vim-fubitive' " Bitbucket

" Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'

" " https://github.com/ycm-core/YouCompleteMe#explanation-for-the-quick-start-2
" Disabled in favor of coc
" Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --go-completer --ts-completer' }

" If you add a new ft into 'for', add it to g:mta_filetypes too
Plug 'valloric/MatchTagAlways', { 'for': ['erb', 'eruby', 'html', 'jinja', 'xhtml', 'xml'] }

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'vim-ruby/vim-ruby', { 'for': '*ruby' }
" Plug 'tpope/vim-bundler', { 'for': '*ruby' } - autocommand errors
Plug 'tpope/vim-rails', { 'for': '*ruby' }
" Plug 'tpope/vim-rake', { 'for': '*ruby' } - errors

" cSpell:ignore vitalk wsdjeg endel lifepillar liuchengxu rakr

Plug 'vitalk/vim-simple-todo'
" Jump to the specified line & column. E.g. when Vim is invoked with colon: file:LN
Plug 'wsdjeg/vim-fetch'

" Color schemes
" Plug 'endel/vim-github-colorscheme'
" Plug 'lifepillar/vim-solarized8'
" Plug 'junegunn/seoul256.vim'
" Plug 'liuchengxu/space-vim-theme'
Plug 'rakr/vim-one'

call plug#end()

" ===== Plugin settings for airblade/vim-rooter =====
let g:rooter_patterns = [
      \ '.project_root',
      \ '.rbenv/versions/*',
      \ '.git',
      \ '.git/',
      \ '_darcs/',
      \ '.hg/',
      \ '.bzr/',
      \ '.svn/'
      \ ]

" ===== Plugin settings for AndrewRadev/switch.vim =====
let g:switch_mapping = '-'

" ===== Plugin settings for chaoren/vim-wordmotion =====
let g:wordmotion_prefix = mapleader
" This affects nnoremap <leader>v... (:verbose ...)
" let g:wordmotion_mappings = {
"   \ '<C-R><C-W>' : '<C-R><M-w>'
" \ }

" ===== Plugin settings for chrisbra/csv.vim =====
" See .vim/ftplugin/csv.vim
" let g:csv_disable_fdt = 1
" au BufEnter *.csv setlocal nofoldenable
" au BufEnter *.csv call csv#DisableFolding()
" au BufEnter *.csv let b:csv_did_foldsettings=1

" ===== Plugin settings for dense-analysis/ale =====
let g:ale_echo_msg_format = '[%linter%] %code: %%s [%severity%]'
" NOTE: Solargraph can ramp up to 1G memory on large folders (e.g. with multiple repos)
" TODO: Per project setting
" ftplugin versions seem to be not working (solargraph is still running)
" let g:ale_php_phan_use_client = 1
let g:ale_fixers = {
  \ 'markdown': ['markdownlint'],
  \ 'ruby': ['rubocop'],
  \ 'zsh': ['shellcheck']
\ }
" php: phpcs is in defaults, which throws too many errors on sloppy (AKA usual) code, and makes it really slow
let g:ale_linters = {
  \ 'php': ['php', 'languageserver'],
  \ 'ruby': ['rubocop'],
  \ 'zsh': ['shellcheck']
\ }
" Comment-like virtual text, causes layout shifts & can be confused with comments
let g:ale_virtualtext_cursor = 0
let g:ale_sh_shellcheck_dialect = 'bash'

" ===== Plugin settings for easymotion/vim-easymotion =====
map <leader> <Plug>(easymotion-prefix)
" let g:EasyMotion_do_mapping = 0 " Disable default mappings
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)
" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1
" JK motions: Line motions
map <leader>j <Plug>(easymotion-j)
map <leader>k <Plug>(easymotion-k)

" ===== Plugin settings for fatih/vim-go =====
let g:go_term_mode = "split"

" ===== Plugin settings for luochen1990/rainbow =====
let g:rainbow_active = 1
" Please see the colorscheme section for colors

" ===== Plugin settings for neoclide/coc.nvim =====
" highlight: Highlight colors in vim files
" snippets: Show snippets in completion menu. UltiSnips is still used since
"           coc-snippets doesn't support some features like regex snippets (out of the
"           box, might be possible with customization)
" solargraph: ruby
" tsserver: javascript, typescript
"  -> Disabled: coc-highlight, coc-solargraph
" ---> Use :CocConfig (,,c) for coc settings
let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-emmet',
      \ 'coc-explorer',
      \ 'coc-go',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-markdownlint',
      \ 'coc-phpls',
      \ 'coc-python',
      \ 'coc-snippets',
      \ 'coc-tsserver'
      \ ]

" https://github.com/weirongxu/coc-explorer/issues/121#issuecomment-593746323
" autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif

" https://github.com/neoclide/coc.nvim#example-vim-configuration
set hidden
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" :h coc-completion-example
inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#_select_confirm() :
  \ coc#expandableOrJumpable() ?
  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()

fun! s:check_back_space() abort
  let l:col = col('.') - 1
  return !l:col || getline('.')[l:col - 1]  =~# '\s'
endfun

let g:coc_snippet_next = '<tab>'

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

fun! s:show_documentation()
  if (InArray(['vim','help'], &filetype))
    execute 'h '.expand('<cword>')
  else
    " call CocAction('doHover')
    execute 'ptag '.expand('<cword>')
  endif
endfun

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Halil's Note: formatXML, formatJSON etc. still exist in ft plugins
" ===== /End: Plugin settings for neoclide/coc.nvim =====

" ===== Plugin settings for osyo-manga/vim-anzu =====
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)

" ===== Plugin settings for prabirshrestha/vim-lsp =====
if executable('pylsp')
  " pip install python-lsp-server
  au User lsp_setup call lsp#register_server({
    \ 'name': 'pylsp',
    \ 'cmd': {server_info->['pylsp']},
    \ 'allowlist': ['python'],
    \ })
endif

fun! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gs <plug>(lsp-document-symbol-search)
  nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> gi <plug>(lsp-implementation)
  nmap <buffer> gt <plug>(lsp-type-definition)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
  nmap <buffer> K <plug>(lsp-hover)
  nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
  nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

  let g:lsp_format_sync_timeout = 1000
  autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')

  " refer to doc to add more commands
endfun

augroup lsp_install
  au!
  " call s:on_lsp_buffer_enabled only for languages that has the server registered.
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
" End: Plugin settings for prabirshrestha/vim-lsp

" ===== Plugin settings for preservim/vim-markdown =====
let g:vim_markdown_folding_disabled = 1

" ===== Plugin settings for scrooloose/nerdcommenter =====
let g:NERDDefaultAlign = 'left'
let g:NERDSpaceDelims = 1

" ===== Plugin settings for scrooloose/nerdtree =====
" https://github.com/scrooloose/nerdtree#faq
let g:NERDTreeMouseMode = 2
let g:NERDTreeWinSize = 45
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['^\.DS_Store$', '^\.git$', '\~$']
" open NERDTree automatically when vim starts up on opening a directory
" augroup my_auto_nerdtree
"   autocmd!
"   autocmd StdinReadPre * let s:std_in=1
"   autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
" augroup end

" set showtabline=2
" set tabline+=%F

" ===== Plugin settings for valloric/MatchTagAlways =====
let g:mta_filetypes = {
  \ 'erb': 1,
  \ 'eruby': 1,
  \ 'html' : 1,
  \ 'jinja' : 1,
  \ 'xhtml' : 1,
  \ 'xml' : 1,
\ }

" ===== Plugin settings for vim-airline/vim-airline =====
" Also see ChangeBackground()
let g:airline_powerline_fonts = 1
" let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type = 2
let g:airline#extensions#tabline#buffer_idx_mode = 1
for s:buf_idx in [1, 2, 3, 4, 5, 6, 7, 8, 9]
  exe 'nmap <D-' . s:buf_idx . '> <Plug>AirlineSelectTab' . s:buf_idx . '<CR>'
  exe 'nmap <leader>' . s:buf_idx . ' <Plug>AirlineSelectTab' . s:buf_idx . '<CR>'
  exe 'imap <D-' . s:buf_idx . '> <ESC><D-' . s:buf_idx . '>'
endfor
let g:airline#extensions#tabline#fnamemod = ':~:.'
let g:airline#extensions#tabline#fnamecollapse = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
" let g:airline_section_c = '%~'
" See the colorscheme section below for theme/color options

fun! AirlinePrependSectionY(status_str)
  let g:airline_section_y = a:status_str
    \ . g:airline_symbols.space . g:airline_right_alt_sep . g:airline_symbols.space
    \ . g:airline_section_y
endfun

fun! AirlineAddCustomSections(...)
  if !exists('g:airline_added_custom_sections')
    if exists('g:custom_ai_plugin') && g:custom_ai_plugin == 'windsurf'
      call AirlinePrependSectionY('{…} Windsurf:%3{codeium#GetStatusString()}')
    endif

    if g:is_root
      call airline#parts#define_function('root', 'ShowRoot')
      call AirlinePrependSectionY(airline#section#create_right(['root']))
      fun! ShowRoot()
        return 'ROOT'
      endfun
    endif

    let g:airline_added_custom_sections = 1
  endif
endfun
silent! call airline#add_statusline_func('AirlineAddCustomSections')

" ===== Plugin settings for mhinz/vim-startify =====
let g:startify_session_persistence = 1
let g:startify_disable_at_vimenter = 1
" Open Startify even when given a folder (which is not \"editable" anyway)
" augroup my_auto_startify
"   autocmd!
"   autocmd StdinReadPre * let s:std_in=1
"   autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'Startify' | endif
" augroup end

" ===== Plugin settings for nathanaelkane/vim-indent-guides =====
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree', 'startify']
" light background color settings are in the colorscheme section below

" ===== Plugin settings for Yggdroot/indentLine =====
" let g:indentLine_char = '⎸'

if executable('ctags')
  " ===== Plugin settings for skywind3000/gutentags_plus =====
  " https://github.com/skywind3000/gutentags_plus#configuration
  " let g:gutentags_modules = ['ctags', 'gtags_cscope']
  " Cache dir causes project files to have absolute paths. Also why hide them?
  " let g:gutentags_cache_dir = expand('~/.cache/tags')
  let g:gutentags_plus_switch = 1
  let g:gutentags_project_root = ['.project_root']
endif

" ===== Plugin settings for SirVer/ultisnips =====
let g:UltiSnipsExpandTrigger='<C-space>'
let g:UltiSnipsEditSplit='vertical'

" This needs to be after plug block
" See https://vim.fandom.com/wiki/Xterm256_color_names_for_console_Vim for color numbers/names

" Enable to hardcode regardless of the OS appearance
" set background=dark
" set background=light
"
" OSAppearanceChanged / ChangeBackground: See .gvimrc (,,g)

" The following sections need to be after colorscheme

fun! SetupDark()
  set background=dark

  " Color schemes that support dark background:
  " Vim: blue darkblue desert elflord evening habamax industry koehler lunaperche macvim murphy
  "      pablo quiet retrobox ron slate sorbet torte wildcharm zaibatsu
  " Custom: one seoul256 solarized8 solarized8_flat solarized8_high solarized8_low
  colorscheme wildcharm

  " ALEWarning uses this too
  highlight SpellCap guisp=Yellow

  if g:colors_name == 'darkblue'
    hi SignColumn ctermbg=NONE guibg=#00002D
    hi ColorColumn ctermbg=17 guibg=#00105f
  else
    highlight ColorColumn ctermfg=59 guibg=Grey37
  endif

  if g:colors_name == 'one'
    " https://github.com/rakr/vim-one#customising-one-without-fork
    " https://github.com/rakr/vim-one/blob/master/colors/one.vim
    call one#highlight('CursorLine', '', '3f454f', 'none')
    call one#highlight('CursorLineNr', '', '3f454f', 'none')
    call one#highlight('LineNr', '777777', '', 'none')
    call one#highlight('Comment', '999999', '', 'none')
    call one#highlight('vimLineComment', '999999', '', 'none')
    call one#highlight('Visual', '', '660000', 'none')
  endif

  " \ 'guifgs': ['royalblue', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
  " \ 'guifgs': ['Violet', '#33b0ff', 'Cyan', 'Green', 'Yellow', 'Orange', 'Red'],
  " \ 'guifgs': ['Violet', 'Red', '#33b0ff', 'Orange', 'Cyan', 'Yellow', 'Green'],
  " \ 'guifgs': ['Green', 'Yellow', 'Cyan', 'Orange', '#33B0FF', 'Red', '#9B870C']
  " Sync: VS Code > settings.json > workbench.colorCustomizations > (preferred dark theme) >
  "       editorBracketHighlight.foreground*
  let g:rainbow_conf = {
    \ 'guifgs': ['#ffd700', '#da70d6', '#87cefa', '#ffa500', '#33b0ff', '#af00ff', '#9b870c']
  \ }
  " [({[({[]})]})]

  let g:airline_solarized_bg='dark'

  if g:colors_name == 'seoul256'
    let g:seoul256_background = 233
  endif

  if g:colors_name == 'slate'
    hi SignColumn ctermbg=NONE guibg=NONE
  endif

  " \ 'macvim': 'papercolor',
  call SetAirlineTheme({
    \ 'one': 'one',
    \ 'space_vim_theme': 'solarized'
    \ })
endfun

fun! SetupLight()
  set background=light

  " Color schemes that support light background:
  " Vim: delek lunaperche macvim morning peachpuff quiet retrobox shine wildcharm zellner
  " Custom: github one seoul256-light solarized8 solarized8_flat solarized8_high solarized8_low
  colorscheme wildcharm

  let g:indent_guides_auto_colors = 0

  if InArray(['one', 'macvim'], g:colors_name)
    " autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#f6f6f6 ctermbg=15
    hi IndentGuidesOdd  guibg=#f6f6f6 ctermbg=15
    " autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=white ctermbg=7
    hi IndentGuidesEven guibg=white ctermbg=7

  elseif g:colors_name == 'solarized8_high'
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#fcf6e5 ctermbg=229
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#fffceb ctermbg=230
    hi Comment guifg=Black guibg=NONE guisp=NONE gui=italic cterm=italic

  elseif g:colors_name == 'wildcharm'
    hi IndentGuidesOdd  guibg=#fafafa ctermbg=15
    " autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=white ctermbg=7
    hi IndentGuidesEven guibg=#f7f7f7 ctermbg=7

  else
    " Includes morning
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#f0f0f0 ctermbg=15
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#e9e9e9 ctermbg=7

  endif

  " Others define their own color, or we want to override these
  if InArray([
        \ 'one',
        \ 'seoul256-light',
        \ 'zellner',
        \ ], g:colors_name)
    highlight ColorColumn ctermfg=255 guibg=Grey93
    highlight ALEVirtualTextWarning guifg=#c3b191
  endif

  if !InArray([
        \ 'morning',
        \ ], g:colors_name)
    " ALEWarning uses this too
    highlight SpellCap guisp=Orange
    highlight SpellBad guisp=DarkOrange
    highlight ALEError guisp=Red
  endif

  " Sync: VS Code > settings.json > workbench.colorCustomizations > (preferred light theme) >
  "       editorBracketHighlight.foreground*
  let g:rainbow_conf = {
    \ 'guifgs': ['#87af87', '#af00d7', '#0000ff', '#ff8700', '#33b0ff', '#800080', '#9b870c']
  \ }
  " [({[({[]})]})]

  " https://github.com/junegunn/fzf.vim#global-options
  " let g:fzf_colors = {
    " \ 'fg':      ['fg', 'Red'],
    " \ 'bg':      ['bg', 'Normal'],
  " \ }

  if g:colors_name == 'morning'
    " Originally Green, which is not very visible on Cyan matching braces
    hi Cursor guibg=white guifg=NONE
  endif

  if g:colors_name == 'seoul256-light'
    let g:seoul256_background = 256
  endif

  call SetAirlineTheme({
    \ 'github': 'silver',
    \ 'macvim': 'silver',
    \ 'morning': 'papercolor',
    \ 'one': 'one'
    \ })
endfun

" https://github.com/vim-airline/vim-airline-themes/tree/master/autoload/airline/themes
" https://github.com/vim-airline/vim-airline/wiki/Screenshots
fun! SetAirlineTheme(colo2air)
  let l:airline_theme = get(a:colo2air, g:colors_name)
  if l:airline_theme
    let g:airline_theme = l:airline_theme
  endif
endfun

" https://stackoverflow.com/a/40728903/372654
highlight ExtraWhitespace ctermbg=Red guibg=Red
match ExtraWhitespace /\s\+$/
augroup my_extra_whitespace
  autocmd!
  autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
  autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  autocmd InsertLeave * match ExtraWhitespace /\s\+$/
  autocmd BufWinLeave * call clearmatches()
augroup end
" command -bar SearchTrailingWs exe '/\s$' | exe '<CR>n'
nnoremap <leader>/ :/\s$<CR>n

" https://stackoverflow.com/a/51195979/372654
highlight StrangeWhitespace ctermbg=Red guibg=Red
" https://stackoverflow.com/a/37903645 - removed `\t`, `\n`, ` `, `\xa0`
call matchadd('StrangeWhitespace', '[\x0b\x0c\r\x1c\x1d\x1e\x1f\x85\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000]')

" https://stackoverflow.com/a/39360896/372654
nnoremap <leader>rm :call DeleteFileAndCloseBuffer()<CR>

fun! DeleteFileAndCloseBuffer()
  let l:file = expand('%:p')

  if isdirectory(l:file)
    echo "DeleteFileAndCloseBuffer: " . l:file . " is not a file"
  else
    let l:choice = confirm("Delete " . l:file . " and close buffer?", "&Delete\n&Cancel", 1)
    if l:choice == 1
      " call delete(l:file)
      Remove
      bdelete
    endif
  endif
endfun

fun! s:real_paths()
  let l:real_file_path = resolve(expand('%:p'))
  let l:real_folder = fnamemodify(real_file_path, ':h')
  let l:git_root = system("cd " . shellescape(real_folder) . " && git rev-parse --show-toplevel | tr -d '\\n'")

  if v:shell_error == 0
    return [real_file_path, git_root]
  else
    echoer git_root
    return ''
  endif
endfun

fun! GitPath(real_paths = s:real_paths())
  if empty(a:real_paths)
    return
  else
    return substitute(a:real_paths[0], '\V' . a:real_paths[1] . '/', '', '')
  endif
endfun

command SourceTreeStatus call SourceTreeFileStatus()

" Note: Needs Accessibility and Automation > System Events permissions
fun! SourceTreeFileStatus()
  let l:real_paths = s:real_paths()
  let l:git_path = GitPath(l:real_paths)
  if empty(real_paths)
    return
  else
    let l:cmd = "osascript $DOTFILES_SHARED/share/sourcetree-file-status.applescript "
      \ . shellescape(real_paths[1]) . " " . shellescape(git_path)
    " echo "Calling: " . cmd
    call system(cmd)
  endif
endfun

" https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
" Save current view settings on a per-window, per-buffer basis.
fun! AutoSaveWinView()
  if !exists("w:SavedBufView")
    let w:SavedBufView = {}
  endif
  let w:SavedBufView[bufnr("%")] = winsaveview()
endfun

" Restore current view settings.
fun! AutoRestoreWinView()
  let l:buf = bufnr("%")
  if exists("w:SavedBufView") && has_key(w:SavedBufView, l:buf)
    let l:view = winsaveview()
    let l:atStartOfFile = l:view.lnum == 1 && l:view.col == 0
    if l:atStartOfFile && !&diff
      call winrestview(w:SavedBufView[l:buf])
    endif
    unlet w:SavedBufView[l:buf]
  endif
endfun

" When switching buffers, preserve window view.
if v:version >= 700
  augroup my_preserve_window_view
    autocmd!
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
  augroup END
endif
" End: Avoid_scrolling_when_switch_buffers

command CopyAbsPath call CopyAndEcho(expand('%:~'))
command CopyRelPath call CopyAndEcho(expand('%'))
command CopyGitPath call CopyAndEcho(GitPath())
command CopyGitPathLine call CopyAndEchoGitPathLine()

fun! CopyAndEcho(val)
  let @+ = a:val
  echo 'Copied "' . getreg('+') . '"'
endfun

fun! GitPathLine()
  return GitPath() . ':' . line('.')
endfun

fun! CopyAndEchoGitPathLine()
  call CopyAndEcho(GitPathLine())
endfun

command SnipViewUltiSnips call Snip('UltiSnips', 'view')
command SnipViewSnipMate call Snip('snippets', 'view')
command SnipEditUltiSnips call Snip('UltiSnips', 'edit')

fun! Snip(folder, cmd)
  if a:cmd == 'view'
    let l:prefix = 'plugged/vim-snippets/'
  else
    let l:prefix = ''
  endif

  exe a:cmd '~/.vim/' . l:prefix . a:folder . '/' . &filetype . '.snippets'
endfun
