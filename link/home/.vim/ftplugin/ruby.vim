" See .vimrc for ale_fixers/ale_linters etc.

" RubyCursorTag is defined in ~/.vim/plugged/vim-ruby/ftplugin/ruby.vim:361
nnoremap g] :exe('Tags '.RubyCursorTag().' ')<CR>
