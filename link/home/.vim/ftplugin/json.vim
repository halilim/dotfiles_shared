" nnoremap :FormatJSON :%!python3 -m json.tool
com! FormatJSON %!python3 -m json.tool
" This delays FZF (,f)
" nmap <Leader>fmt :FormatJSON<CR>

" jsonc support
syntax match Comment +\/\/.\+$+
